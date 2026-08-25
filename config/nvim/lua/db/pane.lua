--[[
The window a query's output opens in.

The client writes its output to a file and this window shows that file, so the
text is read by nvim and never passes through lua. While the client is still
writing, the file is reloaded on a timer, which is what makes a script's
transcript fill in as it runs.

Each source window keeps one output window, so a second query lands where the
first did rather than splitting again.
]]

local M = {}

-- One name for the key, so what the indicator offers and what it binds cannot
-- drift. Bound in visual mode too, because a query is often started from a
-- selection and the selection is still there while it runs.
local CANCEL = "<C-c>"
local MODES = { "n", "x" }

-- The output window, by source window id.
---@type table<integer, integer>
local panes = {}

-- The query writing into each source window's pane, by window id.
---@type table<integer, db.Run>
local running = {}

-- What takes down the indicator beside each source window's query, by window
-- id.
---@type table<integer, fun()>
local indicators = {}

--- Remembers `run` as the query writing into `srcWin`'s pane.
---@param srcWin integer
---@param run db.Run
function M.attach(srcWin, run)
  running[srcWin] = run
end

--- Forgets `run`, which has ended, if it is still the query writing into
--- `srcWin`'s pane. A run that was replaced before it ended forgets nothing,
--- so the one that replaced it stays cancellable.
---@param srcWin integer
---@param run db.Run
function M.release(srcWin, run)
  if running[srcWin] == run then
    running[srcWin] = nil
  end
end

--- Cancels the query writing into `srcWin`'s pane, if one still is. A cancel
--- is a request, so the run stays the running query until it exits of its own
--- accord and reports the cancellation itself.
---@param srcWin integer
function M.stop(srcWin)
  local run = running[srcWin]
  if run then
    run.cancel()
  end
end

-- Cancelling leaves the client to end in its own time, which it will not get
-- once nvim is gone, and a detached client does not die with nvim either.
-- Someone will delete this and leave a psql holding a transaction open.
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    for srcWin, run in pairs(running) do
      running[srcWin] = nil
      run.job:kill("sigterm")
    end
  end,
})

--- Shows the file at `path` in `srcWin`'s output window, opening that window
--- below the query if this is the first output from it. The current window
--- does not change.
---@param srcWin integer
---@param path string
---@param db string The connection the file came from, for the buffer to carry.
---@return integer buf
function M.show(srcWin, path, db)
  -- Named and then shown by number, because a path put into an :edit command
  -- has to be escaped and a buffer number does not.
  local buf = vim.fn.bufadd(path)

  local win = panes[srcWin]
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_set_buf(win, buf)
  else
    local parent = vim.api.nvim_win_is_valid(srcWin) and srcWin or 0
    win = vim.api.nvim_open_win(buf, false, { split = "below", win = parent })
    panes[srcWin] = win
  end

  -- Opening at the bottom is what sets the file following itself.
  vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })

  -- Output is aligned in columns, so wrapping would break a row across screen
  -- lines and unalign it, and a line number counts nothing the reader wants.
  vim.wo[win].wrap = false
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false

  -- autoread so a reload while the client is still writing needs no answer,
  -- wipe so the output of one query goes when the next one takes the window.
  vim.bo[buf].autoread = true
  vim.bo[buf].bufhidden = "wipe"
  vim.b[buf].db = db

  -- The file outlives nvim otherwise, and one query's output can be larger
  -- than everything else in the cache directory put together.
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    once = true,
    callback = function()
      os.remove(path)
    end,
  })
  return buf
end

--- Rereads `buf` from disk. A window whose cursor was on the last line follows
--- the file down.
---@param buf integer
local function reread(buf)
  local count = vim.api.nvim_buf_line_count(buf)
  local following = {}
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    following[win] = vim.api.nvim_win_get_cursor(win)[1] == count
  end

  vim.cmd("checktime " .. buf)

  local bottom = vim.api.nvim_buf_line_count(buf)
  for win, follows in pairs(following) do
    if follows and vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_set_cursor(win, { bottom, 0 })
    end
  end
end

-- Slow enough that a client writing steadily does not reread on every write,
-- fast enough to read as live.
local REFRESH = 500

--- Shows `path` in `srcWin`'s output window and keeps it current while the
--- client is still writing it. The window stays shut until the file has
--- something in it, so a query that prints nothing opens nothing. Returns the
--- function that stops following, after one last reread.
---@param srcWin integer
---@param path string
---@param db string
---@return fun() stop
function M.follow(srcWin, path, db)
  local timer = vim.uv.new_timer()
  local buf

  local function refresh()
    if not buf then
      local stat = vim.uv.fs_stat(path)
      if stat and stat.size > 0 then
        buf = M.show(srcWin, path, db)
      end
      return
    end
    if vim.api.nvim_buf_is_valid(buf) then
      reread(buf)
    end
  end

  timer:start(REFRESH, REFRESH, vim.schedule_wrap(refresh))

  return function()
    timer:stop()
    timer:close()
    refresh()
  end
end

local FRAMES = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local NAMESPACE = vim.api.nvim_create_namespace("db_pane_progress")
-- The extmark carrying the indicator, so redrawing moves it rather than
-- leaving one behind.
local MARK = 1

--- Turns a spinner and a clock at the end of the line `srcWin` sits on, and
--- binds the key that stops its query in that window's buffer. Returns the
--- function that takes both away again.
---
--- The indicator is virtual text, so it cannot be edited, yanked, or undone,
--- and it stays beside the query rather than in the output.
---@param srcWin integer
---@return fun() stop
function M.progress(srcWin)
  -- One query per window means one indicator per window, and the one being
  -- replaced is taken down while it still owns the mark and the mapping.
  if indicators[srcWin] then
    indicators[srcWin]()
  end

  local started = vim.uv.hrtime()
  local frame = 0
  local timer = vim.uv.new_timer()

  local buf, row
  if vim.api.nvim_win_is_valid(srcWin) then
    buf = vim.api.nvim_win_get_buf(srcWin)
    row = vim.api.nvim_win_get_cursor(srcWin)[1] - 1
    vim.keymap.set(MODES, CANCEL, function()
      M.stop(srcWin)
    end, { buffer = buf, desc = "cancel the running query" })
  end

  local function draw()
    if not (buf and vim.api.nvim_buf_is_valid(buf)) then
      return
    end
    -- Where the mark is now, so editing the query above it does not leave the
    -- indicator beside a different statement. Reloading the buffer clears the
    -- mark and can leave the line it started on past the end, so the fallback
    -- is clamped rather than trusted.
    local placed = vim.api.nvim_buf_get_extmark_by_id(buf, NAMESPACE, MARK, {})
    local at = placed[1] or math.min(row, vim.api.nvim_buf_line_count(buf) - 1)
    frame = frame % #FRAMES + 1
    vim.api.nvim_buf_set_extmark(buf, NAMESPACE, at, 0, {
      id = MARK,
      virt_text = {
        { "  " .. FRAMES[frame] .. "  ", "DiagnosticInfo" },
        { string.format("%.1fs", (vim.uv.hrtime() - started) / 1e9), "Comment" },
        { "    " .. CANCEL .. " to cancel", "NonText" },
      },
      virt_text_pos = "eol",
    })
  end

  local stop
  stop = function()
    if indicators[srcWin] ~= stop then
      return
    end
    indicators[srcWin] = nil
    timer:stop()
    timer:close()
    if buf and vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.keymap.del, MODES, CANCEL, { buffer = buf })
      vim.api.nvim_buf_clear_namespace(buf, NAMESPACE, 0, -1)
    end
  end

  indicators[srcWin] = stop
  draw()
  timer:start(80, 80, vim.schedule_wrap(draw))
  return stop
end

return M
