
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
set scrolloff=5
set jumpoptions+=stack

"" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8


"" Fix backspace indent
set backspace=indent,eol,start

"" Tabs. May be overridden by autocmd rules
set tabstop=2
set softtabstop=2
set shiftwidth=2
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
set wrap
set showbreak=↳\
set linebreak breakindent
set signcolumn=auto:1-2
set cursorline
"
" Tweaks to improve performance
set updatetime=100
set lazyredraw

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
"set titlestring=%{fnamemodify(getcwd(-1, 0),\ ':t')}
set titlestring=%{toupper(fnamemodify(getcwd(-1,0),\ ':t'))}\ ...\ %t

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
  " To share clipboard between instances
  " if exists(':rshada')
  "   autocmd TextYankPost,FocusGained,FocusLost * rshada | wshada
  " endif
endfunction

function! WinLeave()
  if &filetype != "neo-tree"
    setlocal nocursorline
  endif
endfunction

highlight TransparentBackground guibg=transparent

function! InitTerminal()
  set filetype=terminal
  call EnterTerminal()
  "startinsert
endfunction

function! EnterTerminal()
  setlocal nonumber norelativenumber autowriteall modifiable noruler signcolumn=no
  setlocal winhighlight=Normal:TransparentBackground
  "setlocal winfixheight
  "setlocal noshowmode
  "setlocal laststatus=0
  "setlocal noshowcmd
  "setlocal cmdheight=1
  let g:last_terminal_job_id = b:terminal_job_id
  let g:last_terminal_winid = nvim_get_current_win()
  let g:last_terminal_bufid = nvim_get_current_buf()
  "startinsert
endfunction

function! GetUsableWinWidth()
  let l:id = nvim_get_current_win()
  let l:info = getwininfo(l:id)[0]
  let l:width = l:info['width'] - l:info['textoff']
  return l:width
endfunction

function! InitMarkdown()
  " if this file is in a tmp directory, delete the buffer on hide
  " it is probably a git commit message
  if expand('%:p') =~# '/tmp/'
    setlocal bufhidden=delete
    return
  endif
endfunction


augroup core_autocmd
  autocmd!
  autocmd FileType gitcommit,gitrebase,gitconfig,gitrebase,git,tmp set bufhidden=delete
  autocmd FileType go set noexpandtab
  autocmd FileType javascript,typescript,typescriptreact,html,lua call TwoSpaceIndent()
  autocmd FileType dockerfile,yml,vim call TwoSpaceIndent()
  autocmd FileType markdown call InitMarkdown()
  autocmd FileType cs call FourSpaceIndent()
  autocmd TermOpen * call InitTerminal()
  autocmd WinEnter term://* call EnterTerminal()
  autocmd BufEnter term://* call EnterTerminal()
  autocmd TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=700}
  "autocmd TermClose * if !v:event.status | exe 'bdelete! '..expand('<abuf>') | endif

  autocmd VimEnter    * call VimEnter()
  autocmd WinEnter    * setlocal cursorline
  autocmd BufWinEnter * setlocal cursorline
  autocmd WinLeave    * call WinLeave()

augroup END


function! CreateNewTerminal()
  split 20
  terminal
  call InitTerminal()
endfunction

function! SendToTerminal(cmd, job_id)
  let g:last_terminal_cmd = a:cmd
  call chansend(a:job_id, a:cmd . "\<cr>")
endfunction

function! SendToLastTerminal(args)
  if !exists("g:last_terminal_job_id") || !exists("g:last_terminal_winid")
    call CreateNewTerminal()
  endif
  let cmd = a:args
  if len(a:args) == 0
    let cmd = g:last_terminal_cmd
  endif
  if len(cmd) == 0
    echo "No command found"
    return
  endif
  try
    call SendToTerminal(cmd, g:last_terminal_job_id)
  catch
    call CreateNewTerminal()
    call SendToTerminal(cmd, g:last_terminal_job_id)
  endtry
  call win_execute(g:last_terminal_winid, 'normal! G')
endfunction

command! -nargs=? T call SendToLastTerminal("<args>")


" Stack to remember closed column buffers (per tab)
" Key: tabnr, Value: list of bufnrs (rightmost column first)
let g:closed_column_buffers = {}

function! GetClosedColumnStack()
  let l:tabnr = tabpagenr()
  if !has_key(g:closed_column_buffers, l:tabnr)
    let g:closed_column_buffers[l:tabnr] = []
  endif
  return g:closed_column_buffers[l:tabnr]
endfunction

" Get all non-floating windows with their positions
function! GetWindowsWithPositions()
  let l:windows = []
  for l:win in nvim_tabpage_list_wins(0)
    let l:cfg = nvim_win_get_config(l:win)
    if cfg.relative > "" || cfg.external
      continue
    endif
    let l:pos = win_screenpos(l:win)
    call add(l:windows, {
          \ 'win': l:win,
          \ 'x': l:pos[1],
          \ 'y': l:pos[0],
          \ 'bufnr': winbufnr(l:win)
          \ })
  endfor
  return l:windows
endfunction

" Get minimum y position (top row, accounts for tabline)
function! GetMinY()
  let l:windows = GetWindowsWithPositions()
  if len(l:windows) == 0
    return 1
  endif
  let l:min_y = l:windows[0].y
  for l:w in l:windows
    if l:w.y < l:min_y
      let l:min_y = l:w.y
    endif
  endfor
  return l:min_y
endfunction

" Get top-row windows (these define columns)
function! GetTopWindows()
  let l:windows = GetWindowsWithPositions()
  let l:min_y = GetMinY()
  let l:top_windows = []
  for l:w in l:windows
    if l:w.y == l:min_y
      call add(l:top_windows, l:w)
    endif
  endfor
  return l:top_windows
endfunction

" Count columns (windows at top of screen)
function! CountColumns()
  return len(GetTopWindows())
endfunction

" There is no reason why I would ever want a widescreen monitor to have a
" window that goes all the way to the edge of the screen. This will create
" splits to fit as many xxx characters wide windows as possible.
function! InitNewTab()
  let l:desired_columns = &columns / 120
  let l:desired_columns = l:desired_columns > 0 ? l:desired_columns : 1

  while CountColumns() < l:desired_columns
    silent! vsplit
  endwhile
endfunction

" Close rightmost column (all windows in column, save topmost buffer)
function! CloseRightmostColumn()
  let l:top_windows = GetTopWindows()
  if len(l:top_windows) <= 1
    return 0
  endif

  " Find rightmost top window
  let l:rightmost_top = l:top_windows[0]
  for l:w in l:top_windows
    if l:w.x > l:rightmost_top.x
      let l:rightmost_top = l:w
    endif
  endfor

  " Save topmost buffer
  let l:stack = GetClosedColumnStack()
  if bufexists(l:rightmost_top.bufnr)
    call insert(l:stack, l:rightmost_top.bufnr, 0)
  endif

  " Find ALL windows in this column (same x or greater, up to next column)
  let l:all_windows = GetWindowsWithPositions()
  let l:sorted_top = sort(copy(l:top_windows), {a, b -> a.x - b.x})
  let l:col_x = l:rightmost_top.x

  " Find the x of the column to the left (if any)
  let l:left_col_x = 0
  for l:w in l:sorted_top
    if l:w.x < l:col_x
      let l:left_col_x = l:w.x
    endif
  endfor

  " Close all windows in the rightmost column (x >= col_x)
  for l:w in l:all_windows
    if l:w.x >= l:col_x
      try
        call nvim_win_close(l:w.win, v:false)
      catch
      endtry
    endif
  endfor

  return 1
endfunction

" Restore a column from the stack
function! RestoreColumn()
  let l:stack = GetClosedColumnStack()

  " Find top-right window to split from
  let l:top_windows = GetTopWindows()
  if len(l:top_windows) == 0
    return
  endif
  let l:top_right = l:top_windows[0]
  for l:w in l:top_windows
    if l:w.x > l:top_right.x
      let l:top_right = l:w
    endif
  endfor

  " Get buffer to restore (or create empty)
  let l:bufnr = 0
  if len(l:stack) > 0
    let l:saved_bufnr = remove(l:stack, 0)
    if bufexists(l:saved_bufnr)
      let l:bufnr = l:saved_bufnr
    endif
  endif
  if l:bufnr == 0
    let l:bufnr = nvim_create_buf(v:true, v:false)
  endif

  " Create split to the right without changing focus
  call nvim_open_win(l:bufnr, v:false, {'split': 'right', 'win': l:top_right.win})
endfunction

" Handle window resize - close or open columns as needed
function! HandleResize()
  let l:desired_columns = &columns / 120
  let l:desired_columns = l:desired_columns > 0 ? l:desired_columns : 1
  let l:current_columns = CountColumns()

  " Shrinking: close rightmost columns
  let l:max_iterations = 20
  let l:iterations = 0
  while l:current_columns > l:desired_columns && l:current_columns > 1 && l:iterations < l:max_iterations
    let l:prev_columns = l:current_columns
    if !CloseRightmostColumn()
      break
    endif
    let l:current_columns = CountColumns()
    if l:current_columns >= l:prev_columns
      break
    endif
    let l:iterations += 1
  endwhile

  " Growing: restore columns
  let l:iterations = 0
  while l:current_columns < l:desired_columns && l:iterations < l:max_iterations
    let l:prev_columns = l:current_columns
    call RestoreColumn()
    let l:current_columns = CountColumns()
    if l:current_columns <= l:prev_columns
      break
    endif
    let l:iterations += 1
  endwhile
endfunction

function! CleanupClosedTab()
  let l:valid_tabs = range(1, tabpagenr('$'))
  for l:tabnr in keys(g:closed_column_buffers)
    if index(l:valid_tabs, str2nr(l:tabnr)) < 0
      call remove(g:closed_column_buffers, l:tabnr)
    endif
  endfor
endfunction

augroup core_tab
  autocmd!
  autocmd TabNew * call InitNewTab()
  autocmd VimEnter * call InitNewTab()
  autocmd VimResized * call HandleResize()
  autocmd TabClosed * call CleanupClosedTab()
augroup END

augroup ForgetfulMe
  autocmd!
  autocmd WinEnter * :stopinsert
augroup end

augroup AutoRefreshFromDisk
  autocmd!
  autocmd FocusGained * checktime
  autocmd WinEnter * if mode() == 'n' | checktime | endif
  autocmd BufWinEnter * if mode() == 'n' | checktime | endif
augroup end
