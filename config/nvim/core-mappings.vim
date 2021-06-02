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

nnoremap s ciw

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
nmap <silent> <C-v> p
vmap <silent> <C-v> p
imap <silent> <C-v> <Esc>pa
tmap <silent> <C-v> <c-\>pa

" Select All
noremap  <silent> <C-a> ggVG
inoremap <silent> <C-a> <Esc>ggVG
vnoremap <silent> <C-a> <Esc>ggVG

" Standard Cut shortcut
"inoremap <silent> <C-x> <Esc>yawdawi
"vnoremap <silent> <C-x> ygvd
"nnoremap <silent> <C-x> Vydd

" Search and Replace Selected Text
vnoremap <C-r> "ry:%s/<C-r>rp//gc<left><left><left>

" Re-map add mark, bceuase I will shadow it with EasyClip's m for move
nnoremap <leader>m m

" Close window
noremap <C-q> :q<cr>
inoremap <C-q> <Esc>:q<cr>

" Open quickfix at bottom of all windows
noremap <leader>q :botright copen

"" Quick folding of a block in normal mode with the 'z' key
"nnoremap z V%zf
"" and unfold with uppercase 'Z'
"nnoremap Z zo
"augroup fold_augroup
"    autocmd!
"    autocmd FileType xml nnoremap <buffer> z Vatzf
"    autocmd FileType html nnoremap <buffer> z Vatzf
"augroup END

nnoremap <silent> <leader>. :tcd %:p:h<CR>

nnoremap <silent> <leader>w1 :1wincmd w <cr>
nnoremap <silent> <leader>w2 :2wincmd w <cr>
nnoremap <silent> <leader>w3 :3wincmd w <cr>
nnoremap <silent> <leader>w4 :4wincmd w <cr>
nnoremap <silent> <leader>w5 :5wincmd w <cr>
nnoremap <silent> <leader>w6 :6wincmd w <cr>
nnoremap <silent> <leader>w7 :7wincmd w <cr>
nnoremap <silent> <leader>w8 :8wincmd w <cr>
nnoremap <silent> <leader>w9 :9wincmd w <cr>
nnoremap <silent> <leader>w0 :10wincmd w <cr>

" window movement
nnoremap <silent> <C-h> <C-w>H
nnoremap <silent> <C-j> <C-w>x<C-w>j
nnoremap <silent> <C-k> <C-w>k<C-w>x
nnoremap <silent> <C-l> <C-w>K
nnoremap <silent> <leader>z :execute "-1tabedit % | " . line(".") <cr>
nnoremap ZZ <Nop>
" window resize
nnoremap <silent> _     <C-w>5<
nnoremap <silent> +     <C-w>5>
nnoremap <silent> -     <C-w>-
nnoremap <silent> =     <C-w>+

" window navigation
nnoremap <silent> <M-h> <C-w>h
nnoremap <silent> <M-j> <C-w>j
nnoremap <silent> <M-k> <C-w>k
nnoremap <silent> <M-l> <C-w>l

function! CloseTerminal() abort
    for win in nvim_tabpage_list_wins(0)
        if nvim_buf_get_name(nvim_win_get_buf(win)) =~ "term://" && nvim_win_get_width(win) == &columns && nvim_win_get_height(win) < (&lines-3)
            call nvim_win_close(win, 1)
        endif
    endfor
endfunction

function! RecycleTerminal()
    for buf in getbufinfo({ 'buflisted': 1 })
        if buf.name =~ "term://" && len(buf.windows) == 0
            execute "buffer " . buf.bufnr
            return buf.name
        endif
    endfor
    terminal
endfunction

nnoremap <silent> <leader>s :botright split<bar>resize 14<bar>setlocal winfixheight<bar>call RecycleTerminal()<cr>
nnoremap <silent> <leader>S :call CloseTerminal()<cr>
