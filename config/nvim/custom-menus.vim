let content = [
            \ ['Go to &Definition      ,gd', 'call feedkeys(",gd")'],
            \ ['Go to &Type Definition ,gt', 'call feedkeys(",gt")'],
            \ ['Go to &Implementation  ,gi', 'call feedkeys(",gi")'],
            \ ['Find &References       ,gr', 'call feedkeys(",gr")'],
            \ ['--'],
            \ ['Re&name Symbol         ,rn', 'call feedkeys(",rn")'],
            \ ['--'],
            \ ['Code &Actions           ,a', 'call feedkeys(",a")'],
            \ ['Auto&Fix               ,fx', 'call feedkeys(",fx")'],
            \ ['--'],
            \ ['Pretty Print Json         ', '%!python -m json.tool']]
" set cursor to the last position
noremap <space><space> :call quickui#context#open(content, {'index':g:quickui#context#cursor})<cr>
