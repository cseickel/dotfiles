--[[
View state and the actions that change it.

One state table per buffer, holding what the user asked for rather than any row
data. Every action here takes the values it needs explicitly, so it can be
called from a keymap, a command, or a test. Resolving those values from the
cursor belongs to `csv.buffer`.
]]

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

---@class csv.FilterMarked
---@field type "marked"

---@class csv.FilterExpr
---@field type "expr"
---@field expression string Hand-written moonblade.

---@alias csv.Filter csv.FilterNumeric|csv.FilterString|csv.FilterIn|csv.FilterMarked|csv.FilterExpr

---@class csv.State
---@field source string         Path of the file.
---@field sheet integer         0-based sheet being read, 0 for a source without sheets.
---@field sheets string[]       Every sheet name, empty for a source without sheets.
---@field columns csv.Column[]  Every source column, in file order.
---@field rowid_name string     Name for the prepended row id, absent from `columns`.
---@field where csv.Filter[]    ANDed together.
---@field order csv.SortKey[]   Most significant key first.
---@field selected csv.Column[] Display order. Empty means every source column.
---@field clipboard csv.Column[] Cut columns waiting to be pasted.
---@field marked table<integer, boolean> Marked row ids.
---@field marked_columns table<integer, boolean> Marked column indices.
---@field columns_filtered_to_marks boolean
---@field formats table<integer, csv.Format> Keyed by column index.
---@field page integer          0-based.
---@field limit integer         Rows per page.

---@param source csv.Source
---@return csv.State
function M.new(source)
  return {
    source = source.path,
    sheet = source.sheet,
    sheets = source.sheets,
    columns = source.columns,
    rowid_name = source.rowid_name,
    formats = source.formats,
    where = {},
    order = {},
    selected = {},
    clipboard = {},
    marked = {},
    marked_columns = {},
    columns_filtered_to_marks = false,
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

-- Sorting -------------------------------------------------------------------

--- Sort by one column alone. Asking again for the direction it already has
--- clears the sort, which is how a sort is undone.
---@param state csv.State
---@param column csv.Column
---@param direction "asc"|"desc"
function M.sort_by(state, column, direction)
  local only = #state.order == 1 and state.order[1]
  if only and only.column.index == column.index and only.direction == direction then
    state.order = {}
  else
    state.order = {
      { column = column, direction = direction, numeric = M.is_numeric(state, column) },
    }
  end
  state.page = 0
end

--- Add a less significant sort key, or change the direction of one already
--- present. Asking again for the direction it already has removes that key.
---@param state csv.State
---@param column csv.Column
---@param direction "asc"|"desc"
function M.add_sort_key(state, column, direction)
  for index, key in ipairs(state.order) do
    if key.column.index == column.index then
      if key.direction == direction then
        table.remove(state.order, index)
      else
        key.direction = direction
      end
      state.page = 0
      return
    end
  end

  table.insert(state.order, {
    column = column,
    direction = direction,
    numeric = M.is_numeric(state, column),
  })
  state.page = 0
end

---@param state csv.State
---@param column csv.Column
function M.remove_sort_key(state, column)
  for index, key in ipairs(state.order) do
    if key.column.index == column.index then
      table.remove(state.order, index)
      state.page = 0
      return
    end
  end
end

---@param state csv.State
function M.clear_sort(state)
  state.order = {}
  state.page = 0
end

-- Filters -------------------------------------------------------------------

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

-- Marks ---------------------------------------------------------------------

---@param state csv.State
---@param rowid integer
function M.toggle_mark(state, rowid)
  state.marked[rowid] = not state.marked[rowid] or nil
end

---@param state csv.State
function M.clear_marks(state)
  state.marked = {}
end

---@param state csv.State
---@param column csv.Column
function M.toggle_mark_column(state, column)
  state.marked_columns[column.index] = not state.marked_columns[column.index] or nil
end

---@param state csv.State
function M.clear_marked_columns(state)
  state.marked_columns = {}
end

--- Turn the marked-rows filter on, or off if it is already on.
---@param state csv.State
function M.toggle_marked_filter(state)
  for index, filter in ipairs(state.where) do
    if filter.type == "marked" then
      table.remove(state.where, index)
      state.page = 0
      return
    end
  end
  M.add_filter(state, { type = "marked" })
end

-- Paging --------------------------------------------------------------------

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
---@param size integer
function M.set_page_size(state, size)
  state.limit = math.max(1, size)
  state.page = 0
end

---@param state csv.State
function M.reset(state)
  state.where = {}
  state.order = {}
  state.selected = {}
  state.clipboard = {}
  state.marked = {}
  state.marked_columns = {}
  state.columns_filtered_to_marks = false
  state.page = 0
end

return M
