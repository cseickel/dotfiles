--[[
Running a dadbod query outside dadbod.

`:DB` renders results into its own buffer once the client has exited. This
module runs the query through the database's own client instead, in one of two
shapes. A single row-returning statement is asked for as delimited text, so the
result opens as a table. Anything else runs as a script, and the client's own
transcript is read as it is written.

Only psql has a script mode worth the name, echoing each statement and
reporting its row count and duration. Every other client is handed the script
unchanged and prints whatever it prints.
]]

local M = {}

---@alias db.Mode "export"|"script"

---@class db.Command
---@field argv string[]
---@field extension string
---@field env table<string, string>|nil
---@field stdin string|nil
---@field sessionFile string|nil Where the client writes the server session it holds, absent for a client that is the database rather than a client of one.

---@class db.Run
---@field job vim.SystemObj
---@field cancel fun() Stops the query, through the server wherever there is one to ask.

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

--- A script command, whose output is the client's own transcript rather than
--- rows in a delimited format.
---@param command { argv: string[], stdin: string|nil, env: table<string, string>|nil }
---@return db.Command
local function script(command)
  return {
    argv = command.argv,
    extension = "log",
    stdin = command.stdin,
    env = command.env,
  }
end

--- `sql` without the semicolon and space that end it.
---@param sql string
---@return string
local function stripTerminator(sql)
  return (sql:gsub(";%s*$", ""))
end

--- `sql` without the comments it opens with, so the statement keyword is
--- first.
---@param sql string
---@return string
local function uncommented(sql)
  local head = sql
  while true do
    local rest = head:gsub("^%s*%-%-[^\n]*\n", ""):gsub("^%s*/%*.-%*/", "")
    if rest == head then
      return head
    end
    head = rest
  end
end

-- Statements whose result is the table the csv export carries.
local ROW_SOURCES = { select = true, ["with"] = true, table = true, values = true }

-- A CTE ending in one of these writes rows instead of returning them, and
-- Postgres refuses to put it inside COPY.
local WRITES = { "insert", "update", "delete", "merge" }

--- Whether `sql` is the single row-returning statement the csv export can
--- carry, or a script to be run for its transcript. A semicolon inside a
--- string literal reads as a second statement, which costs the table and
--- gives the transcript instead.
---@param sql string
---@return db.Mode
function M.mode(sql)
  local body = stripTerminator(sql)
  if body:find(";", 1, true) then
    return "script"
  end

  local head = uncommented(body)
  local first = (head:match("^%s*(%a+)") or ""):lower()
  if not ROW_SOURCES[first] then
    return "script"
  end

  if first == "with" then
    local lowered = body:lower()
    for _, word in ipairs(WRITES) do
      if lowered:find("%f[%w_]" .. word .. "%f[^%w_]") then
        return "script"
      end
    end
  end
  return "export"
end

--- Tells psql to put the backend pid in `file` rather than in its output, so
--- neither the transcript nor the rows have to be picked apart to find it.
--- `echoing` says whether the statement echo has to be turned off around it
--- and back on afterwards, which script mode needs and export mode must not
--- do, since export mode never turned it on.
---@param file string
---@param echoing boolean
---@return string
local function backendPid(file, echoing)
  local lines = { "\\o '" .. file .. "'", "SELECT pg_backend_pid();", "\\o" }
  if echoing then
    table.insert(lines, 1, "\\set ECHO none")
    table.insert(lines, "\\set ECHO queries")
  end
  return table.concat(lines, "\n") .. "\n"
end

--- How to ask `url`'s client to run `sql`. In export mode the client writes
--- delimited rows to stdout and the extension names the delimiter it wrote
--- with. In script mode it writes its own transcript.
---@param url string
---@param sql string
---@param mode db.Mode
---@return db.Command|nil
function M.command(url, sql, mode)
  local kind = scheme(url)

  if kind == "postgres" or kind == "postgresql" then
    -- --no-psqlrc leaves this module the only thing shaping the output.
    local argv = { "psql", url, "-w", "--no-psqlrc", "-v", "ON_ERROR_STOP=1" }
    local sessionFile = vim.fn.tempname() .. ".pid"

    if mode == "script" then
      -- -e echoes each statement before it runs, so the row count and the
      -- duration underneath it are labelled by the statement they belong to.
      vim.list_extend(argv, { "-e", "-f", "-" })
      return {
        argv = argv,
        extension = "log",
        sessionFile = sessionFile,
        -- The trailing semicolon is separated from the last statement because
        -- a script may end inside a line comment, which would swallow it.
        stdin = backendPid(sessionFile, true) .. "\\timing on\n" .. sql .. "\n;\n",
      }
    end

    -- -q keeps psql's command tags out of the rows.
    vim.list_extend(argv, { "-q", "-f", "-" })
    local copy = "COPY (\n" .. stripTerminator(sql) .. "\n) TO STDOUT WITH (FORMAT csv, HEADER)"
    return {
      argv = argv,
      extension = "csv",
      sessionFile = sessionFile,
      stdin = backendPid(sessionFile, false) .. copy .. "\n;\n",
    }
  end

  if kind == "duckdb" then
    local argv = { "duckdb" }
    local path = filePath(url)
    if path ~= "" then
      table.insert(argv, path)
    end
    if mode == "script" then
      return script({ argv = vim.list_extend(argv, { "-c", sql }) })
    end
    -- `COPY ... TO '/dev/stdout'` reopens stdout, which fails when the caller
    -- gives the process a socket rather than a file.
    vim.list_extend(argv, { "-csv", "-header", "-c", sql })
    return { argv = argv, extension = "csv" }
  end

  if kind == "sqlite" then
    local path = filePath(url)
    if mode == "script" then
      return script({ argv = { "sqlite3", path, sql } })
    end
    return {
      argv = { "sqlite3", "-csv", "-header", path, sql },
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
    if mode == "script" then
      return script({ argv = argv, env = connection.env })
    end
    return { argv = argv, extension = "tsv", env = connection.env }
  end

  return nil
end

-- How to ask a server to stop the query running in one of its own sessions.
-- Absent for a client that is the database rather than a client of one, which
-- has no session to name and no second connection to ask on.
local CANCELS = {
  postgres = function(url, pid)
    return {
      "psql",
      url,
      "-w",
      "--no-psqlrc",
      "-q",
      "-c",
      "SELECT pg_cancel_backend(" .. pid .. ")",
    }
  end,
}
CANCELS.postgresql = CANCELS.postgres

--- The server session recorded in `file`, nil while the client has yet to
--- write one.
---@param file string
---@return integer|nil
local function recorded(file)
  local handle = io.open(file, "r")
  if not handle then
    return nil
  end
  local text = handle:read("*a")
  handle:close()
  return tonumber(text:match("%d+"))
end

--- Asks `url`'s server to cancel the query running in the session recorded in
--- `file`. False when there is no server to ask or no session recorded yet, so
--- the caller can fall back to interrupting the client.
---@param url string
---@param file string
---@return boolean asked
function M.cancel(url, file)
  local build = CANCELS[scheme(url)]
  if not build then
    return false
  end
  local pid = recorded(file)
  if not pid then
    return false
  end

  -- Nothing waits on this. The client being cancelled reports the outcome in
  -- the pane, which is where the reader is already looking.
  vim.system(build(url, pid), { detach = true })
  return true
end

--- How the query `job` is running gets stopped: by asking the server when
--- there is one holding a session we know of, and by interrupting the client
--- when there is not.
---@param url string
---@param command db.Command
---@param job vim.SystemObj
---@return db.Run
local function runOf(url, command, job)
  return {
    job = job,
    cancel = function()
      if not (command.sessionFile and M.cancel(url, command.sessionFile)) then
        job:kill("sigint")
      end
    end,
  }
end

--- How to run `sql`, or nil for a url no client is known for, already
--- reported.
---@param url string
---@param sql string
---@param mode db.Mode
---@return db.Command|nil
local function commandFor(url, sql, mode)
  local command = M.command(url, sql, mode)
  if not command then
    vim.notify("no client known for " .. url, vim.log.levels.ERROR)
  end
  return command
end

--- Waits for `command` and returns what the client wrote. Nil for a failure,
--- already reported.
---@param command db.Command
---@return string|nil
local function execute(command)
  local result = vim.system(command.argv, {
    text = true,
    env = command.env,
    stdin = command.stdin,
  }):wait()
  if result.code ~= 0 then
    vim.notify(vim.trim(result.stderr or "query failed"), vim.log.levels.ERROR)
    return nil
  end
  return result.stdout or ""
end

--- `argument` as one word of a `sh -c` command line.
---@param argument string
---@return string
local function quoted(argument)
  return "'" .. argument:gsub("'", "'\\''") .. "'"
end

--- `argv` as a command line whose output is one stream, read a line at a time.
--- The client's errors are on stderr and its results on stdout, and only one
--- pipe keeps an error under the statement that caused it. `exec` leaves the
--- client holding the shell's own pid, so a signal reaches the client.
---@param argv string[]
---@return string[]
local function merged(argv)
  local words = {}
  for _, argument in ipairs(argv) do
    table.insert(words, quoted(argument))
  end
  local line = table.concat(words, " ")
  -- Clients block buffer their output when it is not a terminal, and a long
  -- script would then show nothing until it had finished.
  if vim.fn.executable("stdbuf") == 1 then
    line = "stdbuf -oL " .. line
  end
  return { "sh", "-c", "exec " .. line .. " 2>&1" }
end

--- Runs `sql` against `url` as a script and waits for it, returning the
--- transcript. Nil for a failure, already reported.
---@param url string
---@param sql string
---@return string|nil
function M.run(url, sql)
  local command = commandFor(url, sql, "script")
  if not command then
    return nil
  end
  return execute(command)
end

--- The temporary file holding the rows `result` carries, named for the
--- delimiter the client wrote them with. Nil for a failure, already reported.
---@param result vim.SystemCompleted
---@param extension string
---@return string|nil path
local function written(result, extension)
  if result.code ~= 0 then
    vim.notify(vim.trim(result.stderr or "query failed"), vim.log.levels.ERROR)
    return nil
  end

  local path = vim.fn.tempname() .. "." .. extension
  local file = io.open(path, "w")
  if not file then
    vim.notify("could not write " .. path, vim.log.levels.ERROR)
    return nil
  end
  file:write(result.stdout or "")
  file:close()
  return path
end

--- Runs `sql` against `url` and writes the rows to a temporary file, handing
--- `on_done` its path once they are all there. `on_done` runs on the main loop
--- and takes nil for a failure, already reported. Nil for a url no client is
--- known for, also already reported.
---@param url string
---@param sql string
---@param on_done fun(path: string|nil)
---@return db.Run|nil
function M.write(url, sql, on_done)
  local command = commandFor(url, sql, "export")
  if not command then
    return nil
  end

  local job = vim.system(command.argv, {
    text = true,
    env = command.env,
    stdin = command.stdin,
    -- Detached, so the client leads its own process group. A client that
    -- shares nvim's group can be reached by a signal aimed at the group, and
    -- these clients are signalled to cancel them.
    detach = true,
  }, function(result)
    vim.schedule(function()
      on_done(written(result, command.extension))
    end)
  end)

  return runOf(url, command, job)
end

--- Runs `sql` against `url` as a script, handing each piece of the transcript
--- to `handlers.on_output` as the client writes it and the exit code to
--- `handlers.on_exit`. Both run on the main loop. Nil for a url no client is
--- known for, already reported.
---@param url string
---@param sql string
---@param handlers { on_output: fun(text: string), on_exit: fun(code: integer) }
---@return db.Run|nil
function M.stream(url, sql, handlers)
  local command = commandFor(url, sql, "script")
  if not command then
    return nil
  end

  -- vim.system reads the pipe in a fast event context, where most of the api
  -- is unavailable.
  local function forward(_, data)
    if data then
      vim.schedule(function()
        handlers.on_output(data)
      end)
    end
  end

  local job = vim.system(merged(command.argv), {
    text = true,
    env = command.env,
    stdin = command.stdin,
    stdout = forward,
    -- Detached, so the client leads its own process group. A client that
    -- shares nvim's group can be reached by a signal aimed at the group, and
    -- these clients are signalled to cancel them.
    detach = true,
  }, function(result)
    vim.schedule(function()
      handlers.on_exit(result.code)
    end)
  end)

  return runOf(url, command, job)
end

return M
