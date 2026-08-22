--[[
The argv that runs xan.

`csv.pipeline` says which stages a view needs. This module says how to run them:
`xan run '<stages>' <path>`, one process, no shell and no pipes.

A source that is not already CSV gets a `from` stage in front of everything
else, so every other stage sees CSV whatever the file on disk holds.
]]

local columns = require("csv.columns")
local pipeline = require("csv.pipeline")

local M = {}

--- Formats `xan from` reads that hold more than one table.
local SHEETED = { xls = true, xlsx = true, xlsb = true, ods = true }

local SAMPLE_ROWS = 600
-- `sample` reads whatever it is given, so the sample is drawn from the head of
-- the file rather than from all of it.
local SAMPLE_WINDOW = 60000

---@param path string
---@return string
local function extension(path)
  return (path:match("%.([%w]+)$") or ""):lower()
end

--- Whether `path` names a workbook, which is the only kind of source that has
--- sheets to choose between.
---@param path string
---@return boolean
function M.has_sheets(path)
  return SHEETED[extension(path)] == true
end

--- The stage that turns a source into CSV, absent when it already is one.
--- `xan from` infers the format from the extension, so it is never named.
---@param path string
---@param sheet integer|nil 0-based, for a workbook.
---@return string|nil
local function source_stage(path, sheet)
  local suffix = extension(path)
  if suffix == "csv" or suffix == "tsv" then
    return nil
  end
  if M.has_sheets(path) then
    return string.format("from --sheet-index %d", sheet or 0)
  end
  return "from"
end

--- The argv running `stages` against `path`, reading it as CSV first if it is
--- not already CSV.
---@param path string
---@param sheet integer|nil
---@param stages string The pipeline, already joined.
---@return string[]
local function run(path, sheet, stages)
  local from = source_stage(path, sheet)
  if from then
    stages = from .. " | " .. stages
  end
  return { "xan", "run", stages, path }
end

--- The argv for running `state` through xan.
---@param state csv.State
---@return string[]
function M.render(state)
  return run(state.source, state.sheet, pipeline.build(state))
end

--- The argv for the sample `csv.format` measures precision from. Renaming to
--- display names first makes every key unique, which the JSON objects require
--- and duplicated headers would break.
---@param path string
---@param sheet integer|nil
---@param rename_argument string
---@return string[]
function M.sample(path, sheet, rename_argument)
  return run(path, sheet, table.concat({
    string.format("slice -l %d", SAMPLE_WINDOW),
    string.format("sample %d", SAMPLE_ROWS),
    "rename " .. pipeline.quote(rename_argument),
    "to jsonl --strings '*'",
  }, " | "))
end

--- The argv that lists a file's column names, one per line.
---@param path string
---@param sheet integer|nil
---@return string[]
function M.headers(path, sheet)
  return run(path, sheet, "headers -j")
end

--- The argv that names every sheet in a workbook, one per line.
---@param path string
---@return string[]
function M.sheets(path)
  return { "xan", "from", "--list-sheets", path }
end

---@param state csv.State
---@param stage string
---@return string[]
local function narrowed(state, stage)
  local stages = pipeline.narrowing_stages(state)
  table.insert(stages, stage)
  return run(state.source, state.sheet, table.concat(stages, " | "))
end

--- The argv counting the rows the current filters leave.
---@param state csv.State
---@return string[]
function M.count(state)
  return narrowed(state, "count")
end

--- The argv listing the distinct values of `column` among the rows the current
--- filters leave, as one JSON object per value, most frequent first.
---@param state csv.State
---@param column csv.Column
---@return string[]
function M.frequency(state, column)
  local selector = pipeline.quote(columns.selector(column))
  return narrowed(state, "frequency -s " .. selector .. " -A | to jsonl --strings '*'")
end

--- The argv summarising the rows the current filters leave, one JSON object per
--- column, or per every column when `column` is absent.
---@param state csv.State
---@param column csv.Column|nil
---@return string[]
function M.stats(state, column)
  local stage = "stats -A"
  if column then
    stage = stage .. " -s " .. pipeline.quote(columns.selector(column))
  end
  return narrowed(state, stage .. " | to jsonl --strings '*'")
end

return M
