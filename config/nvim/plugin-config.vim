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

" let g:oscyank_term = 'default' " or 'tmux' or 'screen', 'kitty', 'default'
" IndentLine
let g:webdevicons_enable_startify = 1

let g:nvim_tree_gitignore = 1
let g:nvim_tree_show_icons = {
            \ 'git': 0,
            \ 'folders': 1,
            \ 'files': 1,
            \ 'folder_arrows': 0,
            \}
let g:nvim_tree_git_hl = 1 "0 by default, will enable file highlight for git attributes (can be used without the icons).
let g:nvim_tree_highlight_opened_files = 2
let g:nvim_tree_icons = { "default" : "" }

highlight NvimTreeCursorLine guibg=#3a3a3a gui=bold
highlight NvimTreeOpenedFile guifg=#d7af5f gui=bold
highlight NvimTreeNormal guibg=#202020 guifg=#cbcbcb
highlight NvimTreeNormalNC guibg=#262626 guifg=#cbcbcb
highlight NvimTreeIndentMarker guifg=#404040
highlight NvimTreeGitMerge guifg=#ff5900 gui=Bold,Italic
highlight NvimTreeGitStaged guifg=none gui=Italic
highlight NvimTreeGitDirty guifg=none gui=Italic
highlight NvimTreeGitNew guifg=none gui=Italic
highlight NvimTreeSpecialFile ctermfg=none guifg=none gui=Bold

" disable the default highlight group
let g:conflict_marker_highlight_group = ''
let g:conflict_marker_enable_mappings = 0

" Include text after begin and end markers in Highlights
let g:conflict_marker_begin = '^<<<<<<< .*$'
let g:conflict_marker_end   = '^>>>>>>> .*$'

highlight ConflictMarkerBegin guibg=#00875f
highlight ConflictMarkerOurs guibg=#005f5f
highlight ConflictMarkerTheirs guibg=#005f87
highlight ConflictMarkerEnd guibg=#5f87af
highlight ConflictMarkerCommonAncestorsHunk guibg=#754a81



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

"let g:scrollview_current_only=1
let g:scrollview_winblend=60
let g:scrollview_column=1


" clipboard settings
set clipboard=unnamedplus


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


let g:bufExplorerShowRelativePath=1
let g:bufExplorerShowTabBuffer=1
let g:bufExplorerSortBy='fullpath'
let g:bufExplorerDisableDefaultKeyMapping=1

let g:EditorConfig_max_line_indicator="fill"
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
            " close drawer and tool windows
            let l:ft = nvim_buf_get_option(nvim_win_get_buf(win), "ft")
            if l:ft =~ "tree" || l:ft == "fern" || l:ft == "Trouble"
                call nvim_win_close(win, 1)
            endif
        endif
    endfor
endfunction

" Startify
let g:startify_lists = [
            \ { 'header': ['   Hidden Buffers'], 'type': function("s:getHiddenBuffers") },
            \ { 'header': ['   Sessions'],       'type': 'sessions' },
            \ { 'header': ['   MRU '. g:owd], 'type': 'dir' },
            \ ]
let g:startify_session_delete_buffers = 1
let g:startify_session_autoload = 1
let g:startify_session_persistence = 1
let g:startify_session_before_save = ['call CustomStartifyBeforeSave()']
let g:startify_fortune_use_unicode = 1
let g:startify_change_cmd = 'tcd'
let g:startify_change_to_dir = 1
let g:startify_session_savevars = ['g:Taboo_tabs', 't:taboo_tab_name',
            \ 't:terminal', 'g:terminal', 'w:terminal']

set sessionoptions=curdir,tabpages,winpos,buffers


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
highlight clear FloatBorder
highlight link FloatBorder VertSplit

highlight MatchParen gui=BOLD guifg=#ffaf00 guibg=#444444
" nvcode overrides from dark+
highlight Comment ctermfg=0 guifg=#505050 cterm=italic gui=italic
highlight TSComment none
highlight link TSComment Comment

highlight ALEInfoSign ctermbg=None guibg=None cterm=NONE gui=NONE
highlight ALEErrorSign ctermbg=None guibg=None cterm=NONE gui=NONE
highlight ALEWarningSign ctermbg=None guibg=None cterm=NONE gui=NONE
highlight ALEStyleErrorSign ctermbg=None guibg=None cterm=NONE gui=NONE
highlight ALEStyleWarningSign ctermbg=None guibg=None cterm=NONE gui=NONE

highlight GitGutterAdd cterm=NONE gui=NONE guibg=None ctermbg=None guifg=#5faf5f
highlight GitGutterAddLine cterm=NONE gui=NONE guibg=None ctermbg=None
highlight GitGutterChange cterm=NONE gui=NONE guibg=None ctermbg=None guifg=#d7af5f
highlight GitGutterChangeLine cterm=NONE gui=NONE guibg=None ctermbg=None
highlight GitGutterDelete cterm=NONE gui=NONE guibg=None ctermbg=None guifg=#ff5555 gui=Bold 
highlight GitGutterDeleteLine cterm=NONE gui=NONE guibg=None ctermbg=None
highlight GitGutterChangeDelete cterm=NONE gui=NONE guibg=None ctermbg=None guifg=#c97755 gui=Bold
highlight GitGutterChangeDeleteLine cterm=NONE gui=NONE guibg=None ctermbg=None

" for nvim-cmp
highlight CmpItemAbbr guifg=#949494

highlight TSVariableBuiltin guifg=#c586c0 ctermfg=175 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE

highlight StartifyFile ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight StartifyBracket ctermfg=0 guifg=#1e1e1e cterm=NONE gui=NONE
highlight StartifySlash ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight StartifyPath ctermfg=0 guifg=#505050 cterm=NONE gui=NONE

hi TroubleText none
hi LspTroubleText guibg=none ctermbg=none ctermfg=244 guifg=#abb2bf
hi LspReferenceText cterm=underline gui=bold guibg=#404040
hi LspReferenceRead cterm=underline gui=bold guibg=#404040
hi LspReferenceWrite cterm=underline gui=bold guibg=#404040

hi LspDiagnosticsVirtualTextError none
hi LspDiagnosticsVirtualTextWarning none
hi LspDiagnosticsVirtualTextInformation none
hi LspDiagnosticsVirtualTextHint none
hi LspDiagnosticsDefaultWarning guifg=#d7d700 gui=Italic
hi LspDiagnosticsDefaultInformation guifg=#87d7ff gui=Italic
hi LspDiagnosticsDefaultHint guifg=#ffffd7 gui=Italic
hi LspDiagnosticsDefaultError guifg=#d70000 gui=Italic,Bold
hi link vimUserFunc none

hi Normal guibg=#1c1c1c
highlight NormalNC guibg=#262626
highlight link NormalFloat NormalNC
highlight TroubleNormal guibg=none ctermbg=none
highlight TroubleText guibg=#262626
highlight EndOfBuffer guifg=#1c1c1c guibg=None ctermfg=None ctermbg=None
highlight SignColumn ctermbg=None guibg=None cterm=NONE gui=NONE
highlight LineNR guibg=None ctermbg=None
highlight CursorLineNr guibg=#262626 guifg=#a8a8a8 gui=bold
highlight CursorLine guibg=#262626
highlight ColorColumn guibg=#262626


highlight Cursor guibg=#5f87af ctermbg=67
highlight iCursor guibg=#ffffaf ctermbg=229
highlight rCursor guibg=#d70000 ctermbg=124

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

highlight SidebarNvimNormal ctermfg=249 guifg=#abb2bf 
highlight link SidebarNvimGitStatusFileName SidebarNvimNormal
highlight link SidebarNvimLspDiagnosticsMessage SidebarNvimNormal
highlight link SidebarNvimDockerContainerName SidebarNvimNormal
highlight link SidebarNvimDatetimeClockValue SidebarNvimNormal

" Colors for nvim-cmp completion menu
" gray
highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080
" blue
highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6
highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#569CD6
" light blue
highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE
highlight! CmpItemKindInterface guibg=NONE guifg=#9CDCFE
highlight! CmpItemKindText guibg=NONE guifg=#9CDCFE
" pink
highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0
highlight! CmpItemKindMethod guibg=NONE guifg=#C586C0
" front
highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
highlight! CmpItemKindProperty guibg=NONE guifg=#D4D4D4
highlight! CmpItemKindUnit guibg=NONE guifg=#D4D4D4

" highlight link csUnspecifiedStatement PlainText
" highlight link csContextualStatement Control
" highlight link csUnsupportedStatement PlainText
