--[[
Source inspection.

What the plugin must know about a file before it can render anything: the
columns it holds, a row id name that none of those columns already uses, and how
each numeric column should read. All of it comes from xan, so all of it is
asynchronous.
]]

local columns = require("csv.columns")
local commands = require("csv.commands")
local format = require("csv.format")
local query = require("csv.query")

local M = {}

---@class csv.Source
---@field path string
---@field columns csv.Column[]
---@field rowid_name string
---@field formats table<string, csv.Format>
---@field sheet integer   0-based index of the sheet read, 0 for a source without sheets.
---@field sheets string[] Every sheet name, empty for a source without sheets.

--- A name for the row id column that no source column already holds. `enum`
--- prepends its column before `select` runs, so a collision would make a bare
--- source name select the row id instead.
---@param names string[]
---@return string
local function rowid_name(names)
  local taken = {}
  for _, name in ipairs(names) do
    taken[name] = true
  end

  local candidate = "row"
  while taken[candidate] do
    candidate = candidate .. "_"
  end
  return candidate
end

--- The lines of `stdout`, blank ones included. A sheet may hold an empty header
--- cell, which xan prints as a blank line and which is a real column, so
--- skipping blank lines would report fewer columns than the sheet has.
---@param stdout string
---@return string[]
local function lines_of(stdout)
  local lines = vim.split(stdout, "\n", { plain = true })
  if lines[#lines] == "" then
    table.remove(lines)
  end
  return lines
end

--- Inspect one sheet of `path` and hand back everything needed to build a
--- pipeline for it.
---@param path string
---@param sheet integer 0-based, ignored by a source without sheets.
---@param sheets string[] Every sheet name, already listed.
---@param on_done fun(source: csv.Source)
---@param on_error fun(message: string)
local function inspect_sheet(path, sheet, sheets, on_done, on_error)
  query.run(commands.headers(path, sheet), on_error, function(stdout)
    local names = lines_of(stdout)
    if #names == 0 then
      return on_error("no columns in " .. path)
    end

    local source_columns = columns.from_names(names)
    local rename = columns.rename_argument(columns.display_names(source_columns))

    query.run_json_lines(commands.sample(path, sheet, rename), on_error, function(sample)
      on_done({
        path = path,
        columns = source_columns,
        rowid_name = rowid_name(names),
        formats = format.analyse(sample, source_columns),
        sheet = sheet,
        sheets = sheets,
      })
    end)
  end)
end

--- Inspect `path` and hand back everything needed to build a pipeline for it.
---@param path string
---@param sheet integer|nil 0-based, defaulting to the first sheet.
---@param on_done fun(source: csv.Source)
---@param on_error fun(message: string)
function M.inspect(path, sheet, on_done, on_error)
  if vim.fn.executable("xan") == 0 then
    return on_error("xan is not on PATH")
  end

  sheet = sheet or 0
  if not commands.has_sheets(path) then
    return inspect_sheet(path, sheet, {}, on_done, on_error)
  end

  query.run(commands.sheets(path), on_error, function(stdout)
    inspect_sheet(path, sheet, lines_of(stdout), on_done, on_error)
  end)
end

return M
