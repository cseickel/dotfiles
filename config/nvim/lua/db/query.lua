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
  local asked = false
  return {
    job = job,
    cancel = function()
      -- A cancel is a request the client is still free to take its time over,
      -- so it stays the running query until it exits and can be asked again.
      if asked then
        return
      end
      asked = true
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

--- `argv` as a command line that writes what the client prints to `path`, so
--- the output goes from the client to the file without passing through nvim.
--- `exec` leaves the client holding the shell's own pid, so a signal reaches
--- the client.
---
--- A transcript is read, so the client's errors belong in it in the order the
--- client printed them, and one stream is the only way to get that. Rows are
--- data, and their stderr stays a separate pipe so an error cannot land in the
--- csv.
---@param argv string[]
---@param path string
---@param transcript boolean
---@return string[]
local function writingTo(argv, path, transcript)
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
  line = "exec " .. line .. " >" .. quoted(path)
  return { "sh", "-c", transcript and (line .. " 2>&1") or line }
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

---@class db.Started
---@field run db.Run
---@field path string The file the client is writing, named for what it holds.

-- Query output goes under the cache directory rather than through
-- vim.fn.tempname, because nvim's temp directory is under /tmp, and a /tmp on
-- tmpfs is memory. A result set large enough to be worth exporting would be
-- held in memory twice over.
local OUTPUT = vim.fn.stdpath("cache") .. "/db"
local written = 0

--- A file to write one query's output to, unused and unique to this nvim.
---@param extension string
---@return string
local function outputPath(extension)
  vim.fn.mkdir(OUTPUT, "p")
  written = written + 1
  return string.format("%s/%d-%d.%s", OUTPUT, vim.fn.getpid(), written, extension)
end

--- Runs `request.sql` against `request.url` with the client writing what it
--- prints straight to a file, and calls `request.on_done` with the exit code
--- once the client has finished. The output never reaches nvim, so what the
--- query returns cannot exhaust its memory.
---
--- `on_done` runs on the main loop. Nil for a url no client is known for,
--- already reported.
---@param request { url: string, sql: string, mode: db.Mode, on_done: fun(code: integer) }
---@return db.Started|nil
function M.start(request)
  local command = commandFor(request.url, request.sql, request.mode)
  if not command then
    return nil
  end

  local script = request.mode == "script"
  local path = outputPath(command.extension)
  local started = vim.uv.hrtime()

  local job = vim.system(writingTo(command.argv, path, script), {
    text = true,
    env = command.env,
    stdin = command.stdin,
    -- Detached, so the client leads its own process group. A client that
    -- shares nvim's group can be reached by a signal aimed at the group, and
    -- these clients are signalled to cancel them.
    detach = true,
  }, function(result)
    if script then
      local file = io.open(path, "a")
      if file then
        file:write(
          string.format(
            "\n[%s in %.3fs]\n",
            result.code == 0 and "finished" or "failed",
            (vim.uv.hrtime() - started) / 1e9
          )
        )
        file:close()
      end
    end
    vim.schedule(function()
      -- A script reports its own failure in the transcript, which is on screen.
      if result.code ~= 0 and not script then
        vim.notify(vim.trim(result.stderr or "query failed"), vim.log.levels.ERROR)
      end
      request.on_done(result.code)
    end)
  end)

  return { run = runOf(request.url, command, job), path = path }
end

return M
