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

imap <BS> <Plug>(PearTreeBackspace)
imap <CR> <Plug>(PearTreeExpand)

inoremap <silent><expr> <C-Space> compe#complete()
inoremap <silent><expr> <CR>      compe#confirm('<CR>')
inoremap <silent><expr> <C-e>     compe#close('<C-e>')
inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })

function! InitCS()
    let l:compe_config = {}
    let l:compe_config.source = {}
    let l:compe_config.source.omni = v:true
    call compe#setup(l:compe_config, 0)
    nmap <silent><buffer> <leader>gd <Plug>(omnisharp_go_to_definition)
    nmap <silent><buffer> <leader>gu <Plug>(omnisharp_find_usages)
    nmap <silent><buffer> <leader>gi <Plug>(omnisharp_find_implementations)
    nmap <silent><buffer> <leader>pd <Plug>(omnisharp_preview_definition)
    nmap <silent><buffer> <leader>pi <Plug>(omnisharp_preview_implementations)
    nmap <silent><buffer> <leader>gt <Plug>(omnisharp_type_lookup)
    nmap <silent><buffer> <leader>k <Plug>(omnisharp_documentation)
    nmap <silent><buffer> <leader>gr <Plug>(omnisharp_find_symbol)
    nmap <silent><buffer> <leader>fu <Plug>(omnisharp_fix_usings)
    nmap <silent><buffer> <C-\> <Plug>(omnisharp_signature_help)
    imap <silent><buffer> <C-\> <Plug>(omnisharp_signature_help)
    nmap <silent><buffer> [[ <Plug>(omnisharp_navigate_up)
    nmap <silent><buffer> ]] <Plug>(omnisharp_navigate_down)
    nmap <silent><buffer> gcc <Plug>(omnisharp_global_code_check)
    nmap <silent><buffer> <leader>a <Plug>(omnisharp_code_actions)
    nmap <silent><buffer> <leader>= <Plug>(omnisharp_code_format)
    nmap <silent><buffer> <leader>rn <Plug>(omnisharp_rename)
endfunction

augroup omnisharp_commands
    autocmd!
    " Show type information automatically when the cursor stops moving.
    " Note that the type is echoed to the Vim command line, and will overwrite
    " any other messages in this space including e.g. ALE linting messages.
    autocmd CursorHold *.cs OmniSharpTypeLookup
    " The following commands are contextual, based on the cursor position.
    autocmd FileType cs call InitCS()
augroup END
