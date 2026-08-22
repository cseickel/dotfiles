--[[
Which columns are shown, and in what order.

`state.selected` empty means every source column in file order, which is the
state a freshly opened file is in. The first change that needs a position
materialises the full list, so nothing here has to reason about the empty case
twice.
]]

local M = {}

--- The columns on display, in display order.
---@param state csv.State
---@return csv.Column[]
function M.selected(state)
  if #state.selected > 0 then
    return state.selected
  end
  return state.columns
end

--- Materialise `selected` so a column can be removed from or moved within it.
---@param state csv.State
local function fix_selection(state)
  if #state.selected > 0 then
    return
  end
  local copy = {}
  for index, column in ipairs(state.columns) do
    copy[index] = column
  end
  state.selected = copy
end

---@param list csv.Column[]
---@param column csv.Column
---@return integer|nil
local function position_of(list, column)
  for index, candidate in ipairs(list) do
    if candidate.index == column.index then
      return index
    end
  end
  return nil
end

---@param state csv.State
---@param column csv.Column
function M.hide_column(state, column)
  fix_selection(state)
  local index = position_of(state.selected, column)
  if index then
    table.remove(state.selected, index)
  end
end

--- Hide a column and hold it for pasting. `append` adds to a cut already held
--- rather than replacing it, so several columns move together.
---@param state csv.State
---@param column csv.Column
---@param append boolean
function M.cut_column(state, column, append)
  if not append then
    state.clipboard = {}
  end
  if not position_of(state.clipboard, column) then
    table.insert(state.clipboard, column)
  end
  M.hide_column(state, column)
end

--- Put the held columns back, beside `column`.
---@param state csv.State
---@param column csv.Column|nil Paste at the end when absent.
---@param before boolean
---@return boolean pasted
function M.paste_columns(state, column, before)
  if #state.clipboard == 0 then
    return false
  end

  fix_selection(state)
  local at = column and position_of(state.selected, column)
  local insert_at = #state.selected + 1
  if at then
    insert_at = before and at or at + 1
  end

  for offset, held in ipairs(state.clipboard) do
    table.insert(state.selected, insert_at + offset - 1, held)
  end
  state.clipboard = {}
  return true
end

--- Exchange a column with its neighbour `delta` places away.
---@param state csv.State
---@param column csv.Column
---@param delta integer
---@return boolean moved False at the edge of the selection.
function M.swap_column(state, column, delta)
  fix_selection(state)
  local index = position_of(state.selected, column)
  if not index then
    return false
  end

  local target = index + delta
  if target < 1 or target > #state.selected then
    return false
  end
  state.selected[index], state.selected[target] = state.selected[target], state.selected[index]
  return true
end

---@param state csv.State
function M.show_all_columns(state)
  state.selected = {}
  state.columns_filtered_to_marks = false
end

--- Show only the marked columns, or every column if already restricted.
---@param state csv.State
function M.toggle_marked_columns(state)
  if state.columns_filtered_to_marks then
    return M.show_all_columns(state)
  end

  local kept = {}
  for _, column in ipairs(state.columns) do
    if state.marked_columns[column.index] then
      table.insert(kept, column)
    end
  end
  if #kept == 0 then
    return
  end
  state.selected = kept
  state.columns_filtered_to_marks = true
end

return M
