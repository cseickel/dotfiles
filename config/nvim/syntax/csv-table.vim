" The table `xan view` renders, painted into a buffer by the csv plugin.
"
" Line 1 is the header, since csv#layout drops the top rule, and the row id is
" the first cell of any other line.
"
" A narrowed column ends its cells in an ellipsis, so every pattern that reads a
" value has to accept one. Where two patterns cover the same text the later one
" wins, which is why the row id sits below the numbers.
"
" CsvRowId covers the separator it starts on rather than skipping it with \zs.
" An earlier start beats a later one, so a \zs there would put its start past
" the separator CsvBorder already claimed, and the row id would never colour.

syntax match CsvBorder /[─│┌┬┐├┼┤└┴┘]/

" Dates anchor on a leading year and month, then take a run of whatever a
" datetime is made of, so any width of truncation still reads as a date.
syntax match CsvDate /\%>1l\d\{4}-\d\d[-0-9:.T Z+…]*/
syntax match CsvDate /\%>1l\d\{1,2}\/\d\{1,2}\/[0-9…]*/
syntax match CsvDate /\%>1l\d\d:\d\d[0-9:.…]*/

syntax match CsvNumberPositive /\%>1l[ │]\zs\d\+\%(\.\d*\)\?…\?\ze[ │]/
syntax match CsvNumberNegative /\%>1l[ │]\zs-\d\+\%(\.\d*\)\?…\?\ze[ │]/

syntax match CsvRowId /^│ *\d\+ */

syntax match CsvHeader /\%1l[^─│┌┬┐├┼┤└┴┘]\+/

highlight! CsvHeader         gui=bold guifg=#ededed
highlight! CsvBorder                  guifg=#444444
highlight! link CsvRowId CsvBorder
highlight! CsvNumberPositive          guifg=#85e0b1
highlight! CsvNumberNegative          guifg=#ff8066
highlight! CsvDate                    guifg=#ffd685

let b:current_syntax = "csv-table"
