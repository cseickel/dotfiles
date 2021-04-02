
"*************************************************************
"" Vim-Plug core
"*************************************************************
let vimplug_exists=expand('~/.config/nvim/autoload/plug.vim')
if has('win32')&&!has('win64')
    let curl_exists=expand('C:\Windows\Sysnative\curl.exe')
else
    let curl_exists=expand('curl')
endif

if !filereadable(vimplug_exists)
    if !executable(curl_exists)
        echoerr "You have to install curl or first install vim-plug yourself!"
        execute "q!"
    endif
    echo "Installing Vim-Plug..."
    echo ""
    silent exec "!"curl_exists" -fLo " . shellescape(vimplug_exists) . " --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    let g:not_finish_vimplug = "yes"
    autocmd VimEnter * PlugInstall
endif

"*************************************************************
"" Settings related to plugins
"*************************************************************
let g:coc_global_extensions = [
            \"coc-angular",
            \"coc-eslint",
            \"coc-fzf-preview",
            \"coc-java",
            \"coc-json",
            \"coc-python",
            \"coc-tsserver",
            \"coc-db",
            \"coc-styled-components"]
"            \"coc-explorer",

call plug#begin(expand('~/.config/nvim/plugged'))

"*************************************************************
"" Plug install packages - Stuff I definitely use
"*************************************************************
Plug 'kyazdani42/nvim-web-devicons'
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'lambdalisue/fern.vim'
Plug 'lambdalisue/fern-git-status.vim'
Plug 'lambdalisue/nerdfont.vim'
Plug 'lambdalisue/glyph-palette.vim'
Plug 'lambdalisue/fern-hijack.vim'
Plug 'lambdalisue/fern-renderer-nerdfont.vim'
"CHADTree conflicts with scrollview and dwm right now
"Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': 'python3 -m chadtree deps'}
Plug 'jlanzarotta/bufexplorer'
Plug 'qpkorr/vim-bufkill'
"Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'tpope/vim-repeat'
Plug 'svermeulen/vim-easyclip'
Plug 'alvan/vim-closetag'
Plug 'tmsvg/pear-tree'
Plug 'OmniSharp/omnisharp-vim'
Plug 'nickspoons/vim-sharpenup'
Plug 'dense-analysis/ale'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'dir': $HOME . '/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'yuki-yano/fzf-preview.vim', { 'branch': 'release/remote', 'do': ':UpdateRemotePlugins'  }
"Plug 'gcmt/wildfire.vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'kana/vim-textobj-user'
Plug 'sgur/vim-textobj-parameter'
Plug 'AckslD/nvim-revJ.lua'

Plug 'tpope/vim-fugitive'
Plug 'sodapopcan/vim-twiggy'
Plug 'samoshkin/vim-mergetool'

Plug 'puremourning/vimspector'
Plug 'mhinz/vim-startify'

Plug 'sheerun/vim-polyglot' " syntax highlighting for all languages!
Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }
Plug 'ntpeters/vim-better-whitespace'
"color scheme
Plug 'dunstontc/vim-vscode-theme'
Plug 'taniarascia/new-moon.vim'
Plug 'jacoborus/tender.vim'
Plug 'christianchiarulli/nvcode-color-schemes.vim'
Plug 'mhartington/oceanic-next'
Plug 'sainnhe/sonokai'
Plug 'sheerun/vim-polyglot'

Plug 'neovim/nvim-lspconfig'
Plug 'kabouzeid/nvim-lspinstall'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'hrsh7th/nvim-compe'
Plug 'onsails/lspkind-nvim'



" UI Stuff
"Plug 'psliwka/vim-smoothie' " Smooth scrolling, probably better on local
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'ryanoasis/vim-devicons'
Plug 'Yggdroot/indentLine'
Plug 'lukas-reineke/indent-blankline.nvim'

Plug 'skywind3000/vim-quickui'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'gcmt/taboo.vim'
"Plug 'wfxr/minimap.vim', {'do': ':!cargo install --locked code-minimap'}
"Plug 'TaDaa/vimade' " nice, but has issues with popup windows
Plug 'dstein64/nvim-scrollview', { 'branch': 'main' }
Plug 'cseickel/dwm.vim'

"*************************************************************
"" Plug install packages - Stuff I might need
"*************************************************************
Plug 'mileszs/ack.vim'
Plug 'liuchengxu/vista.vim'

" SQL Interface
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'

" Snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
" html
Plug 'mattn/emmet-vim'

call plug#end()
