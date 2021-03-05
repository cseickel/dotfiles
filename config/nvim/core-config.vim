
"*****************************************************************************
"" Basic Setup
"*****************************************************************************"
filetype plugin indent on
set autoread
set showtabline=2
set nocompatible
set wildmenu
set wildmode=longest,list
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

set listchars=tab:--▶,space:·,trail:·,extends:>,precedes:<

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


""*****************************************************************************
"" Visual Settings
"*****************************************************************************
syntax enable
set ruler
set number
set wrap
set signcolumn=yes

" Tweaks to improve performance
set nocursorline
set updatetime=1000
set lazyredraw

function! SetFocusedNumber()
  if expand('%') =~ "term://"
    set nonumber nocursorline
  else
    set number relativenumber
  endif
endfunction
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * call SetFocusedNumber()
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber nocursorline
augroup END


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
