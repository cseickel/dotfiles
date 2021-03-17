nnoremap <silent> <C-t> :tabnew<cr><bar>:Startify<cr>
nnoremap <M-t> :TabooRename 
nnoremap <silent> <leader><leader> :BufExplorer<CR>

nnoremap <silent> \ :Fern . -reveal=%<CR>
nnoremap <silent> <bar> :Fern . -reveal=% -drawer -toggle<CR>

nnoremap <silent> <C-n>     :call DWM_New()<bar>Startify<cr>
nmap     <silent> <C-q>     <Plug>DWMClose
nmap     <silent> <         <Plug>DWMShrinkMaster
nmap     <silent> >         <Plug>DWMGrowMaster
nmap     <silent> <C-h>     <Plug>DWMFocus
nmap     <silent> <C-j>     <Plug>DWMMoveDown
nmap     <silent> <C-k>     <Plug>DWMMoveUp
nmap     <silent> <C-l>     <Plug>DWMMoveRight


function! FernInit() abort
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
    nnoremap <buffer> <bar> :b#<cr>
    nnoremap <buffer> <tab> <Plug>(fern-action-mark:toggle)j
    nmap <buffer> F <Plug>(fern-action-new-file)
    nmap <buffer> D <Plug>(fern-action-new-dir)
    nmap <buffer> d <Plug>(fern-action-remove)
    nmap <buffer> m <Plug>(fern-action-move)
    nmap <buffer> r <Plug>(fern-action-rename)
    nmap <buffer> s <Plug>(fern-action-open:split)
    nmap <buffer> v <Plug>(fern-action-open:vsplit)
    nmap <buffer> <F5> <Plug>(fern-action-reload)
endfunction
augroup FernEvents
    autocmd!
    autocmd FileType fern call FernInit()
augroup END

"Mapping selecting mappings
nmap <leader>fm <Plug>(fzf-maps-n)
xmap <leader>fm <Plug>(fzf-maps-x)
omap <leader>fm <Plug>(fzf-maps-o)

nnoremap <leader>ga :FzfPreviewGitActions<CR>
nnoremap <leader>q  :FzfPreviewQuickFix<CR>
nnoremap <leader>l  :FzfPreviewLocationList<CR>
nnoremap <leader>f  :FzfPreviewBufferLines<CR>
nnoremap <leader>rg :<C-u>FzfPreviewProjectGrep<Space>
xnoremap <leader>rg "sy:FzfPreviewProjectGrep<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"

" Mergetool shortcuts
nnoremap <expr> <C-Left> &diff? '<Plug>(MergetoolDiffExchangeLeft)' : '<C-Left>'
nnoremap <expr> <C-Right> &diff? '<Plug>(MergetoolDiffExchangeRight)' : '<C-Right>'
nnoremap <expr> <C-Down> &diff? '<Plug>(MergetoolDiffExchangeDown)' : '<C-Down>'
nnoremap <expr> <C-Up> &diff? '<Plug>(MergetoolDiffExchangeUp)' : '<C-Up>'


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
" Apply AutoFix to problem on the current line.
nmap <leader>fx  <Plug>(coc-fix-current)

" Highlight the symbol and its references when holding the cursor.
augroup coc_commands
    autocmd!
    autocmd CursorHold * silent call CocActionAsync('highlight')
augroup END
augroup omnisharp_commands
    autocmd!

    " Show type information automatically when the cursor stops moving.
    " Note that the type is echoed to the Vim command line, and will overwrite
    " any other messages in this space including e.g. ALE linting messages.
    autocmd CursorHold *.cs OmniSharpTypeLookup

    " The following commands are contextual, based on the cursor position.
    autocmd FileType cs nmap <silent><buffer> <leader>gd <Plug>(omnisharp_go_to_definition)
    autocmd FileType cs nmap <silent><buffer> <leader>gu <Plug>(omnisharp_find_usages)
    autocmd FileType cs nmap <silent><buffer> <leader>gi <Plug>(omnisharp_find_implementations)
    autocmd FileType cs nmap <silent><buffer> <leader>pd <Plug>(omnisharp_preview_definition)
    autocmd FileType cs nmap <silent><buffer> <leader>pi <Plug>(omnisharp_preview_implementations)
    autocmd FileType cs nmap <silent><buffer> <leader>gt <Plug>(omnisharp_type_lookup)
    autocmd FileType cs nmap <silent><buffer> <leader>k <Plug>(omnisharp_documentation)
    autocmd FileType cs nmap <silent><buffer> <leader>gr <Plug>(omnisharp_find_symbol)
    autocmd FileType cs nmap <silent><buffer> <leader>fu <Plug>(omnisharp_fix_usings)
    autocmd FileType cs nmap <silent><buffer> <C-\> <Plug>(omnisharp_signature_help)
    autocmd FileType cs imap <silent><buffer> <C-\> <Plug>(omnisharp_signature_help)

    " Navigate up and down by method/property/field
    autocmd FileType cs nmap <silent><buffer> [[ <Plug>(omnisharp_navigate_up)
    autocmd FileType cs nmap <silent><buffer> ]] <Plug>(omnisharp_navigate_down)
    " Find all code errors/warnings for the current solution and populate the quickfix window
    autocmd FileType cs nmap <silent><buffer> gcc <Plug>(omnisharp_global_code_check)
    " Contextual code actions (uses fzf, vim-clap, CtrlP or unite.vim selector when available)
    autocmd FileType cs nmap <silent><buffer> <leader>a <Plug>(omnisharp_code_actions)

    autocmd FileType cs nmap <silent><buffer> <leader>= <Plug>(omnisharp_code_format)

    autocmd FileType cs nmap <silent><buffer> <leader>rn <Plug>(omnisharp_rename)
augroup END



imap <BS> <Plug>(PearTreeBackspace)
imap <CR> <Plug>(PearTreeExpand)
