nnoremap <silent> <M-t> :tabnew<cr><bar>:Startify<cr>

let $EDITOR="nvr --remote-wait -cc 'call DWM_New()'"

nnoremap <silent> <C-n>     :call DWM_New()<bar>Startify<cr>
nmap     <silent> <C-q>     <Plug>DWMClose
"nmap     <silent> <         <Plug>DWMShrinkMaster
"nmap     <silent> >         <Plug>DWMGrowMaster
nmap     <silent> <C-h>     <Plug>DWMFocus
nmap     <silent> <C-j>     <Plug>DWMMoveDown
nmap     <silent> <C-k>     <Plug>DWMMoveUp
nmap     <silent> <C-l>     <Plug>DWMMoveRight

imap <c-p> <plug>EasyClipInsertModePaste
cmap <c-p> <plug>EasyClipCommandModePaste

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


nnoremap <silent> <C-\> :ToggleTerm<cr>



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
    autocmd FileType scrollview,terminal execute("MarksToggleSigns" . bufnr('%'))
    "autocmd BufWritePre * undojoin | Neoformat
augroup END

function! Syn()
  for id in synstack(line("."), col("."))
    echo synIDattr(id, "name")
  endfor
endfunction
command! -nargs=0 Syn call Syn()

function! LineNoIndicator() abort
  let g:line_no_indicator_chars = ['⎺', '⎻', '⎼', '⎽']
  let g:line_no_indicator_chars = split('                            ')
  " Zero index line number so 1/3 = 0, 2/3 = 0.5, and 3/3 = 1
  let l:current_line = line('.') - 1
  let l:total_lines = line('$') - 1

  if l:current_line == 0
    let l:index = 0
  elseif l:current_line == l:total_lines
    let l:index = -1
  else
    let l:line_no_fraction = floor(l:current_line) / floor(l:total_lines)
    let l:index = float2nr(l:line_no_fraction * len(g:line_no_indicator_chars))
  endif

  return g:line_no_indicator_chars[l:index]
endfunction
