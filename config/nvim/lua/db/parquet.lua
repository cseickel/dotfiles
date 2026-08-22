--[[
Opening a parquet file.

A parquet holds nothing editable, so what opens is a duckdb query against it.
duckdb reads the file where it lies and nothing is imported. The file is named
as a view first, because a view is a table with a schema, which is what sql
completion lists.
]]

local query = require("db.query")

local M = {}

-- One database per nvim, because duckdb takes an exclusive lock on the file it
-- opens. The database lives in nvim's temp directory, which nvim removes on
-- exit.
local URL = "duckdb:" .. vim.fn.tempname() .. ".duckdb"
local SCRATCH = vim.fn.stdpath("cache") .. "/parquet"

--- `text` as a duckdb string literal.
---@param text string
---@return string
local function literal(text)
  return "'" .. text:gsub("'", "''") .. "'"
end

--- `name` as a duckdb identifier.
---@param name string
---@return string
local function identifier(name)
  return '"' .. name:gsub('"', '""') .. '"'
end

--- Names the parquet at `path` as a view in the shared database. Nil when that
--- database cannot be opened, which one duckdb process holding it is enough to
--- cause.
---@param path string
---@return string|nil name
local function define(path)
  local name = vim.fn.fnamemodify(path, ":t:r")
  local sql = string.format(
    "create or replace view %s as select * from %s;",
    identifier(name),
    literal(path)
  )
  if query.run(URL, sql) == nil then
    return nil
  end
  return name
end

--- The query that opens in place of the parquet at `path`, and the connection
--- that answers it. Without a view the file is read by path, which costs only
--- the completion the view was for.
---@param path string
---@return { url: string, lines: string[] }
local function opening(path)
  local name = define(path)
  if not name then
    return {
      url = "duckdb:",
      lines = { "select *", "from " .. literal(path), "limit 1000;" },
    }
  end
  return {
    url = URL,
    lines = { "select *", "from " .. identifier(name), "limit 1000;" },
  }
end

function M.setup()
  vim.api.nvim_create_autocmd("BufReadCmd", {
    pattern = "*.parquet",
    callback = function(event)
      local path = vim.fn.fnamemodify(event.match, ":p")

      -- The buffer is renamed before it holds any sql, so that a name already
      -- taken leaves an empty buffer rather than a parquet file one `:w` away
      -- from being overwritten.
      vim.fn.mkdir(SCRATCH, "p")
      vim.api.nvim_buf_set_name(
        event.buf,
        string.format("%s/%s.sql", SCRATCH, vim.fn.fnamemodify(path, ":t:r"))
      )

      local opened = opening(path)
      vim.api.nvim_buf_set_lines(event.buf, 0, -1, false, opened.lines)
      vim.bo[event.buf].filetype = "sql"
      -- InitSql runs on the filetype set above and assigns b:db from g:db, so
      -- the connection has to be set after it.
      vim.b[event.buf].db = opened.url
      vim.bo[event.buf].modified = false

      -- executeSqlCsv opens a window, which BufReadCmd is still in the middle
      -- of reading the buffer for.
      vim.schedule(function()
        if vim.api.nvim_get_current_buf() == event.buf then
          _G.executeSqlCsv(0)
        end
      end)
    end,
  })
end

return M
