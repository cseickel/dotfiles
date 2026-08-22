--[[
Entry point.

Wires the buffer-local keymaps to state changes, and exposes the `:CsvTable`
command that opens a file. Every action resolves what it needs from the cursor,
changes the state, and asks for a repaint.
]]

local buffer = require("csv.buffer")
local state = require("csv.state")

local M = {}

local actions = {}
M.actions = actions

---@param buf csv.Buffer
---@param change fun(column: csv.Column)
local function on_column(buf, change)
  local column = buffer.column_at_cursor(buf, 0)
  if not column then
    return
  end
  change(column)
  buffer.render(buf)
end

function actions.sort(buf)
  on_column(buf, function(column)
    state.sort_by(buf.state, column)
  end)
end

function actions.add_sort_key(buf)
  on_column(buf, function(column)
    state.add_sort_key(buf.state, column)
  end)
end

function actions.clear_sort(buf)
  state.clear_sort(buf.state)
  buffer.render(buf)
end

function actions.hide_column(buf)
  on_column(buf, function(column)
    state.hide_column(buf.state, column)
  end)
end

function actions.show_all_columns(buf)
  state.show_all_columns(buf.state)
  buffer.render(buf)
end

--- Swap the column under the cursor with a neighbour, then follow it: after the
--- repaint the cursor would otherwise sit on whatever column took its place.
---@param buf csv.Buffer
---@param delta integer
local function swap_column(buf, delta)
  local column = buffer.column_at_cursor(buf, 0)
  if not column then
    return
  end

  if not state.swap_column(buf.state, column, delta) then
    return
  end

  local cell
  for index, candidate in ipairs(state.selected(buf.state)) do
    if candidate.index == column.index then
      cell = index + 1
    end
  end

  buffer.render(buf, function()
    buffer.focus_cell(buf, 0, cell)
    buffer.flash_cell(buf, cell)
  end)
end

function actions.move_column_left(buf)
  swap_column(buf, -1)
end

function actions.move_column_right(buf)
  swap_column(buf, 1)
end

function actions.next_page(buf)
  if buffer.at_last_page(buf) then
    return vim.notify("csv: last page", vim.log.levels.INFO)
  end
  state.turn_page(buf.state, 1)
  buffer.render(buf)
end

function actions.prev_page(buf)
  state.turn_page(buf.state, -1)
  buffer.render(buf)
end

function actions.first_page(buf)
  state.goto_page(buf.state, 0)
  buffer.render(buf)
end

function actions.pop_filter(buf)
  state.pop_filter(buf.state)
  buffer.render(buf)
end

function actions.clear_filters(buf)
  state.clear_filters(buf.state)
  buffer.render(buf)
end

function actions.refresh(buf)
  buffer.render(buf)
end

function actions.clear_all(buf)
  state.reset(buf.state)
  buffer.render(buf)
end

M.keymaps = {
  ["s"] = "sort",
  ["S"] = "add_sort_key",
  ["<leader>sc"] = "clear_sort",

  ["x"] = "hide_column",
  ["X"] = "show_all_columns",
  ["<"] = "move_column_left",
  [">"] = "move_column_right",

  ["]"] = "next_page",
  ["["] = "prev_page",
  ["[["] = "first_page",

  ["<BS>"] = "pop_filter",
  ["<leader>fc"] = "clear_filters",

  ["<leader>r"] = "refresh",
  ["<leader>x"] = "clear_all",
}

---@param buf csv.Buffer
local function apply_keymaps(buf)
  for lhs, name in pairs(M.keymaps) do
    local action = actions[name]
    if not action then
      error(string.format("csv: keymap %q names unknown action %q", lhs, name))
    end
    vim.keymap.set("n", lhs, function()
      action(buf)
    end, { buffer = buf.bufnr, desc = "csv: " .. name })
  end
end

--- How the page on display reads in a statusline. Empty for any other buffer.
---@param bufnr integer
---@return string
function M.status(bufnr)
  local buf = buffer.get(bufnr)
  if not buf or not buf.layout then
    return ""
  end

  local first, last = buffer.row_range(buf)
  if last < first then
    return "no rows"
  end

  local text = string.format("rows %d-%d", first, last)
  if buffer.at_last_page(buf) then
    return text .. " (end)"
  end
  return text
end

M.patterns = { "*.csv", "*.tsv" }

function M.setup(opts)
  opts = opts or {}
  if opts.keymaps then
    M.keymaps = opts.keymaps
  end
  if opts.patterns then
    M.patterns = opts.patterns
  end

  -- `BufReadCmd` replaces nvim's own read, so the file's text never enters the
  -- buffer and a multi-gigabyte CSV costs nothing to open.
  vim.api.nvim_create_autocmd("BufReadCmd", {
    pattern = M.patterns,
    callback = function(event)
      buffer.attach(event.buf, apply_keymaps)
    end,
  })

  vim.api.nvim_create_user_command("CsvTable", function(command)
    local path = command.args ~= "" and command.args or vim.api.nvim_buf_get_name(0)
    if path == "" then
      return vim.notify("csv: no file to open", vim.log.levels.ERROR)
    end
    vim.cmd.edit(vim.fn.fnameescape(path))
  end, { nargs = "?", complete = "file", desc = "Open a CSV as a table" })
end

return M
