
"*****************************************************************************
"" Basic Setup
"*****************************************************************************"
filetype plugin indent on
set autoread
set showtabline=2
set nocompatible
set wildmenu
set wildmode=longest,list
set pumheight=20
"source $VIMRUNTIME/menu.vim
set splitbelow
set splitright

"" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8


"" Fix backspace indent
set backspace=indent,eol,start

"" Tabs. May be overridden by autocmd rules
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab


"" Enable hidden buffers
set hidden

"" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

set fileformats=unix,dos,mac

if exists('$SHELL')
    set shell=$SHELL
else
    set shell=/bin/sh
endif


" Enable mouse
set mouse=a
set mousemodel=popup

abbreviate teh the

""*****************************************************************************
"" Visual Settings
"*****************************************************************************
syntax enable
set ruler
set number
set wrap linebreak breakindent
set showbreak=\ ﬌\ 
set signcolumn=auto:2
set cursorline
"
" Tweaks to improve performance
set updatetime=1000
set lazyredraw

let $EDITOR="nvr --remote-wait -cc '0wincmd w'"
function! EnterTerminal()
  setlocal nonumber norelativenumber autowriteall modifiable noruler
  "setlocal winfixheight
  "setlocal noshowmode
  "setlocal laststatus=0
  "setlocal noshowcmd
  "setlocal cmdheight=1
endfunction

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile


" If you have vim >=8.0 or Neovim >= 0.1.5
if (has("termguicolors"))
    set termguicolors
endif

" For Neovim 0.1.3 and 0.1.4
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

"" Status bar
set laststatus=2

"" Use modeline overrides
set modeline
set modelines=10

set title
set titleold="Terminal"
set titlestring=%F

set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)\

set guicursor=n-v-c:block-Cursor/lCursor
            \,i-ci-ve:ver100-iCursor
            \,r-cr:block-rCursor
            \,o:hor50-Cursor/lCursor
            \,sm:block-iCursor
            \,a:blinkwait1000-blinkon500-blinkoff250


function! TwoSpaceIndent()
  setlocal shiftwidth=2
  setlocal tabstop=2
  setlocal softtabstop=2
  setlocal expandtab
endfunction

function! FourSpaceIndent()
    setlocal shiftwidth=4
    setlocal tabstop=4
    setlocal softtabstop=4
    setlocal expandtab
endfunction

function! InitTerminal()
  setlocal nonumber norelativenumber noruler nocursorline signcolumn=yes
  setlocal autowriteall modifiable
  set filetype=terminal
endfunction

augroup core_autocmd
  autocmd!
  autocmd FileType gitcommit,gitrebase,gitconfig,fern,bufexplorer set bufhidden=delete
  autocmd FileType javascript,typescript,html call TwoSpaceIndent()
  autocmd FileType dockerfile,yml call TwoSpaceIndent()
  autocmd TermOpen * call InitTerminal()
  autocmd TermEnter * call InitTerminal()
  autocmd TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=700}
  autocmd TermClose * if !v:event.status | exe 'bdelete! '..expand('<abuf>') | endif
augroup END
