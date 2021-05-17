" Turns off highlight of last search and paste mode when you hit Escape.
nnoremap <silent> <Esc> <Esc>:noh<bar>set nopaste<CR>
" clear search term for real
command C let @/=""
" Map Control \ to Esc
map <silent> <C-\> <Esc>  
imap <silent> <C-\> <Esc>
tnoremap <silent> <C-\> <c-\><c-n>

" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
nnoremap n nzzzv
nnoremap N Nzzzv


"" Map leader to ,
let mapleader=","

" Switch to previous buffer
nnoremap <M-3> :b#<cr>
inoremap <M-3> <Esc>:b#<cr>
tnoremap <M-3> <c-\><c-n>:b#<cr>

" Tab Navigation
nnoremap <silent> <tab> :tabnext<cr>
nnoremap <silent> <S-tab> :tabprevious<cr>

" Standard Save shortcuts
noremap  <silent> <C-s> :w<cr>
inoremap <silent> <C-s> <Esc>:w<cr>
noremap  <silent> <M-s> :wa<cr>
inoremap <silent> <M-s> <Esc>:wa<cr>

" Use Control + v for paste, ALt + v for visual block mode
nnoremap <silent> <M-v> <C-v>
nnoremap <silent> <C-v> "0p
vnoremap <silent> <C-v> "_d"0p
inoremap <silent> <C-v> <Esc>"0pa
tnoremap <silent> <C-v> <c-\><c-n>"0pi

" Select All
noremap  <silent> <C-a> ggVG
inoremap <silent> <C-a> <Esc>ggVG
vnoremap <silent> <C-a> <Esc>ggVG

" Standard Cut shortcut
inoremap <silent> <C-x> <Esc>yawdawi
vnoremap <silent><C-x> ygvd
nnoremap <silent> <C-x> Vydd

" Search and Replace Selected Text
vnoremap <C-r> "ry:%s/<C-r>rp//gc<left><left><left>

" Re-map add mark, bceuase I will shadow it with EasyClip's m for move
nnoremap am m

" Close window
noremap <C-q> :q<cr>
inoremap <C-q> <Esc>:q<cr>

" Open quickfix at bottom of all windows
noremap <leader>q :botright copen

" Quick folding of a block in normal mode with the 'z' key
"nnoremap z V%zf
"autocmd FileType xml nnoremap <buffer> z Vatzf
"autocmd FileType html nnoremap <buffer> z Vatzf
" and unfold with uppercase 'Z'
"nnoremap Z zo

nnoremap <silent> <leader>. :tcd %:p:h<CR>


" Window navigation
"nnoremap <Left>  <c-w>h
"nnoremap <Down>  <c-w>j
"nnoremap <Up>    <c-w>k
"nnoremap <Right> <c-w>l

nnoremap <silent> `1 :1wincmd w <cr>
nnoremap <silent> `2 :2wincmd w <cr>
nnoremap <silent> `3 :3wincmd w <cr>
nnoremap <silent> `4 :4wincmd w <cr>
nnoremap <silent> `5 :5wincmd w <cr>
nnoremap <silent> `6 :6wincmd w <cr>
nnoremap <silent> `7 :7wincmd w <cr>
nnoremap <silent> `8 :8wincmd w <cr>
nnoremap <silent> `9 :9wincmd w <cr>
nnoremap <silent> `0 :10wincmd w <cr>

" window movement
nnoremap <silent> <C-h> <C-w>H
nnoremap <silent> <C-j> <C-w>x<C-w>j
nnoremap <silent> <C-k> <C-w>k<C-w>x
nnoremap <silent> <C-l> <C-w>K
nnoremap <silent> <C-m> :-1tabedit % <cr>
" window resize
nnoremap <silent> _     <C-w>_
nnoremap <silent> <     <C-w>5<
nnoremap <silent> >     <C-w>5>
nnoremap <silent> -     <C-w>-
nnoremap <silent> +     <C-w>+
nnoremap <silent> =     <C-w>+

" window navigation
nnoremap <silent> <M-h> <C-w>h
nnoremap <silent> <M-j> <C-w>j
nnoremap <silent> <M-k> <C-w>k
nnoremap <silent> <M-l> <C-w>l

function! RecycleTerminal()
    for buf in getbufinfo({ 'buflisted': 1 })
        if buf.name =~ "term://" && len(buf.windows) == 0
            execute "buffer " . buf.bufnr
            return buf.name
        endif
    endfor
    terminal
endfunction

nnoremap <silent> <leader>sh :botright split<bar>resize 10<bar>setlocal winfixheight<bar>call RecycleTerminal()<cr>
