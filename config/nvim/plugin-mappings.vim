nnoremap <silent> <M-t> :tabnew<cr><bar>:Startify<cr>

imap <c-p> <C-o>p
cmap <c-p> <C-r>0

imap <silent><script><expr> <C-j> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true


function! ToggleWindowZoom(clear_decorations) abort
    if exists("b:is_zoomed_win") && b:is_zoomed_win
        unlet b:is_zoomed_win
        let l:name = expand("%:p")
        let l:top = line("w0")
        let l:line = line(".")
        tabclose
        let windowNr = bufwinnr(l:name)
        if windowNr > 0
            execute windowNr 'wincmd w'
            execute "normal " . l:top . "zt"
            execute l:line
        endif
    else
        if winnr('$') > 1 || a:clear_decorations
            let l:top = line("w0")
            let l:line = line(".")
            -1tabedit %
            let b:is_zoomed_win = 1
            execute "normal " . l:top . "zt"
            execute l:line
            execute "TabooRename  " . expand("%:t")
        endif
        if a:clear_decorations
            set nonumber
            set signcolumn=no
            IndentBlanklineDisable
        endif
    endif
endfunction

function! CloseAllTools()
    call CloseTerminal()
    cclose
    lclose
    redraw
endfunction




"*****************************************************************************
"" LSP Mappings
"*****************************************************************************
nnoremap <silent>       K         :lua vim.lsp.buf.hover()<cr>

function! InitSql()
    nnoremap <silent><buffer> <M-x> :%DB $DBUI_URL<cr>
    vnoremap <silent><buffer> <M-x> :DB $DBUI_URL<cr>
    let b:db=$DBUI_URL
endfunction

function! Highlight_Symbol() abort
    if &ft != "cs"
        lua vim.lsp.buf.document_highlight()
    endif
endfunction


augroup plugin_mappings_augroup
    autocmd!
    autocmd CursorHold * silent! call Highlight_Symbol()
    autocmd CursorMoved * silent! lua vim.lsp.buf.clear_references()
    autocmd FileType typescript,javascript nnoremap <buffer><leader>= :lua vim.lsp.buf.formatting()<cr>
    autocmd FileType sql call InitSql()
    autocmd FileType qf,Trouble silent! call CloseAllTools()
    autocmd FileType Trouble setlocal cursorline
    autocmd FileType json nnoremap <buffer> <leader>= :%!python -m json.tool<cr>
    "autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is 'c' | execute 'OSCYankReg c' | endif
    "autocmd BufWritePre * undojoin | Neoformat
augroup END

function! Syn()
  for id in synstack(line("."), col("."))
    echo synIDattr(id, "name")
  endfor
endfunction
command! -nargs=0 Syn call Syn()


function! DeleteBuffer() abort
    BufSurfBack
    bd#
endfunction

nnoremap <silent> <M-q>     :call DeleteBuffer()<cr>
