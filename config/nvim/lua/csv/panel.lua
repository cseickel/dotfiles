--[[
The read-only floats: help, file information, and column statistics.

Help is generated from the keymap table and the descriptions on the actions, so
a binding that changes cannot leave its documentation behind. Information and
statistics are drawn through the filters currently applied, so they describe the
rows on screen rather than the file on disk.
]]

local columns = require("csv.columns")
local keymaps = require("csv.keymaps")
local query = require("csv.query")
local selection = require("csv.selection")
local window = require("csv.window")

local M = {}

local STAT_FIELDS = {
  "type", "count", "count_empty", "cardinality",
  "min", "max", "mean", "median", "stddev", "mode",
}

---@param message string
local function report(message)
  vim.notify("csv: " .. message, vim.log.levels.ERROR)
end

--- Every binding, grouped by the action it runs, longest key first so the
--- columns line up.
---@return string[]
function M.help_lines()
  local actions = require("csv.actions").actions

  local rows = {}
  local width = 0
  for key, name in pairs(keymaps.map) do
    local described = actions[name]
    if described then
      table.insert(rows, { key = key, description = described.description })
      width = math.max(width, #key)
    end
  end
  table.sort(rows, function(left, right)
    return left.description < right.description
  end)

  local lines = {}
  for index, row in ipairs(rows) do
    lines[index] = string.format("  %-" .. width .. "s   %s", row.key, row.description)
  end
  return lines
end

function M.help()
  window.split(M.help_lines(), { title = "csv keys" })
end

--- How the current filters and sort read as sentences.
---@param buf csv.Buffer
---@return string[]
local function view_lines(buf)
  local lines = {}

  if #buf.state.where == 0 then
    table.insert(lines, "  no filters")
  end
  for _, filter in ipairs(buf.state.where) do
    if filter.type == "marked" then
      table.insert(lines, "  marked rows only")
    elseif filter.type == "expr" then
      table.insert(lines, "  " .. filter.expression)
    elseif filter.type == "in" then
      table.insert(lines, string.format(
        "  %s is one of %s",
        columns.display(filter.column),
        table.concat(filter.values, ", ")
      ))
    else
      table.insert(lines, string.format(
        "  %s %s %s",
        columns.display(filter.column),
        filter.operator,
        filter.value
      ))
    end
  end

  table.insert(lines, "")
  if #buf.state.order == 0 then
    table.insert(lines, "  no sort")
  end
  for position, key in ipairs(buf.state.order) do
    table.insert(lines, string.format(
      "  %d. %s %s",
      position,
      columns.display(key.column),
      key.direction == "asc" and "ascending" or "descending"
    ))
  end

  return lines
end

--- One line per column: how it is read, how it is shown, and what is in it.
--- The statistics arrive in column order rather than by name, because two
--- columns may share a name and `field` would then describe both.
---@param buf csv.Buffer
---@param stats table<string, string>[] One row per column, row id column first.
---@return string[]
local function column_lines(buf, stats)
  local lines = { string.format(
    "  %-24s %-6s %-4s %-8s %12s %12s %12s %10s",
    "column", "kind", "dec", "align", "min", "max", "mean", "distinct"
  ) }

  for _, column in ipairs(selection.selected(buf.state)) do
    local name = columns.display(column)
    local format = buf.state.formats[column.index] or { kind = "text", precision = 0 }
    local summary = stats[column.index + 2] or {}
    table.insert(lines, string.format(
      "  %-24s %-6s %-4d %-8s %12s %12s %12s %10s",
      name,
      format.kind,
      format.precision,
      format.align or "auto",
      summary.min or "",
      summary.max or "",
      summary.mean and summary.mean:sub(1, 12) or "",
      summary.cardinality or ""
    ))
  end

  return lines
end

--- Describe the file and the view over it.
---@param buf csv.Buffer
function M.info(buf)
  query.count(buf.state, report, function(count)
    query.stats(buf.state, nil, report, function(stats)
      local pages = math.max(math.ceil(count / buf.state.limit), 1)
      local lines = {
        "  " .. buf.state.source,
        string.format("  %d rows, %d columns, page %d of %d",
          count, #buf.state.columns, buf.state.page + 1, pages),
        "",
      }
      vim.list_extend(lines, view_lines(buf))
      table.insert(lines, "")
      vim.list_extend(lines, column_lines(buf, stats))

      window.open(lines, { title = "csv info" })
    end)
  end)
end

--- Every statistic xan reports for one column.
---@param buf csv.Buffer
---@param column csv.Column
function M.stats(buf, column)
  query.stats(buf.state, column, report, function(rows)
    local summary = rows[1]
    local lines = {}
    for _, field in ipairs(STAT_FIELDS) do
      if summary[field] then
        table.insert(lines, string.format("  %-14s %s", field, summary[field]))
      end
    end
    window.open(lines, { title = columns.display(column) })
  end)
end

return M
