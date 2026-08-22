--[[
The actions that act on a column.

Hiding, cutting, pasting and moving change which columns are shown. Aligning,
padding and formatting change how one column reads. Both resolve their column
from the cursor, and the movement ones carry the cursor along so the column that
moved is still the one under it.
]]

local buffer = require("csv.buffer")
local cursor = require("csv.cursor")
local format = require("csv.format")
local selection = require("csv.selection")

local M = {}

---@param description string
---@param run fun(buf: csv.Buffer)
---@return csv.Action
local function action(description, run)
  return { description = description, run = run }
end

--- Run `change` against the column under the cursor, then repaint.
---@param buf csv.Buffer
---@param change fun(column: csv.Column)
local function on_column(buf, change)
  local column = cursor.column_at(buf, 0)
  if not column then
    return
  end
  change(column)
  buffer.render(buf)
end

--- Repaint, then put the cursor back on `column` and flash it, so a column that
--- moved stays under the cursor that moved it.
---@param buf csv.Buffer
---@param column csv.Column
local function follow(buf, column)
  local cell
  for position, candidate in ipairs(selection.selected(buf.state)) do
    if candidate.index == column.index then
      cell = position + 1
    end
  end

  buffer.render(buf, function()
    if cell then
      cursor.focus_cell(buf, 0, cell)
      cursor.flash_cell(buf, cell)
    end
  end)
end

---@param align "left"|"center"|"right"
---@return fun(buf: csv.Buffer)
local function aligner(align)
  return function(buf)
    on_column(buf, function(column)
      format.set_align(buf.state.formats, column, align)
    end)
  end
end

---@param delta integer
---@return fun(buf: csv.Buffer)
local function precision(delta)
  return function(buf)
    on_column(buf, function(column)
      format.adjust_precision(buf.state.formats, column, delta)
    end)
  end
end

---@param delta integer
---@return fun(buf: csv.Buffer)
local function width(delta)
  return function(buf)
    on_column(buf, function(column)
      format.adjust_width(buf.state.formats, column, delta)
    end)
  end
end

---@param delta integer
---@return fun(buf: csv.Buffer)
local function mover(delta)
  return function(buf)
    local column = cursor.column_at(buf, 0)
    if column and selection.swap_column(buf.state, column, delta) then
      follow(buf, column)
    end
  end
end

---@param before boolean
---@return fun(buf: csv.Buffer)
local function paster(before)
  return function(buf)
    local held = buf.state.clipboard[1]
    local column = cursor.column_at(buf, 0)
    if selection.paste_columns(buf.state, column, before) then
      follow(buf, held)
    end
  end
end

---@type table<string, csv.Action>
M.actions = {
  next_column = action("Move to the next column", function(buf)
    cursor.jump_column(buf, 0, 1)
  end),

  prev_column = action("Move to the previous column", function(buf)
    cursor.jump_column(buf, 0, -1)
  end),

  hide_column = action("Hide this column", function(buf)
    on_column(buf, function(column)
      selection.hide_column(buf.state, column)
    end)
  end),

  show_all_columns = action("Show every column again", function(buf)
    selection.show_all_columns(buf.state)
    buffer.render(buf)
  end),

  cut_column = action("Cut this column, holding it to paste", function(buf)
    on_column(buf, function(column)
      selection.cut_column(buf.state, column, false)
    end)
  end),

  cut_append_column = action("Add this column to the cut being held", function(buf)
    on_column(buf, function(column)
      selection.cut_column(buf.state, column, true)
    end)
  end),

  paste_columns_after = action("Paste the held columns after this one", paster(false)),
  paste_columns_before = action("Paste the held columns before this one", paster(true)),
  move_column_left = action("Move this column one place left", mover(-1)),
  move_column_right = action("Move this column one place right", mover(1)),

  align_left = action("Align this column left", aligner("left")),
  align_center = action("Align this column centre", aligner("center")),
  align_right = action("Align this column right", aligner("right")),

  increase_precision = action("Show one more decimal in this column", precision(1)),
  decrease_precision = action("Show one fewer decimal in this column", precision(-1)),
  increase_width = action("Widen this column by one", width(1)),
  decrease_width = action("Narrow this column by one", width(-1)),

  set_format = action("Give this column a printf format", function(buf)
    local column = cursor.column_at(buf, 0)
    if not column then
      return
    end

    local current = buf.state.formats[column.index]
    vim.ui.input({ prompt = "printf format: ", default = current and current.spec or "" }, function(spec)
      if spec == nil then
        return
      end
      format.set_spec(buf.state.formats, column, spec)
      buffer.render(buf)
    end)
  end),
}

return M
