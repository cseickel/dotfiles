let content = [
            \ ['Code &Actions          ,a', 'call feedkeys(",a")'],
            \ ['Re&name Symbol         ,n', 'call feedkeys(",n")'],
            \ ['--'],
            \ ['Go to &Definition      ,gd', 'call feedkeys(",gd")'],
            \ ['Go to &Type Definition ,gt', 'call feedkeys(",gt")'],
            \ ['Go to &Implementation  ,gi', 'call feedkeys(",gi")'],
            \ ['Find &References       ,gr', 'call feedkeys(",gr")'],
            \ ['--'],
            \ ['Pretty Print Json         ', '%!python -m json.tool']]
" set cursor to the last position
noremap <space><space> :call quickui#context#open(content, {'index':g:quickui#context#cursor})<cr>
