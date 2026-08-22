--[[
Running a dadbod query outside dadbod.

`:DB` renders results into its own buffer. This module runs the same query
through the database's own client instead, asking it for delimited text, so the
result opens as a table.
]]

local M = {}

---@param url string A dadbod connection url.
---@return string
local function scheme(url)
  return (url:match("^(%a[%w+.-]*):") or ""):lower()
end

--- The file a `scheme:path` url names, empty for an in-memory database.
---@param url string
---@return string
local function filePath(url)
  local path = url:gsub("^%a[%w+.-]*:", ""):gsub("^//", "")
  return vim.fn.expand(path)
end

--- What the mysql client needs to connect, which is not a url.
---@param url string mysql://user:password@host:port/database
---@return { arguments: string[], env: table<string, string>|nil }
local function mysqlConnection(url)
  local rest = url:gsub("^mysql://", "")
  local credentials, location = rest:match("^(.-)@(.*)$")
  if not location then
    credentials, location = "", rest
  end
  local user, password = credentials:match("^([^:]*):?(.*)$")
  local host, port, database = location:match("^([^:/]*):?(%d*)/?(.*)$")

  local arguments = {}
  local function add(flag, value)
    if value ~= "" then
      vim.list_extend(arguments, { flag, value })
    end
  end
  add("-h", host)
  add("-P", port)
  add("-u", user)
  if database ~= "" then
    table.insert(arguments, database)
  end

  return {
    arguments = arguments,
    env = password ~= "" and { MYSQL_PWD = password } or nil,
  }
end

--- How to ask `url`'s client to run `sql` and write the rows to stdout. The
--- extension names the delimiter that client writes with.
---@param url string
---@param sql string
---@return { argv: string[], extension: string, env: table<string, string>|nil }|nil
function M.command(url, sql)
  local kind = scheme(url)

  if kind == "postgres" or kind == "postgresql" then
    local copy = "COPY (\n" .. sql .. "\n) TO STDOUT WITH (FORMAT csv, HEADER)"
    return {
      argv = { "psql", url, "-v", "ON_ERROR_STOP=1", "-c", copy },
      extension = "csv",
    }
  end

  if kind == "duckdb" then
    local argv = { "duckdb" }
    local path = filePath(url)
    if path ~= "" then
      table.insert(argv, path)
    end
    -- `COPY ... TO '/dev/stdout'` reopens stdout, which fails when the caller
    -- gives the process a socket rather than a file.
    vim.list_extend(argv, { "-csv", "-header", "-c", sql })
    return { argv = argv, extension = "csv" }
  end

  if kind == "sqlite" then
    return {
      argv = { "sqlite3", "-csv", "-header", filePath(url), sql },
      extension = "csv",
    }
  end

  if kind == "mysql" then
    local connection = mysqlConnection(url)
    local argv = { "mysql", "--batch" }
    vim.list_extend(argv, connection.arguments)
    vim.list_extend(argv, { "-e", sql })
    -- The password goes in the environment because a command line is readable
    -- by every process on the machine.
    return { argv = argv, extension = "tsv", env = connection.env }
  end

  return nil
end

--- Runs `sql` against `url`, returning what the client wrote and the extension
--- naming the delimiter it wrote with. Nil for a failure, already reported.
---@param url string
---@param sql string
---@return string|nil output
---@return string extension
function M.run(url, sql)
  local command = M.command(url, sql)
  if not command then
    vim.notify("no client known for " .. url, vim.log.levels.ERROR)
    return nil, ""
  end

  local result = vim.system(command.argv, { text = true, env = command.env }):wait()
  if result.code ~= 0 then
    vim.notify(vim.trim(result.stderr or "query failed"), vim.log.levels.ERROR)
    return nil, ""
  end

  return result.stdout or "", command.extension
end

--- Runs `sql` against `url` and writes the rows to a temporary file named for
--- the delimiter they are written with.
---@param url string
---@param sql string
---@return string|nil path
function M.write(url, sql)
  local output, extension = M.run(url, sql)
  if not output then
    return nil
  end

  local path = vim.fn.tempname() .. "." .. extension
  local file = io.open(path, "w")
  if not file then
    vim.notify("could not write " .. path, vim.log.levels.ERROR)
    return nil
  end
  file:write(output)
  file:close()
  return path
end

return M
