source ~/.config/nvim/core-config.vim
source ~/.config/nvim/core-mappings.vim
source ~/.config/nvim/plugin-install.vim
source ~/.config/nvim/plugin-config.vim
source ~/.config/nvim/plugin-mappings.vim
source ~/.config/nvim/custom-menus.vim


" Style vertical split bar
"set fillchars+=vert:▏
"set fillchars+=vert:▍
"set fillchars+=vert:▉
"set fillchars+=vert:▕
set fillchars+=vert:█
highlight VertSplit guifg=#444444 ctermfg=238 guibg=#222222
highlight NormalNC guibg=#222222
highlight EndOfBuffer guifg=#202020 guibg=None ctermfg=None ctermbg=None
highlight LineNR guibg=None ctermbg=None ctermfg=236 guifg=#505050
highlight SignColumn ctermbg=None guibg=None cterm=NONE gui=NONE
highlight CursorLineNr ctermfg=2 guifg=#608b4e ctermbg=None guibg=None


highlight Cursor guibg=#5f87af ctermbg=67
highlight iCursor guibg=#ffffaf ctermbg=229
highlight rCursor guibg=#af0000 ctermbg=124

