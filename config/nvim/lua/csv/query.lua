--[[
Asking xan about the data rather than for it.

Rendering wants a page of rows. Counting the result, listing a column's distinct
values, and summarising a column want answers. Each of those runs through the
same filters the buffer is showing, so what comes back always describes what is
on screen.

This module also owns running a xan command at all, so every caller reports a
failure the same way.
]]

local commands = require("csv.commands")

local M = {}

---@class csv.Frequency
---@field value string
---@field count integer

--- Run `argv`, handing stdout to `on_output` or the message to `on_error`.
---
--- `xan run` exits 0 even when a stage inside the pipeline fails, and lets the
--- stages after it carry on with no input, so anything on stderr is a failure
--- whatever the exit code says.
---@param argv string[]
---@param on_error fun(message: string)
---@param on_output fun(stdout: string)
function M.run(argv, on_error, on_output)
  vim.system(argv, { text = true }, vim.schedule_wrap(function(result)
    local message = vim.trim(result.stderr or "")
    if message ~= "" then
      return on_error(message)
    end
    if result.code ~= 0 then
      return on_error(argv[1] .. " exited " .. result.code)
    end
    on_output(result.stdout)
  end))
end

--- Run `argv` and decode its output as one JSON object per line.
---@param argv string[]
---@param on_error fun(message: string)
---@param on_rows fun(rows: table[])
function M.run_json_lines(argv, on_error, on_rows)
  M.run(argv, on_error, function(stdout)
    local rows = {}
    for line in stdout:gmatch("[^\r\n]+") do
      local decoded, row = pcall(vim.json.decode, line)
      if not decoded then
        return on_error("xan returned output that is not JSON")
      end
      table.insert(rows, row)
    end
    on_rows(rows)
  end)
end

--- How many rows the current filters leave.
---@param state csv.State
---@param on_error fun(message: string)
---@param on_count fun(count: integer)
function M.count(state, on_error, on_count)
  M.run(commands.count(state), on_error, function(stdout)
    local count = tonumber(vim.trim(stdout))
    if not count then
      return on_error("xan count returned " .. vim.trim(stdout))
    end
    on_count(count)
  end)
end

--- The distinct values of `column`, most frequent first.
---@param state csv.State
---@param column csv.Column
---@param on_error fun(message: string)
---@param on_values fun(values: csv.Frequency[])
function M.frequency(state, column, on_error, on_values)
  M.run_json_lines(commands.frequency(state, column), on_error, function(rows)
    local values = {}
    for index, row in ipairs(rows) do
      values[index] = { value = row.value, count = tonumber(row.count) or 0 }
    end
    on_values(values)
  end)
end

--- Every statistic xan reports, one row per column, or for `column` alone.
---@param state csv.State
---@param column csv.Column|nil
---@param on_error fun(message: string)
---@param on_stats fun(rows: table<string, string>[])
function M.stats(state, column, on_error, on_stats)
  M.run_json_lines(commands.stats(state, column), on_error, function(rows)
    if #rows == 0 then
      return on_error("xan stats returned nothing")
    end
    on_stats(rows)
  end)
end

return M
