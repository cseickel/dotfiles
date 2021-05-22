
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
set nowrap
set signcolumn=yes

" Tweaks to improve performance
set nocursorline
set updatetime=1000
set lazyredraw

function! HideOneLineWindows(...)
  if mode() != 'n'
    return
  endif
  
  let l:currwin = winnr()
  for i in range(1, winnr('$'))
    if !&buflisted
      continue
    endif
    if winwidth(i) > 1
      if winheight(i) > 1
        if bufname(winbufnr(i)) =~ ".space-filler."
          execute i . 'wincmd w'
          b#
          if expand('%') =~ "term://"
            setlocal nonumber norelativenumber nocursorline signcolumn=yes
          else
            setlocal number signcolumn=yes
          endif
        endif
      else
        if !(bufname(winbufnr(i)) =~ ".space-filler.")
          execute i . 'wincmd w'
          let l:original_ft = &ft
          let l:original_ext = expand('%:e')
          execute "e ~/.config/nvim/.space-filler." . l:original_ext
          let &ft = l:original_ft
          setlocal nobuflisted readonly nonumber norelativenumber
        endif
      endif
    endif
  endfor
  if winnr() != l:currwin
    execute l:currwin . 'wincmd w'
    AirlineRefresh
  endif
endfunction

if exists('g:my_hide_one_liner_timer')
  call timer_stop(g:my_hide_one_liner_timer)
endif
"let g:my_hide_one_liner_timer = timer_start(100, 'HideOneLineWindows', {'repeat': -1})

function! SetRelative()
  if &ft == 'CHADtree'
    setlocal nonumber norelativenumber
    return
  endif
  if expand('%') =~ "term://"
    setlocal nonumber norelativenumber nocursorline signcolumn=yes
  else
    if expand("%:t") =~ ".space-filler."
      setlocal nonumber norelativenumber nowrap signcolumn=no
    else
      setlocal nonumber relativenumber 
    endif
  endif
  redraw
endfunction

function! SetNoRelative()
  if &ft == 'CHADtree'
    setlocal nonumber norelativenumber
    return
  endif
  if expand('%') =~ "term://"
    setlocal nonumber norelativenumber
  else
    if expand("%:t") =~ ".space-filler."
      setlocal nonumber norelativenumber nowrap signcolumn=no
    else
      setlocal number norelativenumber wrap signcolumn=yes
    endif
  endif
endfunction

let $EDITOR="nvr --remote-wait -cc '0wincmd w'"
function! EnterTerminal()
  setlocal nonumber norelativenumber autowriteall modifiable noruler
  "setlocal ft=terminal
  "setlocal winfixheight
  "setlocal noshowmode
  "setlocal laststatus=0
  "setlocal noshowcmd
  "setlocal cmdheight=1
endfunction

function! TwoSpaceIndent()
  setlocal shiftwidth=2
  setlocal tabstop=2
  setlocal softtabstop=2
  setlocal expandtab
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

function! InitTerminal()
  setlocal nonumber norelativenumber noruler nocursorline signcolumn=yes
  setlocal autowriteall modifiable
endfunction

augroup core_autocmd
  autocmd!
  autocmd FileType gitcommit,gitrebase,gitconfig,fern,bufexplorer set bufhidden=delete
  autocmd FileType javascript,typescript,html call TwoSpaceIndent()
  autocmd TermOpen * call InitTerminal()
  "autocmd BufEnter,InsertLeave * call SetRelative()
  "autocmd CmdlineLeave         * call SetRelative() | redraw
  "autocmd BufLeave,InsertEnter * call SetNoRelative()
  "autocmd CmdlineEnter         * call SetNoRelative() | redraw
augroup END
