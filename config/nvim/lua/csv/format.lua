--[[
Numeric column formatting.

A CSV cell is text, so nothing in the file says how a number should read. This
module decides, from a sample of rows, which columns are numeric and how many
decimals each one needs. `csv.pipeline` turns those decisions into the `printf`
clauses that xan applies.

Precision is measured after snapping each value to seven significant digits,
because a column printed from float32 carries noise past that point: 89% of the
prices in a real file read as `199.589996338` when the number is `199.59`.
]]

local columns = require("csv.columns")

local M = {}

---@class csv.Format
---@field kind "int"|"float"|"text"
---@field precision integer Decimals to print. Zero unless `kind` is "float".
---@field width integer The longest sampled value, and the width padding uses.
---@field align "left"|"center"|"right"|nil Set only when the user chose one.
---@field spec string|nil A printf specification, replacing every other rule.

local MAX_PRECISION = 6
local SIGNIFICANT_DIGITS = 7

--- Decimals a value needs once its float noise is gone, or nil when the value
--- is not a number.
---@param value string
---@return integer|nil
function M.decimals(value)
  local number = tonumber(value)
  if not number then
    return nil
  end

  -- Round-tripping through %g drops the noise digits, and reprinting in fixed
  -- notation keeps the count right for values %g would render as `1e-05`.
  local snapped = tonumber(string.format("%." .. SIGNIFICANT_DIGITS .. "g", number))
  local fraction = string.format("%.10f", snapped):match("^%-?%d+%.(%d+)$")
  if not fraction then
    return 0
  end
  return #(fraction:gsub("0+$", ""))
end

--- The value at `fraction` through a sorted list.
---@param sorted integer[]
---@param fraction number
---@return integer
local function percentile(sorted, fraction)
  local index = math.ceil(fraction * #sorted)
  return sorted[math.max(1, math.min(index, #sorted))]
end

--- Decide how one column reads from its sampled values.
--- A single unparseable value makes the column text, so a column only formats
--- as a number when every sampled value is one.
---@param values string[]
---@return csv.Format
function M.analyse_column(values)
  local decimals = {}
  local width = 0
  local numeric = true

  for _, value in ipairs(values) do
    local length = columns.text_length(value)
    if length > width then
      width = length
    end
    if value ~= "" and numeric then
      local count = M.decimals(value)
      if count then
        table.insert(decimals, count)
      else
        numeric = false
      end
    end
  end

  if not numeric or #decimals == 0 then
    return { kind = "text", precision = 0, width = width }
  end

  table.sort(decimals)
  -- The last few values of a float32 column can need more decimals than the
  -- rest, so the high percentile keeps one row in six hundred from widening
  -- every row. Under a hundred values it resolves to the maximum, so a small
  -- file formats to whatever its widest value needs.
  local precision = percentile(decimals, 0.99)
  if precision == 0 then
    return { kind = "int", precision = 0, width = width }
  end
  return { kind = "float", precision = math.min(precision, MAX_PRECISION), width = width }
end

--- Decide how every column reads.
--- The sample arrives keyed by display name, because that is what the JSON
--- objects can express, and leaves keyed by column index, because that is what
--- identifies a column everywhere else.
---@param sample table<string, string>[] Sample rows, keyed by display name.
---@param source_columns csv.Column[]
---@return table<integer, csv.Format>
function M.analyse(sample, source_columns)
  local formats = {}
  for _, column in ipairs(source_columns) do
    local name = columns.display(column)
    local values = {}
    for index, row in ipairs(sample) do
      local value = row[name]
      values[index] = type(value) == "string" and value or ""
    end
    formats[column.index] = M.analyse_column(values)
  end
  return formats
end

--- The format for `column`, creating a plain one if the sample never saw it.
---@param formats table<integer, csv.Format>
---@param column csv.Column
---@return csv.Format
local function entry(formats, column)
  local format = formats[column.index]
  if not format then
    format = { kind = "text", precision = 0, width = 0 }
    formats[column.index] = format
  end
  return format
end

--- The side a column's values sit on when the user has not chosen one.
---@param format csv.Format
---@return "left"|"right"
local function natural_align(format)
  return format.kind == "text" and "left" or "right"
end

---@param formats table<integer, csv.Format>
---@param column csv.Column
---@param align "left"|"center"|"right"
function M.set_align(formats, column, align)
  entry(formats, column).align = align
end

--- Show more or fewer decimals. Asking for decimals on a column read as text
--- makes it a float, since that is what the request means.
---@param formats table<integer, csv.Format>
---@param column csv.Column
---@param delta integer
function M.adjust_precision(formats, column, delta)
  local format = entry(formats, column)
  format.precision = math.max(0, math.min(format.precision + delta, MAX_PRECISION))
  format.kind = format.precision > 0 and "float" or "int"
end

--- Use a printf specification instead of every other formatting rule. An empty
--- specification returns the column to the detected format.
---@param formats table<integer, csv.Format>
---@param column csv.Column
---@param spec string
function M.set_spec(formats, column, spec)
  entry(formats, column).spec = spec ~= "" and spec or nil
end

--- Widen or narrow the padding. Padding needs a side to pad towards, so this
--- also settles the alignment when the user has not chosen one.
---@param formats table<integer, csv.Format>
---@param column csv.Column
---@param delta integer
function M.adjust_width(formats, column, delta)
  local format = entry(formats, column)
  format.width = math.max(1, format.width + delta)
  format.align = format.align or natural_align(format)
end

return M
