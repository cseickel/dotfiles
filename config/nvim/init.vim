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
lua    require('impatient')
lua    require('plugins')
source plugin-config.vim
lua    require('mappings')
source plugin-mappings.vim
lua    require('status')
exe 'cd ' . g:owd

augroup init
    autocmd!
    autocmd BufWritePost plugins.lua source <afile>
augroup END
