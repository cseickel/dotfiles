nnoremap <silent> <C-t> :tabnew<cr><bar>:Startify<cr>
nnoremap <M-t> :TabooRename
nnoremap <silent> <leader><leader> :BufExplorer<CR>
nnoremap <C-p> :Telescope builtin<cr>

nnoremap <silent> \ :Fern . -reveal=%<CR>
nnoremap <silent> <bar> :Fern . -reveal=% -drawer -toggle<CR>

let $EDITOR="nvr --remote-wait -cc 'call DWM_New()'"
function! BufferDelete() abort
    if winnr('$') > 1
        bd
        call DWM_Focus()
    else
        bd
    endif
endfunction 
nnoremap <silent> <C-n>     :call DWM_New()<bar>Startify<cr>
nmap     <silent> <C-q>     <Plug>DWMClose
nmap     <silent> <M-q>     :call BufferDelete()<cr>
"nmap     <silent> <         <Plug>DWMShrinkMaster
"nmap     <silent> >         <Plug>DWMGrowMaster
nmap     <silent> <C-h>     <Plug>DWMFocus
nmap     <silent> <C-j>     <Plug>DWMMoveDown
nmap     <silent> <C-k>     <Plug>DWMMoveUp
nmap     <silent> <C-l>     <Plug>DWMMoveRight

function! ToggleWindowZoom() abort
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
        if winnr('$') > 1
            let l:top = line("w0")
            let l:line = line(".")
            -1tabedit %
            let b:is_zoomed_win = 1
            execute "normal " . l:top . "zt"
            execute l:line
            execute "TabooRename  " . expand("%:t")
        endif
    endif
endfunction

nnoremap <silent> <leader>wz :call ToggleWindowZoom()<cr>

function! ShowTrouble() abort
    Trouble
    call DWM_MoveRight()
endfunction
nnoremap <silent> <leader>t :call ShowTrouble()<cr>

nnoremap <silent> <C-\> :lua shadow_term_toggle()<cr>

let g:EasyClipUsePasteToggleDefaults = 0

function! FernInit() abort
    setlocal nonumber
    call glyph_palette#apply()
    nmap <buffer><expr>
            \ <Plug>(fern-my-open-expand-collapse)
            \ fern#smart#leaf(
            \   "\<Plug>(fern-action-open)",
            \   "\<Plug>(fern-action-expand)",
            \   "\<Plug>(fern-action-collapse)",
            \ )
    nmap <buffer> <space> <Plug>(fern-my-open-expand-collapse)
    nmap <buffer> <2-LeftMouse> <Plug>(fern-my-open-expand-collapse)
    nnoremap <buffer> \ :b#<cr>
    nnoremap <buffer> <tab> <Plug>(fern-action-mark:toggle)j
    nmap <buffer> F <Plug>(fern-action-new-file)
    nmap <buffer> D <Plug>(fern-action-new-dir)
    nmap <buffer> d <Plug>(fern-action-remove)
    nmap <buffer> m <Plug>(fern-action-move)
    nmap <buffer> r <Plug>(fern-action-rename)
    nmap <buffer> s <Plug>(fern-action-open:split)
    nmap <buffer> v <Plug>(fern-action-open:vsplit)
    nmap <buffer> <F5> <Plug>(fern-action-reload)

    nmap <buffer> <CR>
          \ <Plug>(fern-action-enter)
          \ <Plug>(fern-wait)
          \ <Plug>(fern-action-tcd:root)

    nmap <buffer> <BS>
          \ <Plug>(fern-action-leave)
          \ <Plug>(fern-wait)
          \ <Plug>(fern-action-tcd:root)
endfunction
augroup FernEvents
    autocmd!
    autocmd FileType fern call FernInit()
augroup END


nnoremap <leader>fg  :FzfPreviewGitActions<CR>
nnoremap <leader>fq  :FzfPreviewQuickFix<CR>
nnoremap <leader>fl  :FzfPreviewLocationList<CR>
nnoremap <leader>fb  :FzfPreviewBufferLines<CR>
nnoremap <leader>ff  :<C-u>FzfPreviewProjectGrep<Space>
xnoremap <leader>ff  "sy:FzfPreviewProjectGrep<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"
nnoremap <leader>fo  :execute 'FzfPreviewDirectoryFiles ' . g:owd<CR>

" Mergetool shortcuts
nnoremap <expr> <C-Left> &diff? '<Plug>(MergetoolDiffExchangeLeft)' : '<C-Left>'
nnoremap <expr> <C-Right> &diff? '<Plug>(MergetoolDiffExchangeRight)' : '<C-Right>'
nnoremap <expr> <C-Down> &diff? '<Plug>(MergetoolDiffExchangeDown)' : '<C-Down>'
nnoremap <expr> <C-Up> &diff? '<Plug>(MergetoolDiffExchangeUp)' : '<C-Up>'

"*****************************************************************************
"" LSP Mappings
"*****************************************************************************
imap <silent> <C-Space> <Plug>(completion_trigger)
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <Down>  pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <expr> <Up>    pumvisible() ? "\<C-p>" : "\<Up>"

nnoremap <silent> <leader>gd <cmd>lua vim.lsp.buf.definition()<cr>
nnoremap <silent> <leader>gt <cmd>lua vim.lsp.buf.type_definition()<cr>
nnoremap <silent> <leader>gi <cmd>lua vim.lsp.buf.implementation() <cr>
nnoremap <silent> <leader>gr <cmd>lua vim.lsp.buf.references()<cr>
nnoremap <silent> <leader>n  <cmd>lua vim.lsp.buf.rename()<cr>
nnoremap <silent> <leader>a  <cmd>lua vim.lsp.buf.code_action()<cr>
nnoremap <silent> K          <cmd>lua vim.lsp.buf.hover()<cr>   
nnoremap <silent> <leader>d  <cmd>lua vim.lsp.diagnostic.set_loclist()<cr>
nnoremap <silent> <leader>[  <cmd>lua vim.lsp.diagnostic.goto_prev()<cr>
nnoremap <silent> <leader>]  <cmd>lua vim.lsp.diagnostic.goto_next()<cr>


function! InitCS()
    inoremap <silent><buffer><expr> <C-Space> compe#complete()
    inoremap <silent><buffer><expr> <CR>      compe#confirm('<CR>')
    inoremap <silent><buffer><expr> <C-e>     compe#close('<C-e>')
    inoremap <silent><buffer><expr> <C-f>     compe#scroll({ 'delta': +4 })
    inoremap <silent><buffer><expr> <C-d>     compe#scroll({ 'delta': -4 })

    let l:compe_config = {}
    let l:compe_config.documentation = v:true
    let l:compe_config.min_length = 1
    let l:compe_config.source = {}
    let l:compe_config.source.calc = v:true
    let l:compe_config.source.path = v:true
    let l:compe_config.source.omni = v:true
    let l:compe_config.source.spell = v:true
    let l:compe_config.source.ultisnips = v:false
    call compe#setup(l:compe_config, 0)

    nmap <silent><buffer> <leader>gd <Plug>(omnisharp_go_to_definition)
    nmap <silent><buffer> <leader>gu <Plug>(omnisharp_find_usages)
    nmap <silent><buffer> <leader>gi <Plug>(omnisharp_find_implementations)
    nmap <silent><buffer> <leader>pd <Plug>(omnisharp_preview_definition)
    nmap <silent><buffer> <leader>pi <Plug>(omnisharp_preview_implementations)
    nmap <silent><buffer> <leader>gt <Plug>(omnisharp_type_lookup)
    nmap <silent><buffer> K          <Plug>(omnisharp_documentation)
    nmap <silent><buffer> <leader>gr <Plug>(omnisharp_find_symbol)
    nmap <silent><buffer> <leader>fu <Plug>(omnisharp_fix_usings)
    nmap <silent><buffer> <C-\> <Plug>(omnisharp_signature_help)
    nmap <silent><buffer> [[ <Plug>(omnisharp_navigate_up)
    nmap <silent><buffer> ]] <Plug>(omnisharp_navigate_down)
    nmap <silent><buffer> <leader>t <Plug>(omnisharp_global_code_check)
    nmap <silent><buffer> <leader>a <Plug>(omnisharp_code_actions)
    nmap <silent><buffer> <leader>= <Plug>(omnisharp_code_format)
    nmap <silent><buffer> <leader>n <Plug>(omnisharp_rename)

    nmap <silent> <buffer> <C-k> <Plug>(omnisharp_signature_help)
    imap <silent> <buffer> <C-k> <Plug>(omnisharp_signature_help)

    nmap <silent> <buffer> <Leader>sr <Plug>(omnisharp_restart_server)
    nmap <silent> <buffer> <Leader>ss <Plug>(omnisharp_start_server)
    nmap <silent> <buffer> <Leader>sp <Plug>(omnisharp_stop_server)
endfunction

function! DocHighlight()
    if &ft == 'cs' || &ft == 'csx'
        OmniSharpTypeLookup
    else
        lua vim.lsp.buf.document_highlight()
    endif
endfunction

function! InitSql()
    nnoremap <silent><buffer> <M-x> :%DB $DBUI_URL<cr>
    vnoremap <silent><buffer> <M-x> :DB $DBUI_URL<cr>
    let b:db=$DBUI_URL
endfunction

augroup plugin_mappings_augroup
    autocmd!
    autocmd CursorHold * silent! call DocHighlight()
    autocmd CursorMoved * silent! lua vim.lsp.buf.clear_references()
    autocmd FileType cs call InitCS()
    autocmd FileType csx call InitCS()
    autocmd FileType sql call InitSql() 
augroup END

function! Syn()
  for id in synstack(line("."), col("."))
    echo synIDattr(id, "name")
  endfor
endfunction
command! -nargs=0 Syn call Syn()
