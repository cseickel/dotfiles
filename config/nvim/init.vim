let g:owd = getcwd()
cd ~/.config/nvim

let g:loaded_gzip = 1
let g:loaded_tar = 1
let g:loaded_tarPlugin = 1
let g:loaded_zip = 1
let g:loaded_zipPlugin = 1

let g:loaded_getscript = 1
let g:loaded_getscriptPlugin = 1
let g:loaded_vimball = 1
let g:loaded_vimballPlugin = 1

let g:loaded_2html_plugin = 1
let g:loaded_logiPat = 1
let g:loaded_rrhelper = 1

let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1
let g:loaded_netrwSettings = 1
let g:loaded_netrwFileHandlers = 1

source core-config.vim
source core-mappings.vim
lua << EOF
  --pcall(require, 'impatient')
  require('plugins')
  require('quickfix')
  require('mappings')

  _G.update_lua_plugin_config = function()
    local path = vim.fn.expand("<afile>")
    local module_name = vim.fn.fnamemodify(path, ':t:r')
    package.loaded[module_name] = nil
    package.loaded["plugins.config." .. module_name] = nil
    package.loaded["plugins"] = nil
    package.loaded["packer"] = nil
    vim.cmd("source " .. path)
    vim.cmd("source ~/.config/nvim/lua/plugins/init.lua")
    require("packer").compile()
  end
EOF
source theme.vim
lua require('status')
exe 'cd ' . g:owd

augroup init
    autocmd!
    autocmd BufWritePost */config/nvim/lua/* call v:lua.update_lua_plugin_config()
augroup END
