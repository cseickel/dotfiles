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

  vim.b.db_name = conns[choice].name
  local db = conns[choice].url
  vim.b.db = db
  vim.g.db = db
  return db
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

-- Runs `sql` and shows what the client writes in the output window, with an
-- indicator beside the query and the key that stops it bound while it runs.
--
-- A transcript is worth watching fill in, so the window follows the file as it
-- is written. Rows are worth reading only once they are all there, and
-- rendering a half written table every half second is expensive on exactly the
-- results large enough to need the wait.
local function execute(db, sql, srcWin)
  local pane = require("db.pane")
  local query = require("db.query")
  -- One query per window, so starting a second one asks the first to stop
  -- rather than leaving a client running that nothing holds a handle to.
  pane.stop(srcWin)

  local mode = query.mode(sql)
  local stopIndicator = pane.progress(srcWin)
  local stopFollowing, run, started

  started = query.start({
    url = db,
    sql = sql,
    mode = mode,
    on_done = function(code)
      stopIndicator()
      if stopFollowing then
        stopFollowing()
      elseif code == 0 then
        pane.show(srcWin, started.path, db)
      end
      pane.release(srcWin, run)
    end,
  })

  if not started then
    stopIndicator()
    return
  end

  run = started.run
  pane.attach(srcWin, run)
  if mode == "script" then
    stopFollowing = pane.follow(srcWin, started.path, db)
  end
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

  execute(db, sql, vim.api.nvim_get_current_win())
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
      command! DBcsv lua executeSqlCsv(0)
      command! -range DBcsv lua executeSqlCsv(1)

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
