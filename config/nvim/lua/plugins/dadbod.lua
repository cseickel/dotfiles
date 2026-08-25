--_G.csvviewer = 'csvlens'
_G.csvviewer = nil

_G.connectDB = function()
  -- hand written connections
  local path = vim.fn.getenv("HOME") .. "/.local/share/db_ui/connections.json"
  local conns = vim.fn.json_decode(vim.fn.readfile(path))
  -- Create a list of choices and a table of connection strings
  -- in the same order
  local choices = {} -- string names of connections
  for index, value in ipairs(conns) do
    table.insert(choices, index .. ": " .. value.name)
  end
  local choice = vim.fn.inputlist(choices)
  if choice == 0 then
    return
  end

  print(vim.inspect(conns[choice]))

  vim.b.db_name = conns[choice].name
  local db = conns[choice].url
  vim.b.db = db
  vim.g.db = db
  return db
end

_G.executeSql = function(visual)
  local db = vim.b.db
  if not db then
    db = connectDB()
  end
  if not db then
    return
  end

  if visual == 1 then
    vim.cmd("'<,'>DB")
  else
    vim.cmd("%DB")
  end
end

-- The selected lines, empty when nothing is selected. A <cmd> mapping leaves
-- visual mode on and `'<` and `'>` still holding the previous selection, so
-- the live selection is read while it is there and the marks only after it has
-- ended, which is how DBcsvText arrives.
local function selectedLines()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    return vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
  end

  local kind = vim.fn.visualmode()
  if kind == "" then
    return {}
  end
  return vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = kind })
end

-- Grab the SQL to run: the visual selection or the whole buffer.
local function sqlText(visual)
  local lines
  if visual == 1 then
    lines = selectedLines()
  else
    lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  end
  return vim.trim(table.concat(lines, "\n"))
end

-- The line closing a pane, naming how it ended and how long it took.
local function outcome(ending, started)
  return string.format("\n[%s in %.3fs]\n", ending, (vim.uv.hrtime() - started) / 1e9)
end

-- The rows as a table, replacing the pane that reported their progress.
local function showTable(db, results, srcWin)
  local pane = require("db.pane")
  pane.open(srcWin)
  -- if not set, open the results directly
  if _G.csvviewer then
    local buf = vim.api.nvim_get_current_buf()
    vim.fn.jobstart({ _G.csvviewer, results }, {
      term = true,
      on_exit = function()
        os.remove(results)
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end)
      end,
    })
  else
    vim.cmd("edit " .. results)
    vim.b.db = db
  end
  pane.leave(srcWin)
end

-- Enough of the sql to recognise which query the pane is reporting on.
local function preview(sql)
  local lines = vim.split(sql, "\n", { plain = true })
  local shown = vim.list_slice(lines, 1, math.min(3, #lines))
  if #lines > 3 then
    table.insert(shown, "...")
  end
  return table.concat(shown, "\n")
end

-- Opens the pane on a buffer reporting `query`'s progress and runs `start`,
-- which writes into that buffer and returns the job doing so. Whatever the job
-- is for, C-c stops it and focus stays where it was.
---@param query { db: string, sql: string, win: integer }
---@param start fun(append: db.Appender, done: fun()): db.Run|nil
local function inPane(query, start)
  local pane = require("db.pane")
  pane.open(query.win)

  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].modifiable = false
  vim.b[buf].db = query.db

  local append = pane.appender(buf)
  append.write(preview(query.sql) .. "\n\n")

  local stop = pane.progress(query.win, buf)
  local run = start(append, function()
    stop()
    pane.release(query.win)
  end)
  if run then
    pane.attach(query.win, run)
  else
    stop()
  end
  pane.leave(query.win)
end

-- The client's transcript, read into the pane while the script is still running.
local function openTranscript(db, sql, srcWin)
  inPane({ db = db, sql = sql, win = srcWin }, function(append, done)
    local started = vim.uv.hrtime()
    return require("db.query").stream(db, sql, {
      on_output = append.write,
      on_exit = function(code)
        done()
        append.flush()
        append.write(outcome(code == 0 and "finished" or "failed", started))
      end,
    })
  end)
end

-- The rows of a single query, opened as a table once they have all arrived.
local function openResults(db, sql, srcWin)
  inPane({ db = db, sql = sql, win = srcWin }, function(append, done)
    local started = vim.uv.hrtime()
    return require("db.query").write(db, sql, function(results)
      done()
      if not results then
        append.write(outcome("failed", started))
        return
      end
      showTable(db, results, srcWin)
    end)
  end)
end

_G.executeSqlCsv = function(visual)
  local db = vim.b.db
  if not db then
    db = connectDB()
  end
  if not db then
    return
  end

  local sql = sqlText(visual)
  if sql == "" then
    vim.notify("no query to run", vim.log.levels.WARN)
    return
  end

  local srcWin = vim.api.nvim_get_current_win()
  if require("db.query").mode(sql) == "export" then
    openResults(db, sql, srcWin)
  else
    openTranscript(db, sql, srcWin)
  end
end

return {
  'kristijanhusak/vim-dadbod-ui',
  lazy = false,
  dependencies = {
    { 'tpope/vim-dadbod' },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
  },
  cmd = {
    'DB',
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
    'DBexecute',
    'DBconnect'
  },
  init = function()
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_hide_schemas = {
      "pg_toast",
      "pg_toast_temp_*",
      "information_schema",
      "pg_catalog",
    }

    require("db.parquet").setup()

    vim.cmd[[
      command! DBconnect lua connectDB()
      command! DBexecute lua executeSql(0)
      command! -range DBexecute lua executeSql(1)
      command! DBcsv lua executeSqlCsv(0)
      command! -range DBcsv lua executeSqlCsv(1)

      function! DBexecuteText()
        if &ft == 'typescript'
          normal vi`
        else
          normal vi"
        endif
        " This is a hack, I just want to set the marks of the visual selection
        " I'll yank it to the blackhole register
        normal "_y
        " Now I can execute the command with the range
        lua executeSql(1)
      endfunction

      nnoremap <silent> <M-x> <cmd>call DBexecuteText()<cr>

      function! DBcsvText()
        if &ft == 'typescript'
          normal vi`
        else
          normal vi"
        endif
        normal "_y
        lua executeSqlCsv(1)
      endfunction

      nnoremap <silent> <M-c> <cmd>call DBcsvText()<cr>

      function! InitSql()
        if exists('g:db')
          let b:db=g:db
        endif
        " nnoremap <silent><buffer> <M-x> <cmd>lua executeSql(0)<cr>
        " vnoremap <silent><buffer> <M-x> <cmd>lua executeSql(1)<cr>
        nnoremap <silent><buffer> <M-x> <cmd>lua executeSqlCsv(0)<cr>
        vnoremap <silent><buffer> <M-x> <cmd>lua executeSqlCsv(1)<cr>
        lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} })
      endfunction

      augroup db
        autocmd!
        autocmd FileType sql,mysql,plsql call InitSql()
      augroup END
    ]]
  end,
}
