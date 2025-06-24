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

" replaced by matchup
let g:loaded_matchit = 1

source core-config.vim
source core-mappings.vim
source theme.vim
lua require('lazy-bootstrap')
lua require('ts-fix-highlight-groups')
lua require('quickfix')
lua require('mappings')
lua require('status')
" Set the socket path for Cluade Code to use
let $NVIM_SOCKET = len($NVIM_UNCEPTION_PIPE_PATH_HOST) ? $NVIM_UNCEPTION_PIPE_PATH_HOST : (len($NVIM) ? $NVIM : $NVIM_LISTEN_ADDRESS)
exe 'cd ' . g:owd
