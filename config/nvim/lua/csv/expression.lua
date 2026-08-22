--[[
State to moonblade.

Filters and formatting both reach xan as expressions rather than flags, so this
module owns that translation. `csv.pipeline` owns the surrounding command line.

Two rules run through everything here. String comparison uses `eq` where numeric
comparison uses `==`, and a comparison against a cell that will not cast aborts
the whole run, so anything that can fail is wrapped in `try`.
]]

local columns = require("csv.columns")

local M = {}

local NUMERIC_CONVERSION = "%%[-+ #%d%.]*[diouxXeEfgGaA]"

--- Render one filter.
---@param filter csv.Filter
---@param state csv.State
---@return string
function M.filter(filter, state)
  if filter.type == "expr" then
    return "(" .. filter.expression .. ")"
  end

  -- The marked set is read at render time rather than copied into the filter,
  -- so marking another row while the filter is on widens the view at once.
  if filter.type == "marked" then
    local rowids = {}
    for rowid in pairs(state.marked) do
      table.insert(rowids, rowid)
    end
    table.sort(rowids)

    local literals = {}
    for index, rowid in ipairs(rowids) do
      literals[index] = columns.string_literal(tostring(rowid))
    end
    return string.format(
      "(col(%s, 0) in [%s])",
      columns.string_literal(state.rowid_name),
      table.concat(literals, ", ")
    )
  end

  local column = columns.expression(filter.column)

  -- A row whose value is not a number is not a row satisfying a numeric
  -- comparison, which is what `try` turns the cast failure into.
  if filter.type == "numeric" then
    return string.format("try(%s %s %s)", column, filter.operator, filter.value)
  end

  if filter.type == "in" then
    local literals = {}
    for index, value in ipairs(filter.values) do
      literals[index] = columns.string_literal(value)
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
---@param state csv.State
---@return string
function M.where(state)
  local parts = {}
  for index, filter in ipairs(state.where) do
    parts[index] = M.filter(filter, state)
  end
  return table.concat(parts, " && ")
end

local PAD_FUNCTION = { left = "rpad", center = "pad", right = "lpad" }

--- How a column's value is written, padding included.
---@param reference string A `col(...)` call naming the column.
---@param format csv.Format
---@param header string
---@return string
function M.value(reference, format, header)
  local written = reference

  if format.spec then
    local argument = format.spec:match(NUMERIC_CONVERSION) and ("float(" .. reference .. ")") or reference
    written = string.format("printf(%s, %s)", columns.string_literal(format.spec), argument)
  elseif format.kind == "float" then
    written = string.format('printf("%%.%df", float(%s))', format.precision, reference)
  end

  if format.align then
    -- `view` sizes a column to its widest cell, so padding narrower than the
    -- header would leave the value off centre inside the drawn column.
    local width = math.max(format.width, columns.text_length(header))
    written = string.format("%s(%s, %d)", PAD_FUNCTION[format.align], written, width)
  end

  return written
end

return M
