_G.connectDB = function()
  -- hand written connections
  local path = vim.fn.getenv("HOME") .. "/.local/share/nvim/db_connections.lua"
  local conns = dofile(path)
  -- Create a list of choices and a table of connection strings
  -- in the same order
  local choices = {} -- string names of connections
  for index, value in pairs(conns) do
    table.insert(choices, index .. ": " .. value.name)
  end
  local choice = vim.fn.inputlist(choices)
  if choice == 0 then
    return
  end

  vim.b.db_name = conns[choice].name
  local db = conns[choice].conn
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
    vim.cmd("DB")
  else
    vim.cmd("%DB")
  end
end

_G.openInLess = function()
  -- Open the current file in less in a tmux popup window
  local path = vim.fn.expand("%")
  local cmd = '/usr/bin/less -S --header 1 --mouse --wheel-lines 3 ' .. path
  vim.fn.system("tmux popup -w 80% -h 80% -E " .. vim.fn.shellescape(cmd))
end


return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod', lazy = true },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
  },
  cmd = {
    'DB',
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_hide_schemas = {
      "pg_toast",
      "pg_toast_temp_*",
      "information_schema",
      "pg_catalog",
    }

    vim.cmd[[
      function! InitSql()
        if exists('g:db')
          let b:db=g:db
        endif
        command! -buffer DBconnect lua connectDB()
        nnoremap <silent><buffer> <M-x> <cmd>lua executeSql(0)<cr>
        vnoremap <silent><buffer> <M-x> <cmd>lua executeSql(1)<cr>
        lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} })
      endfunction

      function! InitDbout()
        nnoremap <silent><buffer> <M-x> <cmd>lua openInLess()<cr>
      endfunction

      augroup db
        autocmd!
        autocmd FileType sql,mysql,plsql call InitSql()
        autocmd FileType dbout call InitDbout()
      augroup END
    ]]
  end,
}
