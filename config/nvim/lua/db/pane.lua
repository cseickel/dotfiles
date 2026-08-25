--[[
The window a query's output opens in.

Each source window remembers one output window and reuses it, so a second query
lands where the first did rather than splitting again. A script still writing
into that window is killed when the window is reused, because reuse takes away
the buffer it was writing to and every handle on it.
]]

local M = {}

local WINVAR = "db_pane_win"

-- The query writing into each source window's pane, by window id.
---@type table<integer, db.Run>
local running = {}

---@param srcWin integer
---@return integer|nil
local function windowFor(srcWin)
  local ok, win = pcall(vim.api.nvim_win_get_var, srcWin, WINVAR)
  if ok and type(win) == "number" and vim.api.nvim_win_is_valid(win) then
    return win
  end
end

--- Remembers `run` as the query writing into `srcWin`'s pane.
---@param srcWin integer
---@param run db.Run
function M.attach(srcWin, run)
  running[srcWin] = run
end

--- Forgets the query writing into `srcWin`'s pane, which has ended.
---@param srcWin integer
function M.release(srcWin)
  running[srcWin] = nil
end

--- Cancels the query writing into `srcWin`'s pane, if one still is. The client
--- reports the cancellation itself and then ends, so nothing is torn down
--- here.
---@param srcWin integer
function M.stop(srcWin)
  local run = running[srcWin]
  if run then
    running[srcWin] = nil
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

--- Opens the window paired with `srcWin` on an empty buffer and leaves that
--- window current.
---@param srcWin integer
function M.open(srcWin)
  M.stop(srcWin)

  local win = windowFor(srcWin)
  if win then
    vim.api.nvim_set_current_win(win)
    local old = vim.api.nvim_win_get_buf(win)
    -- The pane only ever holds query output, and the buffer being replaced is
    -- deleted on the next line either way.
    vim.cmd("enew!")
    if vim.api.nvim_buf_is_valid(old) and old ~= vim.api.nvim_get_current_buf() then
      vim.api.nvim_buf_delete(old, { force = true })
    end
  else
    vim.api.nvim_set_current_win(srcWin)
    vim.cmd("belowright new")
    vim.api.nvim_win_set_var(srcWin, WINVAR, vim.api.nvim_get_current_win())
  end
end

--- Returns to `srcWin`, which opening its pane left.
---@param srcWin integer
function M.leave(srcWin)
  if vim.api.nvim_win_is_valid(srcWin) then
    vim.api.nvim_set_current_win(srcWin)
  end
end

local FRAMES = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local NAMESPACE = vim.api.nvim_create_namespace("db_pane_progress")
-- One name for the key, so what the pane offers and what it binds cannot drift.
local CANCEL = "<C-c>"

--- Turns a spinner and a clock under the last line of `buf`, and binds the key
--- that stops `srcWin`'s job in both `buf` and the buffer the query came from.
--- Returns the function that takes all of it away again.
---
--- The spinner is a virtual line rather than buffer text, so output keeps
--- arriving above it and none of it can be edited, yanked, or undone.
---@param srcWin integer
---@param buf integer
---@return fun() stop
function M.progress(srcWin, buf)
  local started = vim.uv.hrtime()
  local frame = 0
  local timer = vim.uv.new_timer()

  local bound = { buf }
  if vim.api.nvim_win_is_valid(srcWin) then
    table.insert(bound, vim.api.nvim_win_get_buf(srcWin))
  end
  for _, target in ipairs(bound) do
    vim.keymap.set("n", CANCEL, function()
      M.stop(srcWin)
    end, { buffer = target, desc = "cancel the running query" })
  end

  local function draw()
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    frame = frame % #FRAMES + 1
    vim.api.nvim_buf_set_extmark(buf, NAMESPACE, vim.api.nvim_buf_line_count(buf) - 1, 0, {
      id = 1,
      virt_lines = {
        {
          { FRAMES[frame] .. "  ", "DiagnosticInfo" },
          { string.format("%.1fs", (vim.uv.hrtime() - started) / 1e9), "Comment" },
          { "    " .. CANCEL .. " to cancel", "NonText" },
        },
      },
    })
  end

  draw()
  timer:start(80, 80, vim.schedule_wrap(draw))

  return function()
    timer:stop()
    timer:close()
    for _, target in ipairs(bound) do
      if vim.api.nvim_buf_is_valid(target) then
        pcall(vim.keymap.del, "n", CANCEL, { buffer = target })
      end
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_clear_namespace(buf, NAMESPACE, 0, -1)
    end
  end
end

---@class db.Appender
---@field write fun(text: string) Adds text, holding its last line back until the newline comes.
---@field flush fun() Adds the held back line, which no newline is coming for.

--- Writes into `buf` as text arrives. A window whose cursor is on the last
--- line follows the text down.
---@param buf integer
---@return db.Appender
function M.appender(buf)
  local pending = ""

  local function put(lines)
    if not vim.api.nvim_buf_is_valid(buf) or #lines == 0 then
      return
    end

    local count = vim.api.nvim_buf_line_count(buf)
    local following = {}
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
      following[win] = vim.api.nvim_win_get_cursor(win)[1] == count
    end

    -- An empty buffer still has a first line, which the first text replaces.
    local from = count
    if count == 1 and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == "" then
      from = 0
    end

    local modifiable = vim.bo[buf].modifiable
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, from, -1, false, lines)
    vim.bo[buf].modifiable = modifiable

    local bottom = vim.api.nvim_buf_line_count(buf)
    for win, follows in pairs(following) do
      if follows and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_cursor(win, { bottom, 0 })
      end
    end
  end

  return {
    write = function(text)
      local lines = vim.split(pending .. text, "\n", { plain = true })
      pending = table.remove(lines)
      put(lines)
    end,
    flush = function()
      if pending ~= "" then
        local held = pending
        pending = ""
        put({ held })
      end
    end,
  }
end

return M
