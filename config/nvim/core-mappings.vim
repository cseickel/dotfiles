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

" Quick edits from normal/visual mode
nnoremap <silent> <tab> >>
nnoremap <silent> <S-tab> <<
nnoremap <silent> <cr> i<cr><esc>
nnoremap <silent> <bs> i<bs><esc>l
nnoremap <silent> <space> i<space><esc>l

vnoremap <silent> <tab> >gv
vnoremap <silent> <s-tab> <gv
vnoremap <silent> <cr> s<cr><esc>
vnoremap <silent> <bs> xh 
vnoremap <silent> <space> s<space><esc>

" Standard Save shortcuts
noremap  <silent> <C-s> :w<cr>
inoremap <silent> <C-s> <Esc>:w<cr>
noremap  <silent> <M-s> :wa<cr>
inoremap <silent> <M-s> <Esc>:wa<cr>

" Control+v is for paste, use Alt+v for visual block mode
nnoremap <silent> <M-v> <C-v>

" Control+p as universal paste shortcut in all modes
nmap <silent> <C-p> p
vmap <silent> <C-p> p
imap <silent> <C-p> <Esc>pa
tmap <silent> <C-p> <c-\>pa

" Select All
nnoremap <silent> <C-a> ggVG
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

" window navigation
nnoremap <silent> h <C-w>h
nnoremap <silent> j <C-w>j
nnoremap <silent> k <C-w>k
nnoremap <silent> l <C-w>l

" tab navigation
nnoremap <silent> H :tabprevious<cr>
nnoremap <silent> L :tabnext<cr>

function! SmartWindowResize(orientation, direction) abort
    if a:orientation == "v"
        let s:size = winwidth(0)
    endif
    if a:orientation == "h"
        let s:size = winheight(0) * 2
    endif

    let s:incr = 5
    if s:size < 70
        let s:incr = 4
    endif
    if s:size < 60
        let s:incr = 3
    endif
    if s:size < 50
        let s:incr = 2
    endif
    if s:size < 40
        let s:incr = 1
    endif

    if a:orientation == "h"
        if a:direction < 1
            execute "resize -" . s:incr
        else
            execute "resize +" . s:incr
        endif
    endif
    if a:orientation == "v"
        if a:direction < 1
            execute "vert resize -" . s:incr
        else
            execute "vert resize +" . s:incr
        endif
    endif
endfunction
" window resize
nnoremap <silent> _     :call SmartWindowResize("h", 0)<cr>
nnoremap <silent> +     :call SmartWindowResize("h", 1)<cr>
nnoremap <silent> -     :call SmartWindowResize("v", 0)<cr>
nnoremap <silent> =     :call SmartWindowResize("v", 1)<cr>

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
