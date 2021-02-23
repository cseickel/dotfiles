" ==============================================================================
" FILE: Dark Plus Vim
" Author: Clay Dunston <dunstontc@gmail.com>
" License: MIT License
" Last Modified: 2019-07-12
" ==============================================================================

" Setup: {{{
scriptencoding utf-8

if exists('syntax on')
  syntax reset
endif

hi clear
let g:colors_name='dark_plus'
set background=dark

if ! exists('g:dark_plus_termcolors')
  let g:dark_plus_termcolors = 256
endif

if ! exists('g:dark_plus_terminal_italics')
  let g:dark_plus_terminal_italics = 1
endif
" }}}

" Terminal Colors:  {{{
let g:terminal_color_0  = '#1e1e1e'  " black
let g:terminal_color_1  = '#f44747'  " red
let g:terminal_color_2  = '#608b4e'  " green
let g:terminal_color_3  = '#d7ba7d'  " yellow
let g:terminal_color_4  = '#569cd6'  " blue
let g:terminal_color_5  = '#c586c0'  " magenta
let g:terminal_color_6  = '#4ec9b0'  " cyan
let g:terminal_color_7  = '#d4d4d4'  " white
let g:terminal_color_8  = '#1e1e1e'  " bright_black
let g:terminal_color_9  = '#f44747'  " bright_red
let g:terminal_color_10 = '#608b4e'  " bright_green
let g:terminal_color_11 = '#d7ba7d'  " bright_yellow
let g:terminal_color_12 = '#569cd6'  " bright_blue
let g:terminal_color_13 = '#c586c0'  " bright_magenta
let g:terminal_color_14 = '#4ec9b0'  " bright_cyan
let g:terminal_color_15 = '#d4d4d4'  " bright_white
let g:terminal_color_background = g:terminal_color_0
let g:terminal_color_foreground = g:terminal_color_7
" }}}
highlight White ctermfg=7 guifg=#d4d4d4 cterm=NONE gui=NONE
highlight DarkGray ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight Gray ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight Red ctermfg=1 guifg=#f44747 cterm=NONE gui=NONE
highlight LightRed ctermfg=1 guifg=#d16969 cterm=NONE gui=NONE
highlight Orange ctermfg=3 guifg=#ce9178 cterm=NONE gui=NONE
highlight YellowOrange ctermfg=3 guifg=#d7ba7d cterm=NONE gui=NONE
highlight Yellow ctermfg=3 guifg=#dcdcaa cterm=NONE gui=NONE
highlight Green ctermfg=2 guifg=#608b4e cterm=NONE gui=NONE
highlight Blue ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight LightGreen ctermfg=9 guifg=#b5cea8 cterm=NONE gui=NONE
highlight Cyan ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight Blue ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight DarkBlue ctermfg=4 guifg=#264f78 cterm=NONE gui=NONE
highlight LightBlue ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight BrightBlue ctermfg=4 guifg=#007acc cterm=NONE gui=NONE
highlight Magenta ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight Violet ctermfg=13 guifg=#646695 cterm=NONE gui=NONE
highlight Comment ctermfg=0 guifg=#505050 cterm=italic gui=italic
highlight DocString ctermfg=2 guifg=#608b4e cterm=italic gui=italic
highlight SpecialComment ctermfg=2 guifg=#608b4e cterm=italic gui=italic
highlight PlainText ctermfg=7 guifg=#d4d4d4 ctermbg=NONE guibg=NONE cterm=NONE gui=NONE
highlight Control ctermfg=13 guifg=#c586c0 ctermbg=NONE guibg=NONE cterm=NONE gui=NONE
highlight Escape ctermfg=3 guifg=#d7ba7d cterm=italic gui=italic
highlight Function ctermfg=3 guifg=#dcdcaa cterm=NONE gui=NONE
highlight Number ctermfg=9 guifg=#b5cea8 cterm=NONE gui=NONE
highlight Operator ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight RegEx ctermfg=1 guifg=#d16969 cterm=NONE gui=NONE
highlight String ctermfg=3 guifg=#ce9178 cterm=NONE gui=NONE
highlight Storage ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight Language ctermfg=4 guifg=#569cd6 cterm=italic gui=italic
highlight Type ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight Var ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight Tags ctermfg=7 guifg=#808080 cterm=NONE gui=NONE
highlight User1 ctermfg=0 guifg=#1e1e1e ctermbg=2 guibg=#608b4e cterm=NONE gui=NONE
highlight User2 ctermfg=7 guifg=#d4d4d4 ctermbg=0 guibg=#505050 cterm=NONE gui=NONE
highlight User3 ctermfg=2 guifg=#608b4e ctermbg=0 guibg=#303030 cterm=NONE gui=NONE
highlight Normal ctermfg=7 guifg=#d4d4d4 ctermbg=0 guibg=#1e1e1e cterm=NONE gui=NONE
highlight NormalNC ctermbg=0 guibg=#1e1e1e cterm=NONE gui=NONE
highlight ColorColumn ctermbg=0 guibg=#303030 cterm=NONE gui=NONE
highlight iCursor ctermbg=4 guibg=#569cd6 cterm=NONE gui=NONE
highlight vCursor ctermbg=13 guibg=#c586c0 cterm=NONE gui=NONE
highlight rCursor ctermbg=1 guibg=#d16969 cterm=NONE gui=NONE
highlight Cursor ctermbg=2 guibg=#608b4e cterm=NONE gui=NONE
highlight TermCursor ctermbg=2 guibg=#608b4e cterm=NONE gui=NONE
highlight CursorLine ctermbg=0 guibg=#1e1e1e cterm=NONE gui=NONE
highlight Directory ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight DiffAdd ctermbg=2 guibg=#608b4e cterm=NONE gui=NONE
highlight diffAdded ctermbg=2 guibg=#608b4e cterm=NONE gui=NONE
highlight DiffChange ctermbg=3 guibg=#dcdcaa cterm=NONE gui=NONE
highlight DiffDelete ctermbg=1 guibg=#d16969 cterm=NONE gui=NONE
highlight DiffText ctermbg=7 guibg=#d4d4d4 cterm=NONE gui=NONE
highlight EndOfBuffer ctermfg=0 guifg=#505050 ctermbg=0 guibg=#1e1e1e cterm=NONE gui=NONE
highlight ErrorMsg ctermfg=1 guifg=#d16969 ctermbg=NONE guibg=NONE cterm=NONE gui=NONE
highlight VertSplit ctermfg=0 guifg=#1e1e1e ctermbg=0 guibg=#303030 cterm=NONE gui=NONE
highlight Folded ctermfg=0 guifg=#505050 ctermbg=NONE guibg=NONE cterm=NONE gui=NONE
highlight FoldColumn ctermfg=0 guifg=#1e1e1e ctermbg=0 guibg=#303030 cterm=NONE gui=NONE
highlight SignColumn ctermbg=0 guibg=#1e1e1e cterm=NONE gui=NONE
highlight IncSearch ctermfg=NONE guifg=NONE ctermbg=4 guibg=#264f78 cterm=NONE gui=NONE
highlight LineNr ctermfg=0 guifg=#505050 ctermbg=0 guibg=#1e1e1e cterm=NONE gui=NONE
highlight CursorLineNr ctermfg=2 guifg=#608b4e ctermbg=0 guibg=#1e1e1e cterm=NONE gui=NONE
highlight matchTag ctermbg=4 guibg=#264f78 cterm=NONE gui=NONE
highlight MatchParen ctermbg=4 guibg=#264f78 cterm=NONE gui=NONE
highlight ModeMsg ctermfg=7 guifg=#808080 cterm=NONE gui=NONE
highlight MoreMsg ctermfg=7 guifg=#d4d4d4 cterm=NONE gui=NONE
highlight NonText ctermfg=7 guifg=#808080 ctermbg=NONE guibg=NONE cterm=NONE gui=NONE
highlight Pmenu ctermfg=7 guifg=#d4d4d4 ctermbg=0 guibg=#303030 cterm=NONE gui=NONE
highlight PmenuSel ctermfg=7 guifg=#d4d4d4 ctermbg=4 guibg=#264f78 cterm=NONE gui=NONE
highlight PmenuSbar ctermbg=7 guibg=#808080 cterm=NONE gui=NONE
highlight PmenuThumb ctermbg=4 guibg=#007acc cterm=NONE gui=NONE
highlight Question ctermfg=6 guifg=#4ec9b0 ctermbg=NONE guibg=NONE cterm=NONE gui=NONE
highlight Search ctermfg=0 guifg=#1e1e1e ctermbg=7 guibg=#d4d4d4 cterm=NONE gui=NONE
highlight Substitute ctermfg=NONE guifg=NONE ctermbg=7 guibg=#d4d4d4 cterm=NONE gui=NONE
highlight SpellBad ctermfg=1 guifg=#d16969 ctermbg=NONE guibg=NONE cterm=NONE gui=NONE
highlight SpellCap ctermfg=1 guifg=#d16969 ctermbg=NONE guibg=NONE cterm=NONE gui=NONE
highlight SpellRare ctermfg=1 guifg=#d16969 ctermbg=NONE guibg=NONE cterm=NONE gui=NONE
highlight SpellLocal ctermfg=1 guifg=#d16969 ctermbg=NONE guibg=NONE cterm=NONE gui=NONE
highlight TabLine ctermfg=7 guifg=#d4d4d4 ctermbg=0 guibg=#303030 cterm=italic gui=italic
highlight TabLineFill ctermfg=7 guifg=#d4d4d4 ctermbg=0 guibg=#1e1e1e cterm=italic gui=italic
highlight TabLineSel ctermfg=7 guifg=#d4d4d4 ctermbg=0 guibg=#1e1e1e cterm=NONE gui=NONE
highlight Title ctermfg=13 guifg=#c586c0 cterm=bold gui=bold
highlight Visual ctermbg=0 guibg=#1e1e1e cterm=reverse gui=reverse
highlight VisualNOS ctermfg=NONE guifg=NONE ctermbg=4 guibg=#264f78 cterm=NONE gui=NONE
highlight WarningMsg ctermfg=3 guifg=#ce9178 cterm=NONE gui=NONE
highlight WildMenu ctermfg=7 guifg=#d4d4d4 ctermbg=4 guibg=#264f78 cterm=NONE gui=NONE
highlight Debug ctermfg=4 guifg=#007acc cterm=NONE gui=NONE
highlight SpecialKey ctermfg=2 guifg=#608b4e cterm=none gui=none
highlight Tag ctermfg=2 guifg=#608b4e cterm=NONE gui=NONE
highlight Ignore cterm=NONE gui=NONE
highlight Conceal ctermfg=7 guifg=#d4d4d4 ctermbg=0 guibg=#1e1e1e cterm=NONE gui=NONE
highlight Error ctermfg=1 guifg=#d16969 ctermbg=NONE guibg=NONE cterm=NONE gui=NONE
highlight Todo ctermfg=7 guifg=#d4d4d4 ctermbg=2 guibg=#608b4e cterm=bold,italic gui=bold,italic
highlight Underlined cterm=underline gui=underline
highlight qfFileName ctermfg=4 guifg=#569cd6 ctermbg=NONE guibg=NONE cterm=NONE gui=NONE
highlight qfLineNr ctermfg=9 guifg=#b5cea8 ctermbg=NONE guibg=NONE cterm=NONE gui=NONE
highlight helpHyperTextEntry ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight helpHyperTextJump ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight helpCommand ctermfg=3 guifg=#ce9178 cterm=italic gui=italic
highlight helpExample ctermfg=3 guifg=#ce9178 cterm=italic gui=italic
highlight Statement ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight Constant ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight PreProc ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight Keyword ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight Boolean ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight Structure ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight StorageClass ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight String ctermfg=3 guifg=#ce9178 cterm=NONE gui=NONE
highlight Quote ctermfg=3 guifg=#ce9178 cterm=NONE gui=NONE
highlight Character ctermfg=3 guifg=#d7ba7d cterm=NONE gui=NONE
highlight Number ctermfg=9 guifg=#b5cea8 cterm=NONE gui=NONE
highlight Float ctermfg=9 guifg=#b5cea8 cterm=NONE gui=NONE
highlight Identifier ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight Conditional ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight Exception ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight Define ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight Include ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight Label ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight Repeat ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight Typedef ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight Delimiter ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight Special ctermfg=7 guifg=#d4d4d4 cterm=italic gui=italic
highlight SpecialChar ctermfg=13 guifg=#646695 cterm=NONE gui=NONE
highlight link awkFieldVars Var
highlight link awkVariables Var
highlight link awkStatement Constant
highlight link awkPatterns Constant
highlight link awkSpecialPrintf Constant
highlight link awkOperator Operator
highlight link awkExpression Operator
highlight link awkBoolLogic Operator
highlight link awkSemicolon Operator
highlight link awkSpecialCharacter Character
highlight cType ctermfg=6 guifg=#4ec9b0 cterm=italic gui=italic
highlight link cConstant Constant
highlight link cFormat Constant
highlight link cInclude Constant
highlight link cStatement Conditional
highlight link cIncluded Identifier
highlight link cSpecial Character
highlight link cSpecialCharacter Escape
highlight csType ctermfg=6 guifg=#4ec9b0 cterm=italic gui=italic
highlight link csThis Language
highlight link csNew Constant
highlight link csInterpolation Identifier
highlight link csInterpolationDelim Constant
highlight link csDocComment SpecialComment
highlight link csDocExample Identifier
highlight link csDocString Identifier
highlight link csOperator Conditional
highlight link csOperLambda Conditional
highlight link csModifier Conditional
highlight link csLinqKeyword Conditional
highlight link csUnspecifiedStatement PlainText
highlight link csContextualStatement Control
highlight link csUnsupportedStatement PlainText
highlight link cssDefinitionBraces Gray
highlight link cssValueBlockDelimiters Gray
highlight link cssPseudoKeyword Conditional
highlight link cssComment Green
highlight link cssBraces Delimiter
highlight link cssNoise Delimiter
highlight link cssSelectorOperator Conditional
highlight link cssInclude Conditional
highlight link cssTagName Constant
highlight cssClassName ctermfg=3 guifg=#d7ba7d cterm=NONE gui=NONE
highlight link cssClassNameDot cssClassName
highlight link cssClassSelector cssClassName
highlight link cssClassSelectorDot cssClassName
highlight link cssPseudoClass Conditional
highlight link cssPseudoClassID Constant
highlight link cssBrowserPrefix Type
highlight link cssVendor Type
highlight link cssImportant Conditional
highlight link cssMedia Conditional
highlight link cssMediaBlock Conditional
highlight link cssInclude Conditional
highlight link cssIncludeKeyword Conditional
highlight link cssSelectorOp PlainText
highlight link cssProp Identifier
highlight link cssPropDefinition Identifier
highlight link cssCustomProperty Identifier
highlight link cssDefinition Identifier
highlight link cssUnicodeEscape Character
highlight link cssAttr String
highlight link cssColor String
highlight link cssValueKeyword String
highlight link cssValueNumber Number
highlight link cssValueLength Number
highlight link lessClass cssClassName
highlight link lessVariable Identifier
highlight link dockerfileComment Identifier
highlight link dosiniHeader Define
highlight link dosiniNumber Number
highlight link dosiniComment Comment
highlight link dosiniLabel Identifier
highlight link dosbatchEchoOperator Constant
highlight link dosbatchSwitch Character
highlight link dosbatchSpecialChar Character
highlight link elixirStringDelimiter String
highlight link elixirInterpolationDelimiter Constant
highlight link elixirId Identifier
highlight link elixirOperator Conditional
highlight gitcommitBranch ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight gitcommitUntracked ctermfg=3 guifg=#d7ba7d cterm=NONE gui=NONE
highlight gitcommitDiscarded ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight link gitcommitSummary String
highlight link gitcommitFirstLine String
highlight link gitcommitHeader PlainText
highlight link gitcommitWarning WarningMsg
highlight link gitcommitSelectedFile Directory
highlight link gitconfigNone PlainText
highlight link gitconfigEscape Escape
highlight goStandardLib ctermfg=7 guifg=#d4d4d4 cterm=italic gui=italic
highlight goPackageName ctermfg=7 guifg=#d4d4d4 cterm=italic gui=italic
highlight goReceiver ctermfg=7 guifg=#d4d4d4 cterm=NONE gui=NONE
highlight link goComment SpecialComment
highlight link goTmplComment Comment
highlight link goPackageComment SpecialComment
highlight link goDocComment Comment
highlight link goTmplControl Conditional
highlight link goTmplAction Type
highlight link goTodo Todo
highlight link goCommentEmphasis Character
highlight link goMain PlainText
highlight link goStatement Conditional
highlight link goOperator Conditional
highlight link goImport Constant
highlight link goFloats Type
highlight link goArgumentType Type
highlight link goTypeName Type
highlight link goReceiverType Type
highlight goType ctermfg=6 guifg=#4ec9b0 cterm=italic gui=italic
highlight goFloats ctermfg=6 guifg=#4ec9b0 cterm=italic gui=italic
highlight goSignedInts ctermfg=6 guifg=#4ec9b0 cterm=italic gui=italic
highlight goUnsignedInts ctermfg=6 guifg=#4ec9b0 cterm=italic gui=italic
highlight goComplexes ctermfg=6 guifg=#4ec9b0 cterm=italic gui=italic
highlight link goBoolean Boolean
highlight link goPredefinedIdentifiers Constant
highlight link goConst Constant
highlight link goDeclaration Constant
highlight link goDeclType Constant
highlight link goTypeDecl Constant
highlight link goVarAssign Identifier
highlight link goVarDefs Identifier
highlight link goSingleDecl Identifier
highlight link goReceiverVar Identifier
highlight link goFunctionCall Function
highlight link goMethodCall Function
highlight link goBuiltins Function
highlight link goFormatSpecifier Constant
highlight link goEscapeC Escape
highlight goEscapeU ctermfg=3 guifg=#d7ba7d cterm=italic gui=italic
highlight htmlHead ctermfg=7 guifg=#808080 cterm=NONE gui=NONE
highlight htmlTitle ctermfg=7 guifg=#d4d4d4 cterm=NONE gui=NONE
highlight htmlTag ctermfg=7 guifg=#808080 cterm=NONE gui=NONE
highlight htmlEndTag ctermfg=7 guifg=#808080 cterm=NONE gui=NONE
highlight htmlTagName ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight htmlSpecialTagName ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight htmlBold ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight htmlItalic ctermfg=6 guifg=#4ec9b0 cterm=italic gui=italic
highlight link htmlH1 PlainText
highlight link htmlH2 PlainText
highlight link htmlH3 PlainText
highlight link htmlH4 PlainText
highlight link htmlH5 PlainText
highlight link htmlH6 PlainText
highlight link htmlArg Identifier
highlight link htmlComment Comment
highlight link htmlSpecialChar Character
highlight link xmlDocTypeDecl DarkGray
highlight link xmlAttrib  htmlArg
highlight link xmlTagName htmlTagName
highlight link xmlEndTag htmlTagName
highlight link xmlTag htmlTag
highlight link xmlEqual htmlTag
highlight link javaX_JavaLang Constant
highlight link javaOperator Constant
highlight link javaMethodDecl Control
highlight link javaStatement Control
highlight link javaC_JavaLang Type
highlight link javaSpecialChar Character
highlight link javaAnnotation Conditional
highlight link javaBraces PlainText
highlight link javaScript PlainText
highlight link javaScriptFunction Constant
highlight link javaScriptNumber Number
highlight link javaScriptStringS String
highlight link javaScriptSpecial Constant
highlight link jsThis Language
highlight link jsDot Conditional
highlight link jsNoise Comment
highlight link jsGlobalObjects Type
highlight link jsGlobalNodeObjects Type
highlight link jsObjectProp Type
highlight link jsClassDefinition Type
highlight link jsFuncCall Function
highlight link jsFunction Constant
highlight link jsFunctionKey Identifier
highlight link jsModuleKeyword Identifier
highlight link jsVariableDef Identifier
highlight link jsParen Identifier
highlight link jsFuncArgs Identifier
highlight link jsParenRepeat Identifier
highlight link jsParenSwitch Identifier
highlight link jsParenIfElse Identifier
highlight link jsObjectKey Identifier
highlight link jsObjectProp Identifier
highlight link jsObjectStringKey Identifier
highlight link jsTemplateExpression Identifier
highlight link jsClassKeyword Boolean
highlight link jsTemplateString String
highlight link jsSpecial Character
highlight link jsRegexpString RegEx
highlight link jsTemplateBraces StorageClass
highlight link jsSwitchColon Operator
highlight link jsReturn Conditional
highlight link jsOperator Conditional
highlight link jsSpreadOperator Constant
highlight link jsExtendsKeyword Constant
highlight link jsArrowFunction Constant
highlight link jsArrowFuncArgs Identifier
highlight link jsObjectColon PlainText
highlight link jsxEscapeJs Escape
highlight link jsxAttributeBraces Constant
highlight link jsxTag Tags
highlight link jsxEndTag Tags
highlight link jsxTagName htmlTagName
highlight link jsxAttrib Identifier
highlight link jsxEqual PlainText
highlight link jsxString String
highlight link jsxCloseTag htmlTagName
highlight link jsxCloseString htmlTagName
highlight link javascriptNodeGlobal Type
highlight link javascriptIdentifierName Identifier
highlight link javascriptObjectLabel Identifier
highlight link javascriptProp Identifier
highlight link javascriptOperator Constant
highlight link javascriptVariable Constant
highlight link javascriptEndColons Comment
highlight link javascriptBraces PlainText
highlight link javascriptBrackets PlainText
highlight link jsNull Constant
highlight link jsDecorator Constant
highlight link jsonString String
highlight link jsonKeyword Identifier
highlight jsonKeywordMatch ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight jsonBraces ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight jsonNoise ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight jsonQuote ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight link jsonCommentError SpecialComment
highlight link jsonEscape Character
highlight jsonFold ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight link luaFuncKeyword Constant
highlight link luaLocal Constant
highlight link luaFuncName Function
highlight link luaFuncCall Function
highlight link luaParen Identifier
highlight link luaFuncArg Identifier
highlight link luaFuncArgName Identifier
highlight link luaString String
highlight link luaStringSpecial Character
highlight link luaOperator Conditional
highlight link luaSymbolOperator Conditional
highlight luaFunc cterm=NONE gui=NONE
highlight luaComma cterm=NONE gui=NONE
highlight luaFuncParens cterm=NONE gui=NONE
highlight luaBraces ctermfg=7 guifg=#d4d4d4 cterm=NONE gui=NONE
highlight luaTable cterm=NONE gui=NONE
highlight luaFuncSig cterm=NONE gui=NONE
highlight link manSectionHeading Magenta
highlight link manSubHeading Magenta
highlight link makeCommands String
highlight link makeSpecial Constant
highlight link makeComment SpecialComment
highlight link markdownHighlightcs PlainText
highlight markdownH1 ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight link markdownH2 markdownH1
highlight link markdownH3 markdownH1
highlight link markdownH4 markdownH1
highlight link markdownH5 markdownH1
highlight link markdownH6 markdownH1
highlight link markdownRule markdownH1
highlight markdownHeadingDelimiter ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight markdownItalic ctermfg=6 guifg=#9cdcfe cterm=italic gui=italic
highlight markdownItalicDelimiter ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight markdownBold ctermfg=4 guifg=#569cd6 cterm=bold gui=bold
highlight markdownBoldDelimiter ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight markdownListMarker ctermfg=4 guifg=#007acc cterm=NONE gui=NONE
highlight link markdownCode String
highlight link markdownLinkText Identifier
highlight link markdownCodeDelimiter Delimiter
highlight link markdownUrl Delimiter
highlight link markdownLinkDelimiter Delimiter
highlight link markdownLinkTextDelimiter Delimiter
highlight markdownBlockquote ctermfg=2 guifg=#608b4e cterm=NONE gui=NONE
highlight mkdItalic cterm=NONE gui=NONE
highlight mkdBold cterm=NONE gui=NONE
highlight mkdBoldItalic cterm=NONE gui=NONE
highlight mkdFootnotes cterm=NONE gui=NONE
highlight mkdFootnote cterm=NONE gui=NONE
highlight mkdID cterm=NONE gui=NONE
highlight mkdURL ctermfg=3 guifg=#ce9178 cterm=NONE gui=NONE
highlight mkdLink ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight mkdInlineURL ctermfg=3 guifg=#ce9178 cterm=NONE gui=NONE
highlight mkdLinkDefTarget ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight mkdLinkDef ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight mkdLinkTitle ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight mkdLineBreak cterm=NONE gui=NONE
highlight mkdBlockquote ctermfg=2 guifg=#608b4e cterm=NONE gui=NONE
highlight mkdCode ctermfg=3 guifg=#ce9178 cterm=NONE gui=NONE
highlight mkdListItem ctermfg=4 guifg=#007acc cterm=NONE gui=NONE
highlight mkdListItemLine cterm=NONE gui=NONE
highlight mkdNonListItemBlock cterm=NONE gui=NONE
highlight mkdRule ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight mkdDelimiter ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight link nroffReqLeader Constant
highlight link nroffReqName Constant
highlight link nroffSpecialChar Character
highlight link perlSpecialString Escape
highlight link perlVarMember Type
highlight link powershellOperatorStart Conditional
highlight link powershellEscape Character
highlight link powershellKeyword Constant
highlight link powershellCmdlet Type
highlight link ps1Keyword Constant
highlight link ps1InterpolationDelimiter Constant
highlight link ps1Operator Conditional
highlight link ps1Flag Conditional
highlight link ps1Interpolation Identifier
highlight pythonRun ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight pythonCoding ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight pythonBuiltinFunc ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight pythonClassVar ctermfg=4 guifg=#569cd6 cterm=italic gui=italic
highlight pythonAttribute ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight link pythonBuiltin Constant
highlight link pythonDot Identifier
highlight link pythonFunction Function
highlight link pythonClassName Type
highlight link pythonBuiltinObj Type
highlight link pythonInclude Control
highlight link pythonOperator Control
highlight link pythonStatement Control
highlight link pythonNumber Number
highlight link pythonString String
highlight link pythonRawString String
highlight link pythonFString String
highlight link pythonStrFormat Identifier
highlight link pythonStrInterpRegion Identifier
highlight link pythonStrTemplate Identifier
highlight link pythonStrFormatting Character
highlight link pythonEscape Character
highlight link pythonRawEscape Character
highlight link pythonUniEscape Character
highlight link pythonBytesEscape Character
highlight link pythonTrippleQuotes SpecialComment
highlight link pythonDocString SpecialComment
highlight link pythonCommentTitle SpecialComment
highlight link pythonComment Comment
highlight pythonImport ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight pythonIncludeLine ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight pythonImportedModule ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight pythonImportedObject ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight pythonImportedFuncDef ctermfg=3 guifg=#dcdcaa cterm=NONE gui=NONE
highlight impsortNonImport ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight link rubyInterpolation Identifier
highlight link rubyLocalVariableOrMethod Identifier
highlight link rubyInterpolationDelimiter Constant
highlight link rubyOperator Conditional
highlight link rubyControl Conditional
highlight link rubyBlockParameterList htmlTag
highlight link rubyBlockParameter Identifier
highlight link rubySymbol Character
highlight link rubyClassNameTag Type
highlight link rubyString String
highlight link rubyStringDelimiter String
highlight rustSelf ctermfg=4 guifg=#569cd6 cterm=italic gui=italic
highlight link rustEscape Character
highlight link rustPunctuation Comment
highlight link rustDot Conditional
highlight link rustControlKeyword Conditional
highlight link rustMacro Function
highlight link rustModPath Type
highlight link rustOperator Conditional
highlight link rustSigil Constant
highlight link rustPlaceholder Constant
highlight link rustModPathSep Magenta
highlight link sqlComment SpecialComment
highlight link sqlString String
highlight link sqlStatement Constant
highlight link sqlKeyword Conditional
highlight link sqlSpecial Type
highlight link shQuote String
highlight link shDoubleQuote String
highlight link shSpecial Character
highlight link shEscape Character
highlight link shFunction Function
highlight link shFunctionTwo Function
highlight link shSet Constant
highlight link shRedir Control
highlight link shOperator Control
highlight link shTestOpr Control
highlight link shVarAssign Control
highlight link shCmdSubRegion Statement
highlight link shStatement Keyword
highlight link shDerefVar Identifier
highlight link shDerefSpecial Identifier
highlight link shDerefSimple Identifier
highlight link shDerefVarArray Identifier
highlight link shRepeat Identifier
highlight link shFor Identifier
highlight link shFunctionStatement Conditional
highlight link shFunctionKey Conditional
highlight link shConditional Conditional
highlight link shOption Conditional
highlight link shIf Conditional
highlight link shDo Conditional
highlight link shLoop Conditional
highlight link shDblBrace Conditional
highlight link shTestOpr Conditional
highlight shDerefPattern ctermfg=1 guifg=#d16969 cterm=NONE gui=NONE
highlight shDerefOp ctermfg=1 guifg=#d16969 cterm=NONE gui=NONE
highlight shCtrlSeq ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight shFunctionOne ctermfg=7 guifg=#d4d4d4 cterm=NONE gui=NONE
highlight shDeref ctermfg=7 guifg=#d4d4d4 cterm=NONE gui=NONE
highlight shExpr ctermfg=7 guifg=#d4d4d4 cterm=NONE gui=NONE
highlight shSubSh cterm=NONE gui=NONE
highlight shSubRegion cterm=NONE gui=NONE
highlight shCmdParenRegion cterm=NONE gui=NONE
highlight link bashBuiltinCommands Constant
highlight link zshFunction Function
highlight link zshDeref Boolean
highlight link zshVariableDef Identifier
highlight link zshSubst Identifier
highlight link zshOption Identifier
highlight link zshSubstDelim Boolean
highlight link zshOperator Control
highlight link zshQuoted Escape
highlight zshPrecommand ctermfg=3 guifg=#dcdcaa cterm=italic gui=italic
highlight zshParentheses ctermfg=7 guifg=#d4d4d4 cterm=NONE gui=NONE
highlight todoItem ctermfg=7 guifg=#d4d4d4 cterm=NONE gui=NONE
highlight todoID ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight todoDone ctermfg=7 guifg=#808080 cterm=NONE gui=NONE
highlight todoDate ctermfg=7 guifg=#808080 cterm=NONE gui=NONE
highlight todoOverDueDate ctermfg=1 guifg=#d16969 cterm=NONE gui=NONE
highlight todoProject ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight todoContext ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight todoExtra ctermfg=9 guifg=#b5cea8 cterm=NONE gui=NONE
highlight todoString ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight todoPriorityA ctermfg=1 guifg=#f44747 cterm=NONE gui=NONE
highlight todoPriorityB ctermfg=1 guifg=#d16969 cterm=NONE gui=NONE
highlight todoPriorityC ctermfg=3 guifg=#ce9178 cterm=NONE gui=NONE
highlight todoPriorityD ctermfg=3 guifg=#d7ba7d cterm=NONE gui=NONE
highlight todoPriorityE ctermfg=3 guifg=#dcdcaa cterm=NONE gui=NONE
highlight todoPriorityF ctermfg=9 guifg=#b5cea8 cterm=NONE gui=NONE
highlight todoComment ctermfg=0 guifg=#505050 cterm=italic gui=italic
highlight link CSVComment Comment
highlight CSVColumnEven ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight CSVColumnOdd ctermfg=2 guifg=#608b4e cterm=NONE gui=NONE
highlight CSVColumnHeaderEven ctermfg=0 guifg=#1e1e1e ctermbg=4 guibg=#569cd6 cterm=NONE gui=NONE
highlight CSVColumnHeaderOdd ctermfg=0 guifg=#1e1e1e ctermbg=2 guibg=#608b4e cterm=NONE gui=NONE
highlight link vimCtrlChar YellowOrange
highlight link vimEcho Function
highlight link vimNamespace Type
highlight link vimCVar Type
highlight link vimVarNamespace Type
highlight link vimVar Identifier
highlight vimEnvVar ctermfg=6 guifg=#9cdcfe cterm=italic gui=italic
highlight link vimBuiltin Type
highlight link vimFunc Function
highlight link vimUserFunc Function
highlight link vimUserCmd Function
highlight link vimDocBlock SpecialComment
highlight link vimFunction Function
highlight vimFunctionError ctermfg=1 guifg=#f44747 cterm=NONE gui=NONE
highlight vimContinue ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight vimLineComment ctermfg=0 guifg=#505050 cterm=italic gui=italic
highlight link vimCommentTitle SpecialComment
highlight vimBracket ctermfg=7 guifg=#808080 cterm=NONE gui=NONE
highlight link vimNotFunc Conditional
highlight link vimCommand Conditional
highlight link vimCmdSep Conditional
highlight link vimOper Magenta
highlight link vimMap Conditional
highlight link vimFtCmd Conditional
highlight vimParenSep ctermfg=7 guifg=#d4d4d4 cterm=NONE gui=NONE
highlight vimSetSep ctermfg=7 guifg=#d4d4d4 cterm=NONE gui=NONE
highlight vimSep ctermfg=7 guifg=#d4d4d4 cterm=NONE gui=NONE
highlight vimOperParen ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight vimOption ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight vimSet ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight vimMapLhs ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight vimIsCommand ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight vimHiAttrib ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight vimMapMod ctermfg=7 guifg=#808080 cterm=NONE gui=NONE
highlight vimLet ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight vimMapModKey ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight vimHighlight ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight link vimMapRhs Type
highlight link vimFtOption Type
highlight link vimNotation Character
highlight link vimHLGroup Character
highlight link vimHiLink Character
highlight link vimEchoHL Type
highlight vimAutoCmd cterm=NONE gui=NONE
highlight vimAutoEvent cterm=NONE gui=NONE
highlight vimAutoCmdSfxList cterm=NONE gui=NONE
highlight vimPatSepR ctermfg=3 guifg=#d7ba7d cterm=NONE gui=NONE
highlight vimSynPatRange ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight vimSynPatMod ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight vimSynNotPatRange ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight vimSynMatchRegion ctermfg=1 guifg=#d16969 cterm=NONE gui=NONE
highlight vimGroupList ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight vimGroup ctermfg=3 guifg=#d7ba7d cterm=NONE gui=NONE
highlight vimHiGroup ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight vimGroupName ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight vimGroupAdd ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight vimSynNextGroup ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight link vimSynType Type
highlight link vimSynCase Constant
highlight link vimSyncLinecont Constant
highlight link vimSyncMatch Constant
highlight link vimSynRegOpt Constant
highlight link vimSyntax Conditional
highlight link vimSynKeyOpt Conditional
highlight link vimSynContains Conditional
highlight link vimSynReg Conditional
highlight link vimSynMtchOpt Conditional
highlight link vimSynMtchGrp Conditional
highlight nvimMap ctermfg=13 guifg=#646695 cterm=NONE gui=NONE
highlight nvimMapBang ctermfg=13 guifg=#646695 cterm=NONE gui=NONE
highlight nvimUnmap ctermfg=13 guifg=#646695 cterm=NONE gui=NONE
highlight nvimHLGroup ctermfg=13 guifg=#646695 cterm=NONE gui=NONE
highlight link yaccVar Var
highlight link yaccSectionSep Conditional
highlight link yamlPlainScalar String
highlight link yamlBlockMappingKey Identifier
highlight link yamlFlowString String
highlight link yamlFlowStringDelimiter String
highlight link yamlEscape Character
highlight yamlDocumentStart ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight yamlDocumentEnd ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight yamlKeyValueDelimiter ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight link snipSnippetBody String
highlight link snipSnippetDocString PlainText
highlight link snipSnippetTrigger Conditional
highlight link snipEscape Character
highlight link snipSnippetHeader Comment
highlight link snipSnippetFooter Comment
highlight link snipSnippetFooterKeyword Comment
highlight link snipSnippetHeaderKeyword Comment
highlight snipTabStop ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight snipTabStopDefault ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight snipVisual ctermfg=4 guifg=#264f78 cterm=NONE gui=NONE
highlight snipCommand ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight snipVimlCommand ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight snipVimlCommandV ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight snipPythonCommand ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight snipPythonCommandP ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight snipSnippetOptions cterm=NONE gui=NONE
highlight snipGlobal ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight snipGlobalPHeader ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight snipGlobalHeaderKeyword ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight snipSnippetOptionFlag ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight link snipLeadingSpaces nop
highlight link tmuxComment Comment
highlight link tmuxString String
highlight link tmuxStringDelimiter String
highlight tmuxOptions ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight tmuxFmtConditional ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight tmuxOptsSet ctermfg=3 guifg=#d7ba7d cterm=NONE gui=NONE
highlight tmuxOptsSetw ctermfg=3 guifg=#d7ba7d cterm=NONE gui=NONE
highlight tmuxWindowPaneCmds ctermfg=3 guifg=#dcdcaa cterm=NONE gui=NONE
highlight tmuxAttrEquals ctermfg=7 guifg=#d4d4d4 cterm=NONE gui=NONE
highlight tmuxShellInpol ctermfg=7 guifg=#d4d4d4 cterm=NONE gui=NONE
highlight tmuxAttrSeparator ctermfg=7 guifg=#808080 cterm=NONE gui=NONE
highlight tmuxFmtInpol ctermfg=7 guifg=#808080 cterm=NONE gui=NONE
highlight tmuxSpecialCmds ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight tmuxFmtInpolDelimiter ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight tmuxAttrInpolDelimiter ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight tmuxShellInpolDelimiter ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight tmuxURL ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight tmuxColor ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight tmuxStyle ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight tmuxVariable ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight tmuxAttrBgFg ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight tmuxFmtVariable ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight tmuxKey ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight tmuxFmtAlias ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight tmuxDateInpol ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight tmuxKeySymbol ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight tmuxOptionValue ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight ALEInfo cterm=NONE gui=NONE
highlight ALEError cterm=NONE gui=NONE
highlight ALEWarning cterm=NONE gui=NONE
highlight ALEStyleError cterm=NONE gui=NONE
highlight ALEStyleWarning cterm=NONE gui=NONE
highlight ALEInfoSign ctermfg=9 guifg=#b5cea8 ctermbg=0 guibg=#1e1e1e cterm=NONE gui=NONE
highlight ALEErrorSign ctermfg=1 guifg=#d16969 ctermbg=0 guibg=#1e1e1e cterm=NONE gui=NONE
highlight ALEWarningSign ctermfg=3 guifg=#d7ba7d ctermbg=0 guibg=#1e1e1e cterm=NONE gui=NONE
highlight ALEStyleErrorSign ctermfg=3 guifg=#dcdcaa ctermbg=0 guibg=#1e1e1e cterm=NONE gui=NONE
highlight ALEStyleWarningSign ctermfg=3 guifg=#dcdcaa ctermbg=0 guibg=#1e1e1e cterm=NONE gui=NONE
highlight ALEInfoLine cterm=NONE gui=NONE
highlight ALEErrorLine cterm=NONE gui=NONE
highlight ALEWarningLine cterm=NONE gui=NONE
highlight link NeomakeErrorSign ALEErrorSign
highlight link NeomakeWarningSign ALEWarningSign
highlight link NeomakeMessagesSign ALEInfoSign
highlight link NeomakeInfoSign ALEInfoSign
highlight BookmarkSign ctermfg=6 guifg=#4ec9b0 ctermbg=0 guibg=#303030 cterm=NONE gui=NONE
highlight BookmarkAnnotationSign ctermfg=6 guifg=#4ec9b0 ctermbg=0 guibg=#303030 cterm=NONE gui=NONE
highlight BookmarkLine cterm=NONE gui=NONE
highlight BookmarkAnnotationLine cterm=NONE gui=NONE
highlight BufTabLineCurrent ctermfg=0 guifg=#1e1e1e ctermbg=2 guibg=#608b4e cterm=NONE gui=NONE
highlight BufTabLineActive ctermfg=2 guifg=#608b4e ctermbg=0 guibg=#303030 cterm=NONE gui=NONE
highlight BufTabLineHidden ctermfg=7 guifg=#d4d4d4 ctermbg=0 guibg=#303030 cterm=NONE gui=NONE
highlight BufTabLineFill ctermbg=0 guibg=#303030 cterm=NONE gui=NONE
highlight deniteMatchedChar ctermfg=6 guifg=#4ec9b0 cterm=underline gui=underline
highlight denitePrompt ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight deniteConcealedMark ctermfg=4 guifg=#264f78 cterm=NONE gui=NONE
highlight deniteModeNormal ctermfg=2 guifg=#608b4e cterm=NONE gui=NONE
highlight deniteModeInsert ctermfg=2 guifg=#608b4e cterm=NONE gui=NONE
highlight deniteSource_Projectile_Name ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight GitGutterAdd ctermfg=2 guifg=#608b4e ctermbg=0 guibg=#1e1e1e cterm=NONE gui=NONE
highlight GitGutterChange ctermfg=3 guifg=#d7ba7d ctermbg=0 guibg=#1e1e1e cterm=NONE gui=NONE
highlight GitGutterDelete ctermfg=1 guifg=#d16969 ctermbg=0 guibg=#1e1e1e cterm=NONE gui=NONE
highlight GitGutterChangeDelete ctermfg=3 guifg=#d7ba7d ctermbg=0 guibg=#1e1e1e cterm=NONE gui=NONE
highlight GitGutterAddLine cterm=NONE gui=NONE
highlight GitGutterChangeLine cterm=NONE gui=NONE
highlight GitGutterDeleteLine cterm=NONE gui=NONE
highlight GitGutterChangeDeleteLine cterm=NONE gui=NONE
highlight githubNumber ctermfg=9 guifg=#b5cea8 cterm=NONE gui=NONE
highlight githubTime ctermfg=7 guifg=#808080 cterm=NONE gui=NONE
highlight githubUser ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight githubBranch ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight githubRepo ctermfg=3 guifg=#ce9178 cterm=NONE gui=NONE
highlight githubSHA ctermfg=9 guifg=#b5cea8 cterm=NONE gui=NONE
highlight githubKeyword ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight githubCommit ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight githubRelease ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight githubTag ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight githubEdit ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight githubGist ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight StartifyFile ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight StartifyBracket ctermfg=0 guifg=#1e1e1e cterm=NONE gui=NONE
highlight StartifyNumber ctermfg=9 guifg=#b5cea8 cterm=NONE gui=NONE
highlight StartifyVar ctermfg=9 guifg=#b5cea8 cterm=NONE gui=NONE
highlight StartifySpecial ctermfg=9 guifg=#b5cea8 cterm=NONE gui=NONE
highlight StartifySlash ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight StartifyPath ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight StartifySelect ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight StartifyHeader ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight StartifySection ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight TagbarHelp ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight TagbarHelpKey ctermfg=7 guifg=#808080 cterm=NONE gui=NONE
highlight TagbarHelpTitle ctermfg=13 guifg=#646695 cterm=NONE gui=NONE
highlight TagbarKind ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight TagbarNestedKind ctermfg=9 guifg=#b5cea8 cterm=NONE gui=NONE
highlight TagbarScope ctermfg=3 guifg=#dcdcaa cterm=NONE gui=NONE
highlight TagbarType ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight link TagbarParens PlainText
highlight TagbarSignature ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight TagbarPseudoID ctermfg=13 guifg=#c586c0 cterm=NONE gui=NONE
highlight TagbarFunc ctermfg=3 guifg=#dcdcaa cterm=NONE gui=NONE
highlight TagbarSection ctermfg=13 guifg=#c586c0 cterm=bold gui=bold
highlight uniteStatusNormal ctermfg=2 guifg=#608b4e cterm=NONE gui=NONE
highlight uniteStatusInsert ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight unitePrompt ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight FilerCursor ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight FilerSelected ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight FilerActive ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight FilerMatch cterm=NONE gui=NONE
highlight FilerNoMatch cterm=NONE gui=NONE
highlight FilerPrompt ctermfg=6 guifg=#4ec9b0 cterm=NONE gui=NONE
highlight FilerInput ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight FilerCompletion ctermfg=0 guifg=#505050 cterm=NONE gui=NONE
highlight vimfilerStatus cterm=NONE gui=NONE
highlight vimfilerColumn__devicons ctermfg=7 guifg=#808080 cterm=NONE gui=NONE
highlight vimfilerDirectory ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight vimfilerCurrentDirectory ctermfg=6 guifg=#4ec9b0 cterm=italic gui=italic
highlight vimfilerMask ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight vimfilerMark ctermfg=2 guifg=#608b4e cterm=NONE gui=NONE
highlight vimfilerNonMark ctermfg=7 guifg=#d4d4d4 cterm=NONE gui=NONE
highlight vimfilerLeaf ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight vimfilerNormalFile ctermfg=7 guifg=#d4d4d4 cterm=NONE gui=NONE
highlight vimfilerOpenedFile ctermfg=6 guifg=#9cdcfe cterm=NONE gui=NONE
highlight vimfilerClosedFile ctermfg=4 guifg=#569cd6 cterm=NONE gui=NONE
highlight vimfilerMarkedFile ctermfg=2 guifg=#608b4e cterm=NONE gui=NONE
highlight vimfilerROFile ctermfg=7 guifg=#808080 cterm=NONE gui=NONE
