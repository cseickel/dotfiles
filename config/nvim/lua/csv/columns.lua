--[[
Column identity.

A CSV file may repeat a header name, so a name alone does not identify a column.
Every column is carried as a `csv.Column`, and this module owns the four
renderings xan needs: the selection syntax used by `select` and `sort -s`, the
moonblade form used inside filter expressions, the display name shown in the
buffer, and the `rename` argument that puts those display names on the output.
]]

local M = {}

---@class csv.Column
---@field name string     Header text exactly as it appears in the file.
---@field nth integer     0-based occurrence among columns sharing `name`.
---@field index integer   0-based position among the file's columns.
---@field duplicated boolean True when another column shares `name`.

--- Build the column list from the lines of `xan headers -j`.
---@param names string[]
---@return csv.Column[]
function M.from_names(names)
  local totals = {}
  for _, name in ipairs(names) do
    totals[name] = (totals[name] or 0) + 1
  end

  local seen = {}
  local columns = {}
  for i, name in ipairs(names) do
    local nth = seen[name] or 0
    seen[name] = nth + 1
    columns[i] = {
      name = name,
      nth = nth,
      index = i - 1,
      duplicated = totals[name] > 1,
    }
  end
  return columns
end

--- Wrap a value in double quotes, doubling any it contains.
---@param value string
---@return string
local function csv_quote(value)
  return '"' .. value:gsub('"', '""') .. '"'
end

--- Render a name as one token of a xan selection argument. `*`, `:`, `!`, `[`
--- and `]` are selection syntax, so a name containing any of them selects the
--- wrong column, or nothing, unless it is quoted.
---@param name string
---@return string
function M.quote_name(name)
  return name:match("^[%w_]+$") and name or csv_quote(name)
end

--- Render for a xan selection argument (`select`, `sort -s`, `frequency -s`).
--- The bare form of a name always resolves to its first occurrence, so the
--- `[nth]` suffix is only needed past occurrence zero.
---@param column csv.Column
---@return string
function M.selector(column)
  local base = M.quote_name(column.name)
  if column.nth == 0 then
    return base
  end
  return base .. "[" .. column.nth .. "]"
end

--- Render a comma-joined selection argument for several columns, in order.
---@param columns csv.Column[]
---@return string
function M.selection(columns)
  local parts = {}
  for i, column in ipairs(columns) do
    parts[i] = M.selector(column)
  end
  return table.concat(parts, ",")
end

--- Render a moonblade string literal.
---@param value string
---@return string
function M.string_literal(value)
  return '"' .. value:gsub("\\", "\\\\"):gsub('"', '\\"') .. '"'
end

--- Render for use inside a moonblade expression (`filter`, `map`).
--- Always the two-argument `col` form: a bare identifier would be shorter but
--- would need its own rules for names that are not valid identifiers.
---@param column csv.Column
---@return string
function M.expression(column)
  return string.format("col(%s, %d)", M.string_literal(column.name), column.nth)
end

--- The name shown to the user. Only duplicated names carry the occurrence.
---@param column csv.Column
---@return string
function M.display(column)
  if not column.duplicated then
    return column.name
  end
  return column.name .. "[" .. column.nth .. "]"
end

--- Render the argument for `xan rename`, which takes one CSV row of names
--- covering every column of its input, in order.
---@param names string[]
---@return string
function M.rename_argument(names)
  local parts = {}
  for i, name in ipairs(names) do
    parts[i] = name:match('[,"\r\n]') and csv_quote(name) or name
  end
  return table.concat(parts, ",")
end

--- The display names of `columns`, in order.
---@param columns csv.Column[]
---@return string[]
function M.display_names(columns)
  local names = {}
  for i, column in ipairs(columns) do
    names[i] = M.display(column)
  end
  return names
end

return M
