
"*****************************************************************************
"" Basic Setup
"*****************************************************************************"
filetype plugin indent on
set autoread
set showtabline=1
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
"syntax enable
set ruler
set number
set wrap linebreak breakindent
set showbreak=\ ﬌\ 
set signcolumn=auto:1-2
set cursorline
"
" Tweaks to improve performance
set updatetime=1000
set lazyredraw

let $EDITOR="nvr --remote-wait -cc vsplit"
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
if has("persistent_undo")
  let target_path = stdpath('data') . '/.undodir'

  " create the directory and any parent directories
  " if the location does not exist.
  if !isdirectory(target_path)
    call mkdir(target_path, "p", 0700)
  endif

  let &undodir=target_path
  set undofile
endif
set shada='100,<1000,s100,h

"*****************************************************************************
" => UI related settings
" *****************************************************************************
"
" If you have vim >=8.0 or Neovim >= 0.1.5
if (has("termguicolors"))
    set termguicolors
endif
let g:markdown_fenced_languages = ['html', 'python', 'lua', 'vim', 'typescript', 'javascript']
" For Neovim 0.1.3 and 0.1.4
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

"" Status bar
set laststatus=3

"" Use modeline overrides
set modeline
set modelines=10

set title
set titleold="Terminal"
set titlestring=%F

" clipboard settings
set clipboard=unnamedplus
" Avoid showing message extra message when using completion
set shortmess+=c
set sessionoptions=curdir,tabpages,winpos,winsize

set guicursor=n-v-c:block-Cursor/lCursor
            \,i-ci-ve:ver100-iCursor
            \,r-cr:block-rCursor
            \,o:hor50-Cursor/lCursor
            \,sm:block-iCursor
            \,a:blinkwait1000-blinkon500-blinkoff250

function! NoBlink()
  set guicursor=n-v-c:block-Cursor/lCursor
              \,i-ci-ve:ver100-iCursor
              \,r-cr:block-rCursor
              \,o:hor50-Cursor/lCursor
              \,sm:block-iCursor
endfunction

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

function! VimEnter()
  setlocal cursorline
  "To share clipboard between instances
  if exists(':rshada') 
    autocmd TextYankPost,FocusGained,FocusLost * rshada | wshada
  endif
endfunction

function! WinLeave()
  if &filetype != "neo-tree"
    setlocal nocursorline
  endif
endfunction

function! InitTerminal()
  setlocal nonumber norelativenumber noruler nocursorline signcolumn=yes
  setlocal autowriteall modifiable
  set filetype=terminal
  let g:last_terminal_job_id = b:terminal_job_id
  let g:last_terminal_winid = nvim_get_current_win()
  let g:last_terminal_bufid = nvim_get_current_buf()
endfunction

augroup core_autocmd
  autocmd!
  autocmd FileType gitcommit,gitrebase,gitconfig,gitrebase,git,tmp set bufhidden=delete
  autocmd FileType go set noexpandtab
  autocmd FileType javascript,typescript,typescriptreact,html,lua call TwoSpaceIndent()
  autocmd FileType dockerfile,yml,vim call TwoSpaceIndent()
  autocmd FileType cs call FourSpaceIndent()
  autocmd TermOpen * call InitTerminal()
  autocmd TermEnter * call InitTerminal()
  autocmd TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=700}
  autocmd TermClose * if !v:event.status | exe 'bdelete! '..expand('<abuf>') | endif

  autocmd VimEnter    * call VimEnter()
  autocmd WinEnter    * setlocal cursorline
  autocmd BufWinEnter * setlocal cursorline
  autocmd WinLeave    * call WinLeave()

augroup END

function! SendToLastTerminal(args)
  if !exists("g:last_terminal_job_id") || !exists("g:last_terminal_winid")
    echo "No terminal found"
    return
  endif
  let cmd = a:args
  if len(a:args) == 0
    let cmd = g:last_terminal_cmd
  endif
  if len(cmd) == 0
    echo "No command found"
    return
  endif
  let g:last_terminal_cmd = cmd
  call chansend(g:last_terminal_job_id, cmd . "\<cr>")
  call win_execute(g:last_terminal_winid, 'normal! G')
endfunction

command! -nargs=? T call SendToLastTerminal("<args>")
