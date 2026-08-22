--[[
Source inspection.

What the plugin must know about a file before it can render anything: the
columns it holds, a row id name that none of those columns already uses, and how
each numeric column should read. All of it comes from xan, so all of it is
asynchronous.
]]

local columns = require("csv.columns")
local format = require("csv.format")
local pipeline = require("csv.pipeline")

local M = {}

---@class csv.Source
---@field path string
---@field columns csv.Column[]
---@field rowid_name string
---@field formats table<string, csv.Format>

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

---@param argv string[]
---@param on_error fun(message: string)
---@param on_output fun(stdout: string)
local function run(argv, on_error, on_output)
  vim.system(argv, { text = true }, vim.schedule_wrap(function(result)
    if result.code ~= 0 then
      return on_error(vim.trim(result.stderr))
    end
    on_output(result.stdout)
  end))
end

--- Inspect `path` and hand back everything needed to build a pipeline for it.
---@param path string
---@param on_done fun(source: csv.Source)
---@param on_error fun(message: string)
function M.inspect(path, on_done, on_error)
  if vim.fn.executable("xan") == 0 then
    return on_error("xan is not on PATH")
  end

  run(pipeline.headers_command(path), on_error, function(stdout)
    local names = {}
    for line in stdout:gmatch("[^\r\n]+") do
      table.insert(names, line)
    end
    if #names == 0 then
      return on_error("no columns in " .. path)
    end

    local source_columns = columns.from_names(names)
    local rename = columns.rename_argument(columns.display_names(source_columns))
    local argv = pipeline.sample_command(path, rename)

    run(argv, on_error, function(sample_output)
      local sample = {}
      for line in sample_output:gmatch("[^\r\n]+") do
        local ok, row = pcall(vim.json.decode, line)
        if not ok then
          return on_error("could not read the sample of " .. path)
        end
        table.insert(sample, row)
      end

      on_done({
        path = path,
        columns = source_columns,
        rowid_name = rowid_name(names),
        formats = format.analyse(sample, source_columns),
      })
    end)
  end)
end

return M
