nnoremap <silent> <C-t> :tabnew<cr><bar>:Startify<cr>
nnoremap <M-t> :TabooRename
nnoremap <silent> <leader><leader> :BufExplorer<CR>
nnoremap <C-p> :Telescope builtin<cr>

nnoremap <silent> \ :Fern . -reveal=%<CR>
nnoremap <silent> <bar> :Fern . -reveal=% -drawer -toggle<CR>

let $EDITOR="nvr --remote-wait -cc 'call DWM_New()'"
nnoremap <silent> <C-n>     :call DWM_New()<bar>Startify<cr>
nmap     <silent> <C-q>     <Plug>DWMClose
"nmap     <silent> <         <Plug>DWMShrinkMaster
"nmap     <silent> >         <Plug>DWMGrowMaster
nmap     <silent> <C-h>     <Plug>DWMFocus
nmap     <silent> <C-j>     <Plug>DWMMoveDown
nmap     <silent> <C-k>     <Plug>DWMMoveUp
nmap     <silent> <C-l>     <Plug>DWMMoveRight

function! MyZoom()
    let l:top = line("w0")
    let l:line = line(".")
    -1tabedit %
    execute "normal " . l:top . "zt"
    execute l:line
    execute "TabooRename " . expand("%:t")
endfunction
nnoremap <silent> Z         :call MyZoom()<cr>

function! MyTrouble()
    Trouble
    call DWM_MoveRight()
endfunction
nnoremap <silent> <leader>t :call MyTrouble()<cr>

let g:EasyClipUsePasteToggleDefaults = 0
nmap <C-f> <plug>EasyClipSwapPasteForward
nmap <C-d> <plug>EasyClipSwapPasteBackwards

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

"Mapping selecting mappings
nmap <leader>fm <Plug>(fzf-maps-n)
xmap <leader>fm <Plug>(fzf-maps-x)
omap <leader>fm <Plug>(fzf-maps-o)

nnoremap <leader>gg :FzfPreviewGitActions<CR>
nnoremap <leader>q  :FzfPreviewQuickFix<CR>
nnoremap <leader>l  :FzfPreviewLocationList<CR>
nnoremap <leader>f  :FzfPreviewBufferLines<CR>
nnoremap <leader>ff :<C-u>FzfPreviewProjectGrep<Space>
xnoremap <leader>ff "sy:FzfPreviewProjectGrep<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"
nnoremap <leader>o  :execute 'FzfPreviewDirectoryFiles ' . g:owd<CR>

" Mergetool shortcuts
nnoremap <expr> <C-Left> &diff? '<Plug>(MergetoolDiffExchangeLeft)' : '<C-Left>'
nnoremap <expr> <C-Right> &diff? '<Plug>(MergetoolDiffExchangeRight)' : '<C-Right>'
nnoremap <expr> <C-Down> &diff? '<Plug>(MergetoolDiffExchangeDown)' : '<C-Down>'
nnoremap <expr> <C-Up> &diff? '<Plug>(MergetoolDiffExchangeUp)' : '<C-Up>'

let g:USE_COC = v:false

if g:USE_COC
    "*****************************************************************************
    "" Coc Mappings
    "*****************************************************************************
    " select the first completion item and confirm the completion when no item has been selected:
    inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>"

    " use <tab> for trigger completion and navigate to the next complete item
    function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~ '\s'
    endfunction

    inoremap <silent><expr> <Tab>
                \ pumvisible() ? "\<C-n>" :
                \ <SID>check_back_space() ? "\<Tab>" :
                \ coc#refresh()

    " use <c-space>for trigger completion
    imap <silent><expr> <c-space> coc#refresh()

    " GoTo code navigation
    nmap <silent> <leader>gd <Plug>(coc-definition)
    nmap <silent> <leader>gt :CocCommand fzf-preview.CocTypeDefinitions<cr>
    nmap <silent> <leader>gi :CocCommand fzf-preview.CocImplementations<cr>
    nmap <silent> <leader>gr :CocCommand fzf-preview.CocReferences<cr>

    " Symbol renaming.
    nmap <leader>rn <Plug>(coc-rename)
    " Remap keys for applying codeAction to the current line.
    nmap <leader>a <Plug>(coc-codeaction-line)
    vmap <leader>a <Plug>(coc-codeaction-selected)

    function! s:show_documentation()
        if &filetype == 'vim'
            execute 'h '.expand('<cword>')
        else 
            call CocAction('doHover')
        endif
    endfunction
    nnoremap <silent> K :call <SID>show_documentation()<CR>
else
    "*****************************************************************************
    "" LSP Mappings
    "*****************************************************************************
    inoremap <silent><expr> <C-Space> compe#complete()
    inoremap <silent><expr> <CR>      compe#confirm('<CR>')
    inoremap <silent><expr> <C-e>     compe#close('<C-e>')
    inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
    inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })

    nnoremap <silent> <leader>gd <cmd>lua vim.lsp.buf.definition()<cr>
    nnoremap <silent> <leader>gt <cmd>lua vim.lsp.buf.type_definition()<cr>
    nnoremap <silent> <leader>gi <cmd>lua vim.lsp.buf.implementation() <cr>
    nnoremap <silent> <leader>gr <cmd>lua vim.lsp.buf.references()<cr>
    nnoremap <silent> <leader>rn <cmd>lua vim.lsp.buf.rename()<cr>
    nnoremap <silent> <leader>a  <cmd>lua vim.lsp.buf.code_action()<cr>
    nnoremap <silent> K          <cmd>lua vim.lsp.buf.hover()<cr>   
    nnoremap <silent> <leader>d  <cmd>lua vim.lsp.diagnostic.set_loclist()<cr>
    nnoremap <silent> <leader>[  <cmd>lua vim.lsp.diagnostic.goto_prev()<cr>
    nnoremap <silent> <leader>]  <cmd>lua vim.lsp.diagnostic.goto_next()<cr>
endif


function! InitCS()
    if !g:USE_COC
        let l:compe_config = {}
        let l:compe_config.documentation = v:true
        let l:compe_config.min_length = 1
        let l:compe_config.source = {}
        let l:compe_config.source.calc = v:true
        let l:compe_config.source.path = v:true
        let l:compe_config.source.omni = v:true
        let l:compe_config.source.spell = v:true
        let l:compe_config.source.ultisnips = v:true
        call compe#setup(l:compe_config, 0)
    endif
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
    nmap <silent><buffer> gcc <Plug>(omnisharp_global_code_check)
    nmap <silent><buffer> <leader>a <Plug>(omnisharp_code_actions)
    nmap <silent><buffer> <leader>= <Plug>(omnisharp_code_format)
    nmap <silent><buffer> <leader>rn <Plug>(omnisharp_rename)
endfunction

function! DocHighlight()
    if &ft == 'cs' || &ft == 'csx'
        OmniSharpTypeLookup
    else 
        if g:USE_COC
            call CocActionAsync('highlight')
        else
            silent! lua vim.lsp.buf.document_highlight()
        endif
    endif
endfunction

function! InitSql()
    nnoremap <silent><buffer> <M-x> :%DB $DBUI_URL<cr>
    vnoremap <silent><buffer> <M-x> :DB $DBUI_URL<cr>
    let b:db=$DBUI_URL
endfunction

augroup plugin_mappings_augroup
    autocmd!
    " Show type information automatically when the cursor stops moving.
    " Note that the type is echoed to the Vim command line, and will overwrite
    " any other messages in this space including e.g. ALE linting messages.
    autocmd CursorHold * call DocHighlight()
    autocmd CursorMoved * lua vim.lsp.buf.clear_references()
    " The following commands are contextual, based on the cursor position.
    autocmd FileType cs call InitCS()
    autocmd FileType csx call InitCS()
    autocmd FileType sql call InitSql() 
augroup END

