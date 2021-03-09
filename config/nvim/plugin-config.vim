
" Theme
colorscheme dark_plus
let g:airline_powerline_fonts = 1
"let g:airline_theme = 'codedark'
"let g:airline_theme = 'dark_plus'
"let g:airline_theme = 'bubblegum'
let g:airline_theme = 'tender'


" IndentLine
let g:indentLine_color_term = 236
let g:indentLine_color_gui = '#303030'
let g:indentLine_enabled = 1
"let g:indentLine_concealcursor = 0
let g:indentLine_char = '▏'
"let g:indentLine_char_list = ['│','┆','┊','⋮',':', '·', '·', '·', '·']
let g:indentLine_faster = 1


" ntpeters/vim-better-whitespace
let g:beter_whitespace_enabled=1
let g:better_whitespace_ctermcolor=236
let g:strip_whitespace_on_save=1
let g:strip_whitelines_at_eof=1
let g:strip_whitespace_confirm=0
let g:better_whitespace_filetypes_blacklist=[
    \'diff', 'gitcommit','unite', 'qf', 'help', 'markdown', 'vim']

" vim-airline
let g:airline#extensions#branch#enabled = 1 
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tabline#enabled = 0
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline_skip_empty_sections = 1
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'
let g:airline_inactive_collapse=1
let g:airline_section_c="%{GetFileName()} %m"
let g:airline_section_z="☰ %3l/%-3L c:%-2c"


function! GetFileName()
    if expand('%') =~ "term://"
        return 'TERMINAL'
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
        \" %{GetFileName()} %m%=%{&l:ft} %{WebDevIconsGetFileTypeSymbol()} ")

    "return 0   " the default: draw the rest of the statusline
    return 1   " modify the statusline with the current contents of the builder
endfunction
call airline#add_inactive_statusline_func('Custom_Inactive')

let g:webdevicons_enable_airline_statusline = 1
let g:webdevicons_enable_startify = 1

" Tab styling
"let g:taboo_tab_format=" %d %f %m %x⎹"
let g:taboo_tab_format=" %d%U .../%P %m %x⎹"
let g:taboo_renamed_tab_format=" %l %m %x⎹"
let g:taboo_close_tab_label = ""
let g:taboo_modified_tab_flag="פֿ"

hi TabLine guifg=#bbbbbb ctermfg=246 guibg=#444444 ctermbg=238 gui=NONE cterm=NONE
hi TabLineFill guifg=NONE ctermfg=NONE guibg=#444444 ctermbg=238 gui=NONE cterm=NONE
hi TabLineSel guifg=#73cef4 ctermfg=185 guibg=NONE ctermbg=NONE gui=Bold cterm=Bold
hi TabModified guifg=#d7d787 ctermfg=186 guibg=#444444 ctermbg=238 gui=NONE cterm=NONE
hi TabModifiedSelected guifg=#c9d05c ctermfg=185 guibg=NONE ctermbg=NONE gui=Bold cterm=Bold

" dwm tiling window manager
let g:dwm_master_pane_width = "60"
let g:dwm_map_keys=0


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
" let g:OmniSharp_want_snippet=1

"*****************************************************************************
"" Fern File Tree
"*****************************************************************************
let g:fern#renderer = "nerdfont"

" Buffeur Explorer
let g:bufExplorerShowRelativePath=1
let g:bufExplorerShowTabBuffer=1
let g:bufExplorerSortBy='fullpath'
let g:bufExplorerDisableDefaultKeyMapping=1


" colorizer
let g:Hexokinase_highlighters = ['foregroundfull']


" Startify
let g:startify_commands = [
            \ { 't': ['Open Terminal', 'terminal'] },
            \ { '-': ['Browse Directory', 'Fern .'] }
            \ ]

let g:startify_lists = [
            \ { 'header': ['   Commands'],       'type': 'commands' },
            \ { 'header': ['   Sessions'],       'type': 'sessions' },
            \ { 'header': ['   MRU '. getcwd()], 'type': 'dir' },
            \ ]
let g:startify_session_delete_buffers = 0
let g:startify_session_autoload = 1
let g:startify_session_persistence = 1
"let g:startify_session_before_save = ['tabdo MinimapClose']
let g:startify_fortune_use_unicode = 1
let g:startify_change_cmd = 'tcd'
let g:startify_change_to_dir = 1
let g:startify_session_savevars = ['g:Taboo_tabs', 't:taboo_tab_name',
            \ 't:terminal', 'g:terminal', 'w:terminal']

set sessionoptions=blank,curdir,folds,help,tabpages,winpos

" Minimap
"let g:minimap_width=8
"let g:minimap_auto_start=1
"let g:minimap_auto_start_win_enter=1


" vim-quickui menus
let g:quickui_border_style = 2
let g:quickui_color_scheme = 'papercol dark'


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

"Togle Terminal
let g:auto_start_insert = 0
let g:preserve_alternate_buffer=0

let g:db_ui_use_nerd_fonts = 1

let g:scrollview_winblend = 92
let g:scrollview_column = 1
let g:scrollview_current_only = 1

let g:vimade = {
    \ "fadelevel": 0.77,
    \ "basebg": "#000000"
\ }


" Pair expansion is dot-repeatable by default:
let g:pear_tree_repeatable_expand = 0
let g:pear_tree_smart_openers = 1
let g:pear_tree_smart_closers = 1
let g:pear_tree_smart_backspace = 1
let g:pear_tree_map_special_keys = 0

function! InitTerminal()
    setlocal nonumber norelativenumber noruler
    setlocal autowriteall modifiable
    VimadeBufDisable
endfunction

augroup terminal_autocmd
    autocmd!
    autocmd TermOpen * call InitTerminal()
augroup END
