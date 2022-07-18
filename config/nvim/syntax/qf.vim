if exists('b:current_syntax')
    finish
endif

syn match qfFileName /^[^│]*/ contains=qfFileNameHead nextgroup=qfSeparatorLeft
syn match qfFileNameHead "\v[^/│]+ " contained containedin=qfFileName
syn match qfSeparatorLeft /│/ contained nextgroup=qfLineNr
syn match qfLineNr /[^│]*/ contained nextgroup=qfSeparatorRight
syn match qfSeparatorRight '│' contained nextgroup=qfError,qfWarning,qfInfo,qfNote
syn match qfError /  .*$/ contained
syn match qfWarning /  .*$/ contained
syn match qfInfo /  .*$/ contained
syn match qfNote /  .*$/ contained

hi def link qfFileName Comment
hi def link qfFileNameHead WinBar
hi def link qfSeparatorLeft Delimiter
hi def link qfSeparatorRight Delimiter
hi def link qfLineNr LineNr
hi def link qfError DiagnosticError
hi def link qfWarning DiagnosticWarn
hi def link qfInfo DiagnosticInfo
hi def link qfNote DiagnosticHint

let b:current_syntax = 'qf'
