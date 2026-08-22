--[[
Reading `xan view` output.

`view` draws a bordered table, so the rendered text already says where every
column starts and which source row each line came from. This module turns that
text into the lookups the cursor needs, and holds nothing else.

Every lookup works from the separators on the line it is given. `view` pads
cells to display width rather than byte length, so a line holding a multi-byte
character has its separators at different byte offsets than the header, and
offsets taken from one line never describe another.

It is pure Lua and can be exercised without nvim.
]]

local M = {}

local SEPARATOR = "│"

---@class csv.Layout
---@field lines string[]    Buffer lines, borders included.
---@field header integer    Index of the header line.
---@field first_row integer Index of the first data line, past `last_row` when empty.
---@field last_row integer  Index of the last data line.
---@field rowids table<integer, integer> Source row id, keyed by line index.

---@param value string
---@return string
local function trim(value)
  return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

--- 0-based byte offset of every column separator on one line.
---@param line string
---@return integer[]
function M.separators(line)
  local offsets = {}
  local from = 1
  while true do
    local found = line:find(SEPARATOR, from, true)
    if not found then
      return offsets
    end
    table.insert(offsets, found - 1)
    from = found + #SEPARATOR
  end
end

--- The byte range cell `index` occupies on `line`, as 0-based offsets suitable
--- for an extmark. Cell 1 is the row id.
---@param line string
---@param index integer
---@return integer|nil from
---@return integer|nil to
function M.cell_bounds(line, index)
  local offsets = M.separators(line)
  if not offsets[index] or not offsets[index + 1] then
    return nil, nil
  end
  return offsets[index] + #SEPARATOR, offsets[index + 1]
end

--- The trimmed text of every cell on one line, cell 1 being the row id.
---@param line string
---@return string[]
function M.cells(line)
  local offsets = M.separators(line)
  local cells = {}
  for index = 1, #offsets - 1 do
    cells[index] = trim(line:sub(offsets[index] + #SEPARATOR + 1, offsets[index + 1]))
  end
  return cells
end

--- Which cell of `line` holds byte offset `column`, cell 1 being the row id.
---@param line string
---@param column integer 0-based byte offset, as nvim reports the cursor.
---@return integer|nil
function M.cell_at(line, column)
  local offsets = M.separators(line)
  if #offsets < 2 or column < offsets[1] or column >= offsets[#offsets] then
    return nil
  end

  for index = #offsets - 1, 1, -1 do
    if column >= offsets[index] then
      return index
    end
  end
  return nil
end

---@param line string
---@param prefix string
---@return boolean
local function starts_with(line, prefix)
  return line:sub(1, #prefix) == prefix
end

--- Read the table `xan view` drew. It pads its output with a blank line at each
--- end, and draws a top border, a header, a rule, the rows, and a bottom border.
---@param output string[]
---@return csv.Layout|nil layout
---@return string|nil error
function M.parse(output)
  local lines = {}
  for _, line in ipairs(output) do
    if trim(line) ~= "" then
      table.insert(lines, line)
    end
  end

  if #lines < 4 or not starts_with(lines[1], "─") or not starts_with(lines[3], "─") then
    return nil, "xan view did not produce a table"
  end
  -- Cut the top border
  table.remove(lines, 1)

  local layout = {
    lines = lines,
    header = 1,
    first_row = 3,
    last_row = #lines - 1,
    rowids = {},
  }

  for index = layout.first_row, layout.last_row do
    local rowid = tonumber(M.cells(lines[index])[1])
    if rowid then
      layout.rowids[index] = rowid
    end
  end

  return layout, nil
end

--- How many rows the table holds.
---@param layout csv.Layout
---@return integer
function M.row_count(layout)
  return layout.last_row - layout.first_row + 1
end

return M
