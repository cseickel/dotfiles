"Show Turns off highlight of last search and paste mode when you hit Escape.
nnoremap <silent> <Esc> <Esc>:noh<CR>
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

" Change word the cursor is on
nnoremap s "sciw
" Put all substitues in a s register
vnoremap s "sygvc
nnoremap S "sYYS

" Make Y consistent with C and D
nnoremap Y y$

" Reselect pasted text
nnoremap gp `[v`]

"" Map leader to ,
let mapleader=","

" Switch to previous buffer
nnoremap <M-3> :b#<cr>
inoremap <M-3> <Esc>:b#<cr>
tnoremap <M-3> <c-\><c-n>:b#<cr>

" Quick edits from normal/visual mode
"nnoremap <silent> <tab>     >>
"nnoremap <silent> <S-tab>   <<
"nnoremap <silent> <leader>o i<cr><esc>
"nnoremap <silent> <leader>O moO<esc>`o
"nnoremap <silent> <bs>      i<bs><esc>l
"nnoremap <silent> <space>   i<space><esc>l
"
"vnoremap <silent> <tab> >gv
"vnoremap <silent> <s-tab> <gv
"vnoremap <silent> <cr> s<cr><esc>
"vnoremap <silent> <bs> xh 
"vnoremap <silent> <space> s<space><esc>

" Standard Save shortcuts
noremap  <silent> <C-s> :w<cr>
inoremap <silent> <C-s> <Esc>:w<cr>
vnoremap <silent> <C-s> <Esc>:w<cr>
noremap  <silent> <M-s> :wa<cr>
inoremap <silent> <M-s> <Esc>:wa<cr>
tnoremap <silent> <M-s> <C-\><C-n>:wa<cr>
inoremap <silent> <C-s> <Esc>:w<cr>

" Control+v is for paste, use Alt+v for visual block mode
nnoremap <silent> <M-v> <C-v>
tnoremap <silent> <M-v> <C-v>

" Control+p as universal paste shortcut in all modes
nmap <silent> <C-p> p
vmap <silent> <C-p> p
imap <silent> <C-p> <Esc>pa
tmap <silent> <C-p> <c-\>pa


" Use Ctl+c/x/v as secondary clipboard
nnoremap <silent> <C-c> "cy
vnoremap <silent> <C-c> "cy
inoremap <silent> <C-c> <C-o>"cyiw
tnoremap <silent> <C-c> <c-\><c-n>l"cy$

inoremap <silent> <C-x> <C-o>"cdiw
vnoremap <silent> <C-x> "cd
nnoremap <silent> <C-x> "cdiw

nnoremap <silent> <C-v> "cp
vnoremap <silent> <C-v> "cp
inoremap <silent> <C-v> <C-o>"cp
tnoremap <silent> <C-v> <c-\><c-n>"cpa

command! WipeReg for i in range(34,122) | silent! call setreg(nr2char(i), []) | endfor


nmap <silent> <C-c> "cy

" Select All
nnoremap <silent> <C-a> ggVG
inoremap <silent> <C-a> <Esc>ggVG
vnoremap <silent> <C-a> <Esc>ggVG


" Search and Replace Selected Text
vnoremap <C-r> "ry:%s/<C-r>rp//gc<left><left><left>

" Re-map add mark, bceuase I will shadow it with EasyClip's m for move
nnoremap <leader>m m

" Close window
noremap <C-q> :q<cr>
inoremap <C-q> <Esc>:q<cr>

" Open quickfix at bottom of all windows
noremap <leader>q :botright copen<cr>
" Close Quickfix
noremap <leader>Q :cclose<cr>

" Open/close location list
noremap <leader>l :lopen<cr>
noremap <leader>L :lclose<cr>

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

function! SaveTerminal() abort
    for win in nvim_tabpage_list_wins(0)
        let buf_handle = nvim_win_get_buf(win)
        let buf_name = nvim_buf_get_name(buf_handle)
        if buf_name =~ "term://" && nvim_win_get_width(win) == &columns && nvim_win_get_height(win) < (&lines-3)
            " rename last saved terminal 
            let g:saved_terminal = buf_handle
            echo "Terminal Saved: " . buf_name
        endif
    endfor
endfunction

function! OpenSavedTerminal()
    if g:saved_terminal > 0
        let buf_name = nvim_buf_get_name(g:saved_terminal)
        botright split
        resize 14
        setlocal winfixheight
        execute 'b ' . buf_name
    else
        echom "No Saved Terminal to restore!"
    endif
endfunction


function! RecycleTerminal()
    let page_handle = nvim_get_current_tabpage()
    for buf in nvim_list_bufs()
        if nvim_buf_is_valid(buf) && nvim_buf_is_loaded(buf)
            try
                let term_tab_owner = nvim_buf_get_var(buf, "term_tab_owner")
            catch
                let term_tab_owner = -1
            endtry
            let num_windows = len(filter(nvim_tabpage_list_wins(0), "nvim_win_get_buf(v:val)==" . buf))
            if num_windows == 0 && term_tab_owner == page_handle
                execute "buffer " . nvim_buf_get_name(buf)
                return buf
            endif
        endif
    endfor
    terminal
    let b:term_tab_owner = page_handle
endfunction

nnoremap <silent> <leader>S :call SaveTerminal()<cr>
nnoremap <silent> <leader>s :call OpenSavedTerminal()<cr>
nnoremap <silent> <leader>t :botright split<bar>resize 14<bar>setlocal winfixheight<bar>call RecycleTerminal()<cr>
nnoremap <silent> <leader>T :call CloseTerminal()<cr>
