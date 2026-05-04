" Claude transcript syntax (.claude format)
" Symbol-prefixed format: ● Claude, ❯ user, ◆ tool call, ⎿ tool result, ∴ thinking

" Load markdown syntax first, then layer our custom rules on top
unlet! b:current_syntax
runtime! syntax/markdown.vim

" User messages: ❯ prefix, region until next marker
syntax region UserRegion start=/^❯/ end=/^[●❯∴◆↪]\@=\|^\s*⎿\@=/me=s-1 containedin=ALL contains=UserMarker
syntax match UserMarker /^❯/ contained

" Injected content: ↪ prefix, region until next marker
syntax region InjectedRegion start=/^↪/ end=/^[●❯∴◆]\@=\|^\s*⎿\@=/me=s-1 containedin=ALL contains=InjectedMarker
syntax match InjectedMarker /^↪/ contained

" Claude messages: ● prefix, region until next marker
syntax region ClaudeRegion start=/^●/ end=/^[●❯∴◆↪]\@=\|^\s*⎿\@=/me=s-1 containedin=ALL contains=ClaudeMarker
syntax match ClaudeMarker /^●/ contained

" Thinking blocks: ∴ prefix, region until next marker
syntax region ThinkingRegion start=/^∴/ end=/^[●❯∴◆↪]\@=\|^\s*⎿\@=/me=s-1 containedin=ALL contains=ThinkingMarker
syntax match ThinkingMarker /^∴/ contained

" Tool calls: ◆ prefix (single line)
syntax match ToolCallLine /^◆ .*$/ containedin=ALL contains=ToolCallMarker,ToolName,ToolArgs
syntax match ToolCallMarker /^◆/ contained
syntax match ToolName / [A-Za-z_-]\+\ze(/ contained
syntax match ToolArgs /([^)]*)/ contained

" Tool results: ⎿ prefix (indented, single line) with file reference and optional duration
syntax match ToolResultLine /^\s*⎿ .*$/ containedin=ALL contains=ToolResultMarker,ToolFile,ToolDuration
syntax match ToolResultMarker /⎿/ contained
syntax match ToolFile /\d\{3}-[A-Za-z_-]*\.md/ contained
syntax match ToolDuration /([0-9]\+m\?s)/ contained

" Separator
syntax match ClaudeSeparator /^---$/

" Highlighting
highlight! UserMarker gui=bold guifg=#4f8657
highlight! UserRegion guifg=#65a46e
highlight! ClaudeMarker gui=bold guifg=#d4d4d4
highlight! ClaudeRegion guifg=#d4d4d4
highlight! InjectedMarker gui=bold guifg=#65a46e
highlight! InjectedRegion gui=italic guifg=#65a46e
highlight! ThinkingMarker gui=italic guifg=#888888
highlight! ThinkingRegion gui=italic guifg=#888888
highlight! ToolCallMarker guifg=#b4a7d6
highlight! ToolName gui=bold guifg=#b4a7d6
highlight! ToolArgs guifg=#888888
highlight! ToolResultMarker guifg=#555555
highlight! ToolFile gui=underline guifg=#3984bd
highlight! ToolDuration guifg=#666666
highlight! ClaudeSeparator guifg=#444444 gui=bold

let b:current_syntax = "claude-companion"
