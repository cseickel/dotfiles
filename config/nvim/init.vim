set guifont=JetBrainsMono\ Nerd\ Font:h11
let g:owd = getcwd()
cd ~/.config/nvim

source core-config.vim
source core-mappings.vim
lua    require('impatient')
lua    require('plugins')
source plugin-config.vim
lua    require('config')
lua    require('mappings')
source plugin-mappings.vim

exe 'cd ' . g:owd

augroup init
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
augroup END
