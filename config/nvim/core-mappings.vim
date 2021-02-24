inoremap jk <Esc>

"" Map leader to ,
let mapleader=","

" Switch to previous buffer
nnoremap <M-3> :b#<cr>
inoremap <M-3> <Esc>:b#<cr>

" Tab Navigation
nnoremap <silent> <tab> :tabnext<cr>
nnoremap <silent> <S-tab> :tabprevious<cr>

" Standard Save shortcuts
noremap <silent> <C-s> :w<cr>
inoremap <silent> <C-s> <Esc>:w<cr>
noremap <silent> <M-s> :wa<cr>
inoremap <silent> <M-s> <Esc>:wa<cr>

" Use Control + v for paste, ALt + v for visual block mode
noremap <silent> <M-v> <C-v>
nnoremap <silent> <C-v> p
vnoremap <silent> <C-v> d"0p
inoremap <silent> <C-v> <Esc>pi
tnoremap <silent> <C-v> <c-\><c-n>pi

" Standard Cut shortcut
function! CopyDefaultRegisters()
    let @+=@0
    let @*=@0
    let @"=@0
endfunction
vnoremap <silent> <C-x> "0d:call CopyDefaultRegisters()<cr>
nnoremap <silent> <C-x> V"0d:call CopyDefaultRegisters()<cr>

" Re-map add mark, bceuase I will shadow it with EasyClip's m for move
nnoremap am m

" Close window
noremap <C-q> :q<cr>
inoremap <C-q> <Esc>:q<cr>

" Open quickfix at bottom of all windows
noremap <leader>q :botright copen

" Quick folding of a block in normal mode with the 'z' key
nnoremap z V%zf
autocmd FileType xml nnoremap <buffer> z Vatzf
autocmd FileType html nnoremap <buffer> z Vatzf
" and unfold with uppercase 'Z'
nnoremap Z zo

nnoremap <silent> <leader>. :tcd %:p:h<CR>


" Window navigation
"nnoremap <Left>  <c-w>h
"nnoremap <Down>  <c-w>j
"nnoremap <Up>    <c-w>k
"nnoremap <Right> <c-w>l

nnoremap <silent> <leader>1 :1wincmd w <cr>
nnoremap <silent> <leader>2 :2wincmd w <cr>
nnoremap <silent> <leader>3 :3wincmd w <cr>
nnoremap <silent> <leader>4 :4wincmd w <cr>
nnoremap <silent> <leader>5 :5wincmd w <cr>
nnoremap <silent> <leader>6 :6wincmd w <cr>
nnoremap <silent> <leader>7 :7wincmd w <cr>
nnoremap <silent> <leader>8 :8wincmd w <cr>
nnoremap <silent> <leader>9 :9wincmd w <cr>
nnoremap <silent> <leader><leader> :wincmd w <cr>

" window movement
nnoremap <silent> <C-h>     <C-w>H
nnoremap <silent> <C-j>     <C-w>x<C-w>j
nnoremap <silent> <C-k>     <C-w>k<C-w>x
nnoremap <silent> <C-l>     <C-w>K

" Create tool window at bottom
nnoremap <silent> <leader>tw :botright split<bar>resize 10<bar>setlocal winfixheight<cr>

" terminal emulation
nnoremap <silent> <leader>sh :botright terminal<cr><bar>resize 10<bar>setlocal winfixheight<CR>
tnoremap jk <c-\><c-n>
tnoremap <M-3> <c-\><c-n>:b#<cr>

function! EnterTerminal()
    setlocal nonumber norelativenumber autowriteall modifiable noruler
    setlocal ft=terminal
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

augroup core_autocmd
    autocmd!
    autocmd TermEnter * call EnterTerminal()
    autocmd FileType gitcommit,gitrebase,gitconfig,fern,bufexplorer set bufhidden=delete
    autocmd FileType javascript,typescript call TwoSpaceIndent()
augroup END
