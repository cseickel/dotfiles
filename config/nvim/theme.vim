let g:db_ui_use_nerd_fonts = 1

" checks if your terminal has 24-bit color support
if (has("termguicolors"))
    set termguicolors
    hi LineNr ctermbg=NONE guibg=NONE
endif

" Style vertical split bar
set fillchars=horiz:━
set fillchars+=horizup:┻
set fillchars+=horizdown:┳
set fillchars+=vert:┃
set fillchars+=vertleft:┫
set fillchars+=vertright:┣
set fillchars+=verthoriz:╋


highlight WinSeparator guifg=#3c3c52
highlight FloatBorder guifg=#b8b8e6

hi TabLine guifg=#bbbbbb ctermfg=246 guibg=#444444 ctermbg=238 gui=NONE cterm=NONE
hi TabLineFill guifg=NONE ctermfg=NONE guibg=#444444 ctermbg=238 gui=NONE cterm=NONE
hi TabLineSel guifg=#73cef4 ctermfg=185 guibg=NONE ctermbg=NONE gui=Bold cterm=Bold
hi TabModified guifg=#d7d787 ctermfg=186 guibg=#444444 ctermbg=238 gui=NONE cterm=NONE
hi TabModifiedSelected guifg=#c9d05c ctermfg=185 guibg=NONE ctermbg=NONE gui=Bold cterm=Bold

highlight MatchParen gui=BOLD guifg=#ffaf00 guibg=#444444
hi FlashCurrent guifg=#ffaf00 gui=Bold
hi FlashBackdrop guifg=#666666
hi FlashMatch guifg=#EEEEEE
hi FlashLabel guifg=#ff5555 guibg=#000000 gui=Bold
hi Search guibg=#444444 gui=Bold

highlight ALEInfoSign ctermbg=None guibg=None cterm=NONE gui=NONE
highlight ALEErrorSign ctermbg=None guibg=None cterm=NONE gui=NONE
highlight ALEWarningSign ctermbg=None guibg=None cterm=NONE gui=NONE
highlight ALEStyleErrorSign ctermbg=None guibg=None cterm=NONE gui=NONE
highlight ALEStyleWarningSign ctermbg=None guibg=None cterm=NONE gui=NONE

highlight GitGutterAdd               guifg=#5faf5f
highlight GitGutterChange            guifg=#d7af5f
highlight GitGutterDelete            guifg=#ff5555
highlight GitGutterChangeDelete      guifg=#c97755


highlight TSVariableBuiltin guifg=#c586c0 ctermfg=175 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE

hi DiagnosticWarn guifg=#d7d700 gui=Italic
hi DiagnosticInfo guifg=#87d7ff gui=Italic
hi DiagnosticHint guifg=#ffffd7 gui=Italic
hi DiagnosticError guifg=#af0000 gui=Italic,Bold
hi DiagnosticSignWarn guifg=#d7d700
hi DiagnosticSignInfo guifg=#87d7ff
hi DiagnosticSignHint guifg=#ffffd7
hi DiagnosticSignError guifg=#af0000
"hi link vimUserFunc none

"hi Normal guibg=#1c1c1c
highlight clear NormalNC" guibg=#262626
highlight link NormalFloat NormalNC
highlight TroubleNormal guibg=none ctermbg=none
highlight TroubleText guibg=#262626
highlight EndOfBuffer guifg=#1c1c1c guibg=None ctermfg=None ctermbg=None
"highlight SignColumn guibg=#262626
"highlight LineNR guibg=#262626
highlight CursorLineNr guibg=#292929 guifg=#CCCCCC gui=bold
highlight CursorLine guibg=#292929
highlight debugPc guibg=#5f0000 gui=bold
highlight ColorColumn guibg=#262626
highlight Title ctermfg=79 guifg=#4ec9b0 gui=bold

highlight Cursor guibg=#5f87af ctermbg=67
highlight iCursor guibg=#ffffaf ctermbg=229
highlight rCursor guibg=#d70000 ctermbg=124

" Colors for nvim-cmp completion menu
highlight CmpItemAbbr guifg=#949494
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


"-------------------------------------------------------------------------
" rhysd/conflict-marker.vim
"-------------------------------------------------------------------------
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

highlight NeoTreeGitConflict guifg=#ff8700

highlight TermNormal           guibg=#101010
highlight TermWinBar           guibg=#101010 guifg=#BBBBBB gui=bold
highlight TermWinBarHeader     guibg=#101010 guifg=#BBBBBB gui=bold,underline
highlight TermWinBarLocation   guibg=#101010 guifg=#888888 gui=bold

augroup TerminalHighlights
    autocmd!
    autocmd TermEnter * setlocal winhighlight=Normal:TermNormal,WinBar:TermWinBar,WinBarHeader:TermWinBarHeader,WinBarLocation:TermWinBarLocation
    " when we ;eave insert mode, return the bakcground to normal
    autocmd TermLeave * setlocal winhighlight=
augroup END
