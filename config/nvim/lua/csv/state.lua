--[[
View state and the actions that change it.

One state table per buffer, holding what the user asked for rather than any row
data. Every action here takes the values it needs explicitly, so it can be
called from a keymap, a command, or a test. Resolving those values from the
cursor belongs to `csv.buffer`.
]]

local columns = require("csv.columns")

local M = {}

local DEFAULT_LIMIT = 1000

---@class csv.SortKey
---@field column csv.Column
---@field direction "asc"|"desc"
---@field numeric boolean

---@class csv.FilterNumeric
---@field type "numeric"
---@field column csv.Column
---@field operator "=="|"!="|"<"|"<="|">"|">="
---@field value number

---@class csv.FilterString
---@field type "string"
---@field column csv.Column
---@field operator "eq"|"ne"|"contains"|"startswith"|"endswith"|"regex"
---@field value string

---@class csv.FilterIn
---@field type "in"
---@field column csv.Column
---@field values string[]

---@class csv.FilterExpr
---@field type "expr"
---@field expression string Hand-written moonblade.

---@alias csv.Filter csv.FilterNumeric|csv.FilterString|csv.FilterIn|csv.FilterExpr

---@class csv.State
---@field source string         Path of the CSV file.
---@field columns csv.Column[]  Every source column, in file order.
---@field rowid_name string     Name for the prepended row id, absent from `columns`.
---@field where csv.Filter[]    ANDed together.
---@field order csv.SortKey[]   Most significant key first.
---@field selected csv.Column[] Display order. Empty means every source column.
---@field formats table<integer, csv.Format> Keyed by column index.
---@field page integer          0-based.
---@field limit integer         Rows per page.

---@param source csv.Source
---@return csv.State
function M.new(source)
  return {
    source = source.path,
    columns = source.columns,
    rowid_name = source.rowid_name,
    formats = source.formats,
    where = {},
    order = {},
    selected = {},
    page = 0,
    limit = DEFAULT_LIMIT,
  }
end

--- Whether a column holds numbers, which decides how it sorts.
---@param state csv.State
---@param column csv.Column
---@return boolean
function M.is_numeric(state, column)
  local format = state.formats[column.index]
  return format ~= nil and format.kind ~= "text"
end

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

---@param state csv.State
---@param column csv.Column
function M.sort_by(state, column)
  local only_key = #state.order == 1 and state.order[1]
  if only_key and only_key.column.index == column.index then
    only_key.direction = only_key.direction == "asc" and "desc" or "asc"
  else
    state.order = {
      { column = column, direction = "asc", numeric = M.is_numeric(state, column) },
    }
  end
  state.page = 0
end

--- Append a less significant sort key, or flip one already present.
---@param state csv.State
---@param column csv.Column
function M.add_sort_key(state, column)
  for _, key in ipairs(state.order) do
    if key.column.index == column.index then
      key.direction = key.direction == "asc" and "desc" or "asc"
      state.page = 0
      return
    end
  end
  table.insert(state.order, {
    column = column,
    direction = "asc",
    numeric = M.is_numeric(state, column),
  })
  state.page = 0
end

---@param state csv.State
function M.clear_sort(state)
  state.order = {}
  state.page = 0
end

---@param state csv.State
---@param column csv.Column
function M.hide_column(state, column)
  fix_selection(state)
  for index, candidate in ipairs(state.selected) do
    if candidate.index == column.index then
      table.remove(state.selected, index)
      return
    end
  end
end

--- Exchange a column with its neighbour `delta` places away.
---@param state csv.State
---@param column csv.Column
---@param delta integer
---@return boolean moved False at the edge of the selection.
function M.swap_column(state, column, delta)
  fix_selection(state)
  for index, candidate in ipairs(state.selected) do
    if candidate.index == column.index then
      local target = index + delta
      if target < 1 or target > #state.selected then
        return false
      end
      state.selected[index], state.selected[target] = state.selected[target], state.selected[index]
      return true
    end
  end
  return false
end

---@param state csv.State
function M.show_all_columns(state)
  state.selected = {}
end

---@param state csv.State
---@param filter csv.Filter
function M.add_filter(state, filter)
  table.insert(state.where, filter)
  state.page = 0
end

---@param state csv.State
function M.pop_filter(state)
  table.remove(state.where)
  state.page = 0
end

---@param state csv.State
function M.clear_filters(state)
  state.where = {}
  state.page = 0
end

---@param state csv.State
---@param delta integer
function M.turn_page(state, delta)
  state.page = math.max(0, state.page + delta)
end

---@param state csv.State
---@param page integer
function M.goto_page(state, page)
  state.page = math.max(0, page)
end

---@param state csv.State
function M.reset(state)
  state.where = {}
  state.order = {}
  state.selected = {}
  state.page = 0
end

return M
