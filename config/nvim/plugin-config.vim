"set foldmethod=expr
"set foldexpr=nvim_treesitter#foldexpr()

" configure nvcode-color-schemes
let g:nvcodetermcolors=256

" checks if your terminal has 24-bit color support
if (has("termguicolors"))
    set termguicolors
    hi LineNr ctermbg=NONE guibg=NONE
endif

" Theme
"colorscheme dark_plus
colorscheme nvcode "<-- this one is best with tree-sitter

let g:gitgutter_map_keys = 0
let g:airline_powerline_fonts = 1
let g:airline_theme = 'tender'

" IndentLine
let g:indentLine_color_term = 236
let g:indentLine_color_gui = '#303030'
let g:indentLine_enabled = 1
"let g:indentLine_concealcursor = 0
let g:indentLine_char = '▏'
"let g:indentLine_char_list = ['│','┆','┊','⋮',':', '·', '·', '·', '·']
let g:indentLine_faster = 1
let g:indent_blankline_space_char = ' '
let g:indent_blankline_space_char_blankline = ' '
let g:indent_blankline_use_treesitter = v:true
let g:indentLine_fileTypeExclude = [ "NvimTree" ]

" ntpeters/vim-better-whitespace
let g:beter_whitespace_enabled=1
let g:better_whitespace_ctermcolor=236
let g:strip_whitespace_on_save=1
let g:strip_whitelines_at_eof=1
let g:strip_whitespace_confirm=0
let g:better_whitespace_filetypes_blacklist=[
    \'diff', 'gitcommit','unite', 'qf', 'help', 'markdown', 'vim']

" vim-airline
let g:airline#extensions#branch#enabled = 0
let g:airline#extensions#ale#enabled = 0
let g:airline#extensions#nvimlsp#enabled = 1
let g:airline#extensions#tabline#enabled = 0
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline_skip_empty_sections = 1
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'
let g:airline_inactive_collapse=1
let g:airline_section_c="%{GetFileName()} %m"
let g:airline_section_x=""
let g:airline_section_z="☰ %3l/%-3L c:%-2c"
"let g:airline#extensions#branch#displayed_head_limit = 30
let g:airline#extensions#branch#format = 2

function! GetFileName()
    if expand('%') =~ "term://"
        return 'TERMINAL'
    elseif &ft == 'fern'
        return 'fern'
    else
        if expand("%:t") =~ '.space-filler.'
            return expand("#:f")
        else
            return expand('%:f')
        endif
    endif
endfunction
function! Custom_Inactive(...)
    let builder = a:1
    let context = a:2

    call builder.add_section('airline_a', ' %{tabpagewinnr(tabpagenr())} ')
    call builder.add_section('airline_c', 
        \" %{GetFileName()} %m%=%{WebDevIconsGetFileTypeSymbol()} ")

    "return 0   " the default: draw the rest of the statusline
    return 1   " modify the statusline with the current contents of the builder
endfunction
call airline#add_inactive_statusline_func('Custom_Inactive')

let g:webdevicons_enable_airline_statusline = 1
let g:webdevicons_enable_startify = 1

let g:nvim_tree_width = 40
let g:nvim_tree_tab_open = 1
let g:nvim_tree_gitignore = 1
let g:nvim_tree_follow = 1 "0 by default, this option allows the cursor to be updated when entering a buffer
let g:nvim_tree_indent_markers = 0 "0 by default, this option shows indent markers when folders are open
let g:nvim_tree_hide_dotfiles = 0 "0 by default, this option hides files and folders starting with a dot `.`
let g:nvim_tree_show_icons = {
            \ 'git': 0,
            \ 'folders': 1,
            \ 'files': 1,
            \ 'folder_arrows': 1,
            \}
let g:nvim_tree_git_hl = 1 "0 by default, will enable file highlight for git attributes (can be used without the icons).
let g:nvim_tree_highlight_opened_files = 0
let g:nvim_tree_lsp_diagnostics = 1 "0 by default, will show lsp diagnostics in the signcolumn. See :help nvim_tree_lsp_diagnostics
let g:nvim_tree_disable_window_picker = 0 "0 by default, will disable the window picker.
let g:nvim_tree_hijack_cursor = 1
let g:nvim_tree_icons = { "default" : "" }


highlight CursorLine guibg=#363636
highlight NvimTreeOpenedFile gui=italic
highlight NvimTreeNormal guibg=#202020 guifg=#cbcbcb
highlight NvimTreeNormalNC guibg=#262626 guifg=#cbcbcb
highlight NvimTreeIndentMarker guifg=#404040
highlight NvimTreeGitStaged guifg=#d7af5f gui=BOLD
highlight NvimTreeGitDirty guifg=#d7af5f gui=BOLD
highlight NvimTreeGitNew guifg=#c95555 gui=BOLD
highlight GitSignsChange guifg=#d7af5f 
highlight GitSignsAdd guifg=#5faf5f

" Tab styling
"let g:taboo_tab_format=" %d %f %m %x⎹"
let g:taboo_tab_format=" %d%U .../%P %m %x▕"
let g:taboo_renamed_tab_format=" %d %l %m %x▕"
let g:taboo_close_tab_label = ""
let g:taboo_modified_tab_flag="פֿ"

hi TabLine guifg=#bbbbbb ctermfg=246 guibg=#444444 ctermbg=238 gui=NONE cterm=NONE
hi TabLineFill guifg=NONE ctermfg=NONE guibg=#444444 ctermbg=238 gui=NONE cterm=NONE
hi TabLineSel guifg=#73cef4 ctermfg=185 guibg=NONE ctermbg=NONE gui=Bold cterm=Bold
hi TabModified guifg=#d7d787 ctermfg=186 guibg=#444444 ctermbg=238 gui=NONE cterm=NONE
hi TabModifiedSelected guifg=#c9d05c ctermfg=185 guibg=NONE ctermbg=NONE gui=Bold cterm=Bold

" dwm tiling window manager
let g:dwm_master_pane_width = 90
let g:dwm_map_keys=0

let g:scrollview_current_only=1
let g:scrollview_winblend=60
let g:scrollview_column=1

let g:chadtree_settings = { "theme": { "text_colour_set": "nord" } }


" typescript
let g:yats_host_keyword = 1


" clipboard settings
set clipboard=unnamed,unnamedplus
let g:EasyClipAutoFormat=1
let g:EasyClipAlwaysMoveCursorToEndOfPaste=1
let g:EasyClipPreserveCursorPositionAfterYank=1
let g:EasyClipShareYanks=1
let g:EasyClipUseSubstituteDefaults=0


" vim-closetag config
let g:closetag_filenames = '*.html,*.xhtml,*.phtml'
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx'
let g:closetag_filetypes = 'html,xhtml,phtml'
let g:closetag_xhtml_filetypes = 'xhtml,jsx'
let g:closetag_emptyTags_caseSensitive = 1
let g:closetag_regions = {
            \ 'typescript.tsx': 'jsxRegion,tsxRegion',
            \ 'javascript.jsx': 'jsxRegion',
            \ }
let g:closetag_shortcut = '>'
" Add > at current position without closing the current tag,
let g:closetag_close_shortcut = '<leader>>'


" Omnisharp Settings
let g:OmniSharp_fzf_options = { 'down': '30%' } " max 30% of the screen height
"let g:OmniSharp_fzf_options = { 'down': '12' }  " max 12 lines high
"let g:OmniSharp_fzf_options = { 'right': '50%' } " vertical split


" Tell ALE to use OmniSharp for linting C# files, and no other linters.
let g:ale_linters = { 'cs': ['OmniSharp'] }

let g:sharpenup_create_mappings = 0
let g:OmniSharp_popup_options = {
            \ 'winhl': 'Normal:NormalFloat'
            \}
" Enable snippet completion, using the ultisnips plugin
let g:OmniSharp_want_snippet=1

"*****************************************************************************
"" Fern File Tree
"*****************************************************************************
let g:fern#renderer = "nerdfont"
" Add dirs and files inside the brackets that need to remain hidden
let hide_dirs  = '^\%(\.git\|node_modules\)$'  " here you write the dir names 
let hide_files = '\%(\.d\.ts\|\.js\)$'    " here you write the file names
let g:fern#disable_drawer_auto_resize=1
let g:fern#default_exclude = hide_dirs . '\|' . hide_files  " here you exclude them

let g:bufExplorerShowRelativePath=1
let g:bufExplorerShowTabBuffer=1
let g:bufExplorerSortBy='fullpath'
let g:bufExplorerDisableDefaultKeyMapping=1

let g:vista_ignore_kinds=["Variable", "Constant", "Property"]
let g:vista_default_executive="nvim_lsp"

let g:sharpenup_create_mappings = 0
let g:OmniSharp_highlighting = 0
let g:completion_auto_change_source = 0

" colorizer
"let g:Hexokinase_highlighters = ['foregroundfull']
function! s:sortBufferInfo(leftArg, rightArg)
  if a:leftArg['name'] == a:rightArg['name']
    return 0
  elseif a:leftArg['name'] < a:rightArg['name']
    return -1
  else
    return 1
  endif
endfunction
function! s:getHiddenBuffers()
    let buffers = filter(getbufinfo({'buflisted': 1}), 'len(v:val.windows) < 1 && get(v:val, "name", "") > ""')
    call sort(buffers, function('s:sortBufferInfo'))
    return map(buffers, '{"cmd": "b" . v:val.bufnr, "line": fnamemodify(v:val.name, ":~:.")}')
endfunction

function! CustomStartifyBeforeSave() abort
    for win in nvim_list_wins()
        " close floating windows
        if nvim_win_get_config(win).relative > ""
            call nvim_win_close(win, 1)
        else
            " close tree drawer plugins
            let l:ft = nvim_buf_get_option(nvim_win_get_buf(win), "ft")
            if l:ft =~ "tree" || l:ft == "fern"
                call nvim_win_close(win, 1)
            endif
        endif
    endfor
endfunction

" Startify
let g:startify_commands = [
            \ { 't': ['Open Terminal', 'call RecycleTerminal()'] },
            \ { 'f': ['Find Files', 'Telescope find_files'] },
            \ ]

let g:startify_lists = [
            \ { 'header': ['   Commands'],       'type': 'commands' },
            \ { 'header': ['   Hidden Buffers'], 'type': function("s:getHiddenBuffers") },
            \ { 'header': ['   Sessions'],       'type': 'sessions' },
            \ { 'header': ['   MRU '. getcwd()], 'type': 'dir' },
            \ ]
let g:startify_session_delete_buffers = 0
let g:startify_session_autoload = 1
let g:startify_session_persistence = 1
let g:startify_session_before_save = ['call CustomStartifyBeforeSave()']
let g:startify_fortune_use_unicode = 1
let g:startify_change_cmd = 'tcd'
let g:startify_change_to_dir = 1
let g:startify_session_savevars = ['g:Taboo_tabs', 't:taboo_tab_name',
            \ 't:terminal', 'g:terminal', 'w:terminal']

set sessionoptions=blank,curdir,folds,help,tabpages,winpos


"fzf preview
let g:fzf_preview_command = 'bat --color=always --plain {-1}'
let g:fzf_preview_lines_command = 'bat --color=always --plain --number'
let g:fzf_preview_use_dev_icons = 1
let g:fzf_preview_dev_icon_prefix_string_length = 2

" Devicons can make fzf-preview slow when the number of results is high
" By default icons are disable when number of results is higher that 5000
let g:fzf_preview_dev_icons_limit = 5000

" The theme used in the bat preview
let $FZF_PREVIEW_PREVIEW_BAT_THEME = 'OneHalfDark'

let g:db_ui_use_nerd_fonts = 1

" Pair expansion is dot-repeatable by default:
let g:pear_tree_repeatable_expand = 0
let g:pear_tree_smart_openers = 1
let g:pear_tree_smart_closers = 1
let g:pear_tree_smart_backspace = 1
let g:pear_tree_map_special_keys = 0

let g:completion_enable_snippet = 'UltiSnips'
" Avoid showing message extra message when using completion
set shortmess+=c


let g:vimade = { "fadelevel": 0.77 }

" Style vertical split bar
"set fillchars+=vert:▏
"set fillchars+=vert:▍
"set fillchars+=vert:▉
"set fillchars+=vert:▕
set fillchars+=vert:█
highlight VertSplit gui=None cterm=None guifg=#444444 ctermfg=238 guibg=#222222
highlight MatchParen gui=BOLD guifg=#ffaf00 guibg=#444444
" nvcode overrides from dark+
highlight Comment ctermfg=0 guifg=#505050 cterm=italic gui=italic

highlight ALEInfoSign ctermbg=None guibg=None cterm=NONE gui=NONE
highlight ALEErrorSign ctermbg=None guibg=None cterm=NONE gui=NONE
highlight ALEWarningSign ctermbg=None guibg=None cterm=NONE gui=NONE
highlight ALEStyleErrorSign ctermbg=None guibg=None cterm=NONE gui=NONE
highlight ALEStyleWarningSign ctermbg=None guibg=None cterm=NONE gui=NONE

highlight GitGutterAdd cterm=NONE gui=NONE guibg=None ctermbg=None
highlight GitGutterAddLine cterm=NONE gui=NONE guibg=None ctermbg=None
highlight GitGutterChange cterm=NONE gui=NONE guibg=None ctermbg=None
highlight GitGutterChangeLine cterm=NONE gui=NONE guibg=None ctermbg=None
highlight GitGutterDelete cterm=NONE gui=NONE guibg=None ctermbg=None
highlight GitGutterDeleteLine cterm=NONE gui=NONE guibg=None ctermbg=None
highlight GitGutterChangeDelete cterm=NONE gui=NONE guibg=None ctermbg=None
highlight GitGutterChangeDeleteLine cterm=NONE gui=NONE guibg=None ctermbg=None

hi TSVariableBuiltin guifg=#c586c0 ctermfg=175 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE

highlight StartifyFile ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight StartifyBracket ctermfg=0 guifg=#1e1e1e cterm=NONE gui=NONE
highlight StartifySlash ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight StartifyPath ctermfg=0 guifg=#505050 cterm=NONE gui=NONE

hi LspTroubleText guibg=none ctermbg=none ctermfg=244 guifg=#abb2bf
hi LspReferenceText cterm=underline gui=bold guibg=#404040
hi LspReferenceRead cterm=underline gui=bold guibg=#404040
hi LspReferenceWrite cterm=underline gui=bold guibg=#404040
hi link vimUserFunc none

hi Normal guibg=#1c1c1c
highlight NormalNC guibg=#262626
highlight link NormalFloat NormalNC
highlight TroubleNormal guibg=none ctermbg=none
highlight TroubleText guibg=#262626
highlight EndOfBuffer guifg=#1c1c1c guibg=None ctermfg=None ctermbg=None
highlight LineNR guibg=None ctermbg=None
highlight SignColumn ctermbg=None guibg=None cterm=NONE gui=NONE
highlight CursorLineNr ctermfg=2 guifg=#608b4e ctermbg=None guibg=None


highlight Cursor guibg=#5f87af ctermbg=67
highlight iCursor guibg=#ffffaf ctermbg=229
highlight rCursor guibg=#af0000 ctermbg=124

highlight Type ctermfg=6 guifg=#4ec9b0
highlight link This Language
highlight link New Constant
highlight link Interpolation Identifier
highlight link InterpolationDelim Constant
highlight link DocComment SpecialComment
highlight link DocExample Identifier
highlight link DocString Identifier
highlight link Operator Conditional
highlight link OperLambda Conditional
highlight link Modifier Conditional
highlight link LinqKeyword Conditional

" highlight link csUnspecifiedStatement PlainText
" highlight link csContextualStatement Control
" highlight link csUnsupportedStatement PlainText
