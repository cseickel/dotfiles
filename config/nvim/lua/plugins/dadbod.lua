-- Each source window remembers its own tabiew window.
local WINVAR = "dadbod_csv_win"
--_G.csvviewer = 'csvlens'
_G.csvviewer = nil

local function csvWinFor(srcWin)
  local ok, win = pcall(vim.api.nvim_win_get_var, srcWin, WINVAR)
  if ok and type(win) == "number" and vim.api.nvim_win_is_valid(win) then
    return win
  end
end

local function openCsvWindow(srcWin)
  local win = csvWinFor(srcWin)
  if win then
    vim.api.nvim_set_current_win(win)
    local old = vim.api.nvim_win_get_buf(win)
    vim.cmd("enew")
    if vim.api.nvim_buf_is_valid(old) and old ~= vim.api.nvim_get_current_buf() then
      vim.api.nvim_buf_delete(old, { force = true })
    end
  else
    vim.api.nvim_set_current_win(srcWin)
    vim.cmd("belowright new")
    vim.api.nvim_win_set_var(srcWin, WINVAR, vim.api.nvim_get_current_win())
  end
end

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

-- Grab the SQL to run: the visual selection (charwise-aware) or the whole buffer.
local function sqlText(visual)
  local lines
  if visual == 1 then
    lines = vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = vim.fn.visualmode() })
  else
    lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  end
  local sql = table.concat(lines, "\n")
  -- COPY (...) can't contain a trailing semicolon
  return (sql:gsub("%s+$", ""):gsub(";+$", ""):gsub("%s+$", ""))
end

_G.executeSqlCsv = function(visual)
  local db = vim.b.db
  if not db then
    db = connectDB()
  end
  if not db then
    return
  end
  if not db:match("^postgres") then
    vim.notify("tabiew view only supports postgres connections", vim.log.levels.ERROR)
    return
  end

  local sql = sqlText(visual)
  if sql == "" then
    vim.notify("no query to run", vim.log.levels.WARN)
    return
  end

  local csv = vim.fn.tempname() .. ".csv"
  local copy = "COPY (\n" .. sql .. "\n) TO STDOUT WITH (FORMAT csv, HEADER)"

  local res = vim.system({ "psql", db, "-v", "ON_ERROR_STOP=1", "-c", copy }, { text = true }):wait()
  if res.code ~= 0 then
    vim.notify(vim.trim(res.stderr or "psql failed"), vim.log.levels.ERROR)
    return
  end

  local fh = io.open(csv, "w")
  if not fh then
    vim.notify("could not write " .. csv, vim.log.levels.ERROR)
    return
  end
  fh:write(res.stdout or "")
  fh:close()

  local srcWin = vim.api.nvim_get_current_win()

  openCsvWindow(srcWin)
  local buf = vim.api.nvim_get_current_buf()
  vim.b.db = db
  -- if not set, open the csv directly
  if _G.csvviewer then
    vim.fn.jobstart({ _G.csvviewer, csv }, {
      term = true,
      on_exit = function()
        os.remove(csv)
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end)
      end,
    })
  else
    vim.cmd("edit " .. csv)
  end
  if vim.api.nvim_win_is_valid(srcWin) then
    vim.api.nvim_set_current_win(srcWin)
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
