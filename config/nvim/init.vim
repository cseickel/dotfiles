let wd = getcwd()
cd ~/.config/nvim

source core-config.vim
source core-mappings.vim
source plugin-install.vim
source plugin-config.vim
source plugin-mappings.vim
source custom-menus.vim
lua    require('config')

exe 'cd ' . wd
