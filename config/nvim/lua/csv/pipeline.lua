--[[
State to xan pipeline.

`xan run '<pipeline>' <file>` executes a whole pipeline in one process, so the
plugin never builds a chain of piped commands and never goes through a shell.
This module is the pure function from view state to that single pipeline string.
It is the only place that knows xan's command syntax, and it can be exercised
without nvim.

The pipeline always starts with `enum`, so a row keeps its source position
through filtering and sorting. That row id column sits at position 0 of every
downstream stage and is always addressed as `0`, never by name, so a source
column sharing its name cannot shadow it.
]]

local columns = require("csv.columns")

local M = {}

--- Quote one argument of the pipeline string, which xan splits with shlex.
---@param value string
---@return string
local function shell_quote(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

--- Render one filter as a moonblade expression.
---@param filter csv.Filter
---@return string
function M.filter_expression(filter)
  if filter.type == "expr" then
    return "(" .. filter.expression .. ")"
  end

  local column = columns.expression(filter.column)

  -- A numeric comparison against a cell that will not cast, an empty one most
  -- often, aborts the whole run. `try` makes that row falsey instead, which is
  -- what a numeric comparison means: a row whose value is not a number is not a
  -- row satisfying the comparison.
  if filter.type == "numeric" then
    return string.format("try(%s %s %s)", column, filter.operator, filter.value)
  end

  if filter.type == "in" then
    local literals = {}
    for i, value in ipairs(filter.values) do
      literals[i] = columns.string_literal(value)
    end
    return string.format("(%s in [%s])", column, table.concat(literals, ", "))
  end

  local value = columns.string_literal(filter.value)
  if filter.operator == "eq" or filter.operator == "ne" then
    return string.format("(%s %s %s)", column, filter.operator, value)
  end
  if filter.operator == "regex" then
    return string.format("match(%s, %s)", column, value)
  end
  return string.format("%s(%s, %s)", filter.operator, column, value)
end

--- Combine every filter into the single expression `xan filter` receives.
---@param where csv.Filter[]
---@return string
function M.where_expression(where)
  local parts = {}
  for i, filter in ipairs(where) do
    parts[i] = M.filter_expression(filter)
  end
  return table.concat(parts, " && ")
end

--- Sort stages, least significant key first.
--- `xan sort` applies one direction to all its keys and is stable, so a
--- multi-key sort with mixed directions is one stage per key, applied in
--- reverse order of significance.
---@param order csv.SortKey[]
---@return string[]
local function sort_stages(order)
  local stages = {}
  for i = #order, 1, -1 do
    local key = order[i]
    local stage = "sort -s " .. shell_quote(columns.selector(key.column))
    if key.numeric then
      stage = stage .. " -N"
    end
    if key.direction == "desc" then
      stage = stage .. " -R"
    end
    table.insert(stages, stage)
  end
  return stages
end

local ASCENDING = "▲"
local DESCENDING = "▼"

--- The header text each column is rendered under: its display name, carrying a
--- marker when the view is sorted by it. A multi-key sort numbers its markers,
--- so the header says which key is the most significant.
---@param selected csv.Column[]
---@param order csv.SortKey[]
---@return string[]
local function header_names(selected, order)
  local names = columns.display_names(selected)
  for position, key in ipairs(order) do
    for index, column in ipairs(selected) do
      if column.index == key.column.index then
        local arrow = key.direction == "asc" and ASCENDING or DESCENDING
        names[index] = names[index] .. " " .. arrow
        if #order > 1 then
          names[index] = names[index] .. position
        end
      end
    end
  end
  return names
end

--- The `map` stage that gives every float column its decimals.
--- Runs after `rename`, so a column is addressed by its header name, which is
--- unique. A value that will not cast falls through to its raw text rather than
--- aborting the run.
---@param selected csv.Column[]
---@param headers string[]
---@param formats table<integer, csv.Format>
---@return string|nil
local function format_stage(selected, headers, formats)
  local clauses = {}
  for index, column in ipairs(selected) do
    local format = formats[column.index]
    if format and format.kind == "float" then
      local literal = columns.string_literal(headers[index])
      local reference = string.format("col(%s)", literal)
      table.insert(clauses, string.format(
        'try(printf("%%.%df", float(%s))) || %s as %s',
        format.precision, reference, reference, literal
      ))
    end
  end

  if #clauses == 0 then
    return nil
  end
  return "map -O " .. shell_quote(table.concat(clauses, ", "))
end

--- Header names of the columns `view` should right-align. A float column needs
--- this because `printf` leaves it a string, which `view` left-aligns.
---@param selected csv.Column[]
---@param headers string[]
---@param formats table<integer, csv.Format>
---@return string|nil
local function right_aligned(selected, headers, formats)
  local names = {}
  for index, column in ipairs(selected) do
    local format = formats[column.index]
    if format and format.kind ~= "text" then
      table.insert(names, columns.quote_name(headers[index]))
    end
  end

  if #names == 0 then
    return nil
  end
  return table.concat(names, ",")
end

--- The columns the buffer shows, row id first.
---@param state csv.State
---@return csv.Column[]
local function selected_columns(state)
  local rowid = { name = state.rowid_name, nth = 0, index = -1, duplicated = false }
  local selected = { rowid }
  local source = #state.selected > 0 and state.selected or state.columns
  for _, column in ipairs(source) do
    table.insert(selected, column)
  end
  return selected
end

--- Build the argument for `xan run`.
---@param state csv.State
---@return string
function M.build(state)
  local stages = { "enum -c " .. shell_quote(state.rowid_name) }

  if #state.where > 0 then
    table.insert(stages, "filter " .. shell_quote(M.where_expression(state.where)))
  end

  for _, stage in ipairs(sort_stages(state.order)) do
    table.insert(stages, stage)
  end

  table.insert(stages, string.format("slice -s %d -l %d", state.page * state.limit, state.limit))

  local selected = selected_columns(state)
  local headers = header_names(selected, state.order)
  table.insert(stages, "select " .. shell_quote(columns.selection(selected)))
  table.insert(stages, "rename " .. shell_quote(columns.rename_argument(headers)))

  local formatting = format_stage(selected, headers, state.formats)
  if formatting then
    table.insert(stages, formatting)
  end

  -- `-e` renders every column at full width. Without it `view` fits its output
  -- to a terminal width and elides middle columns, which a scrollable buffer
  -- must not do.
  local view = "view --color never -M -I --repeat-headers never -e"
  local aligned = right_aligned(selected, headers, state.formats)
  if aligned then
    view = view .. " -r " .. shell_quote(aligned)
  end
  table.insert(stages, view)

  return table.concat(stages, " | ")
end

--- The argv for running `state` through xan.
---@param state csv.State
---@return string[]
function M.command(state)
  return { "xan", "run", M.build(state), state.source }
end

local SAMPLE_ROWS = 600
-- `sample` reads whatever it is given, so the sample is drawn from the head of
-- the file rather than from all of it.
local SAMPLE_WINDOW = 60000

--- The argv for the sample `csv.format` measures precision from. Renaming to
--- display names first makes every key unique, which the JSON objects require
--- and duplicated headers would break.
---@param path string
---@param rename_argument string
---@return string[]
function M.sample_command(path, rename_argument)
  local pipeline = table.concat({
    string.format("slice -l %d", SAMPLE_WINDOW),
    string.format("sample %d", SAMPLE_ROWS),
    "rename " .. shell_quote(rename_argument),
    "to jsonl --strings '*'",
  }, " | ")
  return { "xan", "run", pipeline, path }
end

--- The argv that lists a file's column names, one per line.
---@param path string
---@return string[]
function M.headers_command(path)
  return { "xan", "headers", "-j", path }
end

return M
