--[[
Floating windows.

The filter dialog and the panels all want the same thing: some lines of text in
a centred float that closes on `q` or Escape. This is that, and nothing else.
]]

local M = {}

---@param lines string[]
---@return integer
local function longest(lines)
  local width = 0
  for _, line in ipairs(lines) do
    local measured = vim.fn.strdisplaywidth(line)
    if measured > width then
      width = measured
    end
  end
  return width
end

--- Open `lines` in a centred float.
---@param lines string[]
---@param opts { title: string, modifiable: boolean|nil }
---@return integer bufnr
---@return integer winid
function M.open(lines, opts)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = opts.modifiable or false
  vim.bo[bufnr].bufhidden = "wipe"

  local width = math.max(math.min(longest(lines) + 2, vim.o.columns - 8), #opts.title + 6)
  local height = math.max(math.min(#lines, vim.o.lines - 8), 1)

  local winid = vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    row = math.max(math.floor((vim.o.lines - height) / 2) - 1, 0),
    col = math.max(math.floor((vim.o.columns - width) / 2), 0),
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " " .. opts.title .. " ",
  })
  vim.wo[winid].wrap = false
  vim.wo[winid].cursorline = true

  M.close_on(bufnr, winid, { "q", "<Esc>" })
  return bufnr, winid
end

--- Open `lines` in a horizontal split below, tall enough to hold them.
---@param lines string[]
---@param opts { title: string }
---@return integer bufnr
---@return integer winid
function M.split(lines, opts)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].bufhidden = "wipe"
  vim.api.nvim_buf_set_name(bufnr, opts.title)

  vim.cmd.split()
  local winid = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(winid, bufnr)
  vim.api.nvim_win_set_height(winid, math.min(#lines + 1, math.floor(vim.o.lines / 2)))
  vim.wo[winid].wrap = false
  vim.wo[winid].cursorline = true

  M.close_on(bufnr, winid, { "q", "<Esc>" })
  return bufnr, winid
end

--- Close `winid` when any of `keys` is pressed in `bufnr`.
---@param bufnr integer
---@param winid integer
---@param keys string[]
function M.close_on(bufnr, winid, keys)
  for _, key in ipairs(keys) do
    vim.keymap.set("n", key, function()
      M.close(winid)
    end, { buffer = bufnr, nowait = true })
  end
end

---@param winid integer
function M.close(winid)
  if vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_win_close(winid, true)
  end
end

return M
