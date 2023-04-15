" lua << EOF
"   -- This block fixes highlight groups that were renamed from neovim 0.7 to 0.8
"   -- see https://github.com/nvim-treesitter/nvim-treesitter/commit/42ab95d5e11f247c6f0c8f5181b02e816caa4a4f
"   local hl = function(group, opts)
"       opts.default = true
"       vim.api.nvim_set_hl(0, group, opts)
"   end
" 
"   -- Misc {{{
"   hl('@comment', {link = 'Comment'})
"   -- hl('@error', {link = 'Error'})
"   hl('@none', {bg = 'NONE', fg = 'NONE'})
"   hl('@preproc', {link = 'PreProc'})
"   hl('@define', {link = 'Define'})
"   hl('@operator', {link = 'Operator'})
"   -- }}}
" 
"   -- Punctuation {{{
"   hl('@punctuation.delimiter', {link = 'Delimiter'})
"   hl('@punctuation.bracket', {link = 'Delimiter'})
"   hl('@punctuation.special', {link = 'Delimiter'})
"   -- }}}
" 
"   -- Literals {{{
"   hl('@string', {link = 'String'})
"   hl('@string.regex', {link = 'String'})
"   hl('@string.escape', {link = 'SpecialChar'})
"   hl('@string.special', {link = 'SpecialChar'})
" 
"   hl('@character', {link = 'Character'})
"   hl('@character.special', {link = 'SpecialChar'})
" 
"   hl('@boolean', {link = 'Boolean'})
"   hl('@number', {link = 'Number'})
"   hl('@float', {link = 'Float'})
"   -- }}}
" 
"   -- Functions {{{
"   hl('@function', {link = 'Function'})
"   hl('@function.call', {link = 'Function'})
"   hl('@function.builtin', {link = 'Special'})
"   hl('@function.macro', {link = 'Macro'})
" 
"   hl('@method', {link = 'Function'})
"   hl('@method.call', {link = 'Function'})
" 
"   hl('@constructor', {link = 'Special'})
"   hl('@parameter', {link = 'Identifier'})
"   -- }}}
" 
"   -- Keywords {{{
"   hl('@keyword', {link = 'Keyword'})
"   hl('@keyword.function', {link = 'Keyword'})
"   hl('@keyword.operator', {link = 'Keyword'})
"   hl('@keyword.return', {link = 'Keyword'})
" 
"   hl('@conditional', {link = 'Conditional'})
"   hl('@repeat', {link = 'Repeat'})
"   hl('@debug', {link = 'Debug'})
"   hl('@label', {link = 'Label'})
"   hl('@include', {link = 'Include'})
"   hl('@exception', {link = 'Exception'})
"   -- }}}
" 
"   -- Types {{{
"   hl('@type', {link = 'Type'})
"   hl('@type.builtin', {link = 'Type'})
"   hl('@type.qualifier', {link = 'Type'})
"   hl('@type.definition', {link = 'Typedef'})
" 
"   hl('@storageclass', {link = 'StorageClass'})
"   hl('@attribute', {link = 'PreProc'})
"   hl('@field', {link = 'Identifier'})
"   hl('@property', {link = 'Identifier'})
"   -- }}}
" 
"   -- Identifiers {{{
"   hl('@variable', {link = 'Normal'})
"   hl('@variable.builtin', {link = 'Special'})
" 
"   hl('@constant', {link = 'Constant'})
"   hl('@constant.builtin', {link = 'Special'})
"   hl('@constant.macro', {link = 'Define'})
" 
"   hl('@namespace', {link = 'Include'})
"   hl('@symbol', {link = 'Identifier'})
"   -- }}}
" 
"   -- Text {{{
"   hl('@text', {link = 'Normal'})
"   hl('@text.strong', {bold = true})
"   hl('@text.emphasis', {italic = true})
"   hl('@text.underline', {underline = true})
"   hl('@text.strike', {strikethrough = true})
"   hl('@text.title', {link = 'Title'})
"   hl('@text.literal', {link = 'String'})
"   hl('@text.uri', {link = 'Underlined'})
"   hl('@text.math', {link = 'Special'})
"   hl('@text.environment', {link = 'Macro'})
"   hl('@text.environment.name', {link = 'Type'})
"   hl('@text.reference', {link = 'Constant'})
" 
"   hl('@text.todo', {link = 'Todo'})
"   hl('@text.note', {link = 'SpecialComment'})
"   hl('@text.warning', {link = 'WarningMsg'})
"   hl('@text.danger', {link = 'ErrorMsg'})
"   -- }}}
" 
"   -- Tags {{{
"   hl('@tag', {link = 'Tag'})
"   hl('@tag.attribute', {link = 'Identifier'})
"   hl('@tag.delimiter', {link = 'Delimiter'})
"   -- }}}
" EOF
let g:db_ui_use_nerd_fonts = 1

" configure nvcode-color-schemes
" let g:nvcodetermcolors=256
" colorscheme nvcode

" checks if your terminal has 24-bit color support
if (has("termguicolors"))
    set termguicolors
    hi LineNr ctermbg=NONE guibg=NONE
endif

" Style vertical split bar
"set fillchars+=vert:█
set fillchars=horiz:━
set fillchars+=horizup:┻
set fillchars+=horizdown:┳
set fillchars+=vert:┃
set fillchars+=vertleft:┫
set fillchars+=vertright:┣
set fillchars+=verthoriz:╋

"set fillchars=horiz:▄
"set fillchars+=horizup:█
"set fillchars+=horizdown:▄
"set fillchars+=vert:█
"set fillchars+=vertleft:█
"set fillchars+=vertright:█
"set fillchars+=verthoriz:█

highlight WinSeparator guifg=#3c3c52
highlight FloatBorder guifg=#b8b8e6

hi TabLine guifg=#bbbbbb ctermfg=246 guibg=#444444 ctermbg=238 gui=NONE cterm=NONE
hi TabLineFill guifg=NONE ctermfg=NONE guibg=#444444 ctermbg=238 gui=NONE cterm=NONE
hi TabLineSel guifg=#73cef4 ctermfg=185 guibg=NONE ctermbg=NONE gui=Bold cterm=Bold
hi TabModified guifg=#d7d787 ctermfg=186 guibg=#444444 ctermbg=238 gui=NONE cterm=NONE
hi TabModifiedSelected guifg=#c9d05c ctermfg=185 guibg=NONE ctermbg=NONE gui=Bold cterm=Bold

highlight MatchParen gui=BOLD guifg=#ffaf00 guibg=#444444

highlight ALEInfoSign ctermbg=None guibg=None cterm=NONE gui=NONE
highlight ALEErrorSign ctermbg=None guibg=None cterm=NONE gui=NONE
highlight ALEWarningSign ctermbg=None guibg=None cterm=NONE gui=NONE
highlight ALEStyleErrorSign ctermbg=None guibg=None cterm=NONE gui=NONE
highlight ALEStyleWarningSign ctermbg=None guibg=None cterm=NONE gui=NONE

highlight GitGutterAdd               guifg=#5faf5f gui=Bold
highlight GitGutterChange            guifg=#d7af5f gui=Bold
highlight GitGutterDelete            guifg=#ff5555 gui=Bold
highlight GitGutterChangeDelete      guifg=#c97755 gui=Bold


highlight TSVariableBuiltin guifg=#c586c0 ctermfg=175 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE

"hi DiagnosticVirtualTextError none
"hi DiagnosticVirtualTextWarn none
"hi DiagnosticVirtualTextInfo none
"hi DiagnosticVirtualTextHint none
hi DiagnosticWarn guifg=#d7d700 gui=Italic
hi DiagnosticInfo guifg=#87d7ff gui=Italic
hi DiagnosticHint guifg=#ffffd7 gui=Italic
hi DiagnosticError guifg=#af0000 gui=Italic,Bold
"hi link vimUserFunc none

hi Normal guibg=#1c1c1c
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

" highlight Type ctermfg=6 guifg=#4ec9b0
" highlight link This Language
" highlight link New Constant
" highlight link Interpolation Identifier
" highlight link InterpolationDelim Constant
" highlight link DocComment SpecialComment
" highlight link DocExample Identifier
" highlight link DocString Identifier
" highlight link Operator Conditional
" highlight link OperLambda Conditional
" highlight link Modifier Conditional
" highlight link LinqKeyword Conditional

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

" highlight link csUnspecifiedStatement PlainText
" highlight link csContextualStatement Control
" highlight link csUnsupportedStatement PlainText


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
