
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
call plug#begin(expand('~/.config/nvim/plugged'))

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
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'samoshkin/vim-mergetool'

Plug 'svermeulen/vim-easyclip'
Plug 'alvan/vim-closetag'
Plug 'tmsvg/pear-tree'

" C Sharp related plugins
Plug 'OmniSharp/omnisharp-vim'
Plug 'nickspoons/vim-sharpenup'
Plug 'hrsh7th/nvim-compe'
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'

"Plug 'dense-analysis/ale'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'dir': $HOME . '/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
"Plug 'tpope/vim-commentary'
"Plug 'kana/vim-textobj-user'
"Plug 'sgur/vim-textobj-parameter'
"Plug 'AckslD/nvim-revJ.lua'

Plug 'mhinz/vim-startify'

Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }
"color scheme
Plug 'jacoborus/tender.vim'
Plug 'christianchiarulli/nvcode-color-schemes.vim'
"Plug 'sheerun/vim-polyglot'

" All of the new functionality in nevim 5 that is not quite stable
Plug 'neovim/nvim-lspconfig'
Plug 'kabouzeid/nvim-lspinstall'
Plug 'onsails/lspkind-nvim'
Plug 'hrsh7th/nvim-compe'
Plug 'ray-x/lsp_signature.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'folke/lsp-trouble.nvim'
"Plug 'folke/lsp-colors.nvim'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'folke/which-key.nvim'
Plug 'akinsho/nvim-toggleterm.lua'

" UI Stuff
"Plug 'psliwka/vim-smoothie' " Smooth scrolling, probably better on local
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'ryanoasis/vim-devicons'
Plug 'Yggdroot/indentLine'
Plug 'lukas-reineke/indent-blankline.nvim'

Plug 'skywind3000/vim-quickui'
Plug 'gcmt/taboo.vim'
"Plug 'wfxr/minimap.vim', {'do': ':!cargo install --locked code-minimap'}
"Plug 'TaDaa/vimade' " nice, but has issues with popup windows
Plug 'dstein64/nvim-scrollview', { 'branch': 'main' }
Plug 'cseickel/dwm.vim'

Plug 'mileszs/ack.vim'

" SQL Interface
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'

" Snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'

call plug#end()
