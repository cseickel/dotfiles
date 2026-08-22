--[[
Everything a key can do.

Each action carries the sentence that describes it, so the help panel is
generated from this table and cannot drift from the bindings. An action reads
whatever it needs from the cursor, changes the state, and asks for a repaint.

The actions that act on a column live in `csv.column_actions` and are merged in
here, so a key still finds every action in one table.
]]

local buffer = require("csv.buffer")
local column_actions = require("csv.column_actions")
local cursor = require("csv.cursor")
local dialog = require("csv.dialog")
local panel = require("csv.panel")
local query = require("csv.query")
local selection = require("csv.selection")
local state = require("csv.state")

local M = {}

---@class csv.Action
---@field description string
---@field run fun(buf: csv.Buffer)

---@param message string
local function report(message)
  vim.notify("csv: " .. message, vim.log.levels.ERROR)
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

---@param description string
---@param run fun(buf: csv.Buffer)
---@return csv.Action
local function action(description, run)
  return { description = description, run = run }
end

---@param direction "asc"|"desc"
---@return fun(buf: csv.Buffer)
local function sorter(direction)
  return function(buf)
    on_column(buf, function(column)
      state.sort_by(buf.state, column, direction)
    end)
  end
end

---@param direction "asc"|"desc"
---@return fun(buf: csv.Buffer)
local function keyer(direction)
  return function(buf)
    on_column(buf, function(column)
      state.add_sort_key(buf.state, column, direction)
    end)
  end
end

---@type table<string, csv.Action>
M.actions = {
  sort_asc = action("Sort by this column ascending, or clear that sort", sorter("asc")),
  sort_desc = action("Sort by this column descending, or clear that sort", sorter("desc")),
  add_sort_key_asc = action("Add this column to the sort, ascending", keyer("asc")),
  add_sort_key_desc = action("Add this column to the sort, descending", keyer("desc")),

  remove_sort_key = action("Drop this column from the sort", function(buf)
    on_column(buf, function(column)
      state.remove_sort_key(buf.state, column)
    end)
  end),

  clear_sort = action("Clear the sort entirely", function(buf)
    state.clear_sort(buf.state)
    buffer.render(buf)
  end),

  toggle_mark_row = action("Mark or unmark this row", function(buf)
    local rowid = cursor.rowid_at(buf, 0)
    if not rowid then
      return
    end
    state.toggle_mark(buf.state, rowid)
    buffer.render(buf)
  end),

  toggle_mark_column = action("Mark or unmark this column", function(buf)
    on_column(buf, function(column)
      state.toggle_mark_column(buf.state, column)
    end)
  end),

  clear_marks = action("Clear every marked row and column", function(buf)
    state.clear_marks(buf.state)
    state.clear_marked_columns(buf.state)
    buffer.render(buf)
  end),

  filter_to_marked_rows = action("Show only marked rows, or stop doing so", function(buf)
    state.toggle_marked_filter(buf.state)
    buffer.render(buf)
  end),

  filter_to_marked_columns = action("Show only marked columns, or stop doing so", function(buf)
    selection.toggle_marked_columns(buf.state)
    buffer.render(buf)
  end),

  filter_to_marked_both = action("Show only marked rows and marked columns", function(buf)
    selection.toggle_marked_columns(buf.state)
    state.toggle_marked_filter(buf.state)
    buffer.render(buf)
  end),

  filter = action("Filter on this column", function(buf)
    local column = cursor.column_at(buf, 0)
    if column then
      dialog.open(buf, column)
    end
  end),

  pop_filter = action("Drop the filter added last", function(buf)
    state.pop_filter(buf.state)
    buffer.render(buf)
  end),

  clear_filters = action("Drop every filter", function(buf)
    state.clear_filters(buf.state)
    buffer.render(buf)
  end),

  next_page = action("Show the next page", function(buf)
    if buffer.at_last_page(buf) then
      return vim.notify("csv: last page", vim.log.levels.INFO)
    end
    state.turn_page(buf.state, 1)
    buffer.render(buf)
  end),

  prev_page = action("Show the previous page", function(buf)
    state.turn_page(buf.state, -1)
    buffer.render(buf)
  end),

  first_page = action("Show the first page", function(buf)
    state.goto_page(buf.state, 0)
    buffer.render(buf)
  end),

  last_page = action("Show the last page", function(buf)
    query.count(buf.state, report, function(count)
      state.goto_page(buf.state, math.ceil(count / buf.state.limit) - 1)
      buffer.render(buf)
    end)
  end),

  set_page_size = action("Choose how many rows a page holds", function(buf)
    vim.ui.input({ prompt = "Rows per page: ", default = tostring(buf.state.limit) }, function(answer)
      local size = tonumber(answer)
      if not size then
        return
      end
      state.set_page_size(buf.state, math.floor(size))
      buffer.render(buf)
    end)
  end),

  show_stats = action("Summarise this column", function(buf)
    local column = cursor.column_at(buf, 0)
    if column then
      panel.stats(buf, column)
    end
  end),

  show_sheets = action("Choose which sheet to read", function(buf)
    dialog.sheets(buf)
  end),

  show_help = action("List every key", function()
    panel.help()
  end),

  show_info = action("Describe this file and the current view", function(buf)
    panel.info(buf)
  end),

  refresh = action("Read the file again", function(buf)
    buffer.render(buf)
  end),

  clear_all = action("Clear filters, sort, marks and hidden columns", function(buf)
    state.reset(buf.state)
    buffer.render(buf)
  end),
}

for name, described in pairs(column_actions.actions) do
  M.actions[name] = described
end

return M
