
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
            \"coc-db",
            \"coc-eslint",
            \"coc-explorer",
            \"coc-fzf-preview",
            \"coc-java",
            \"coc-json",
            \"coc-python",
            \"coc-tsserver"]
"            \"coc-omnisharp" ,
let g:bufExplorerDisableDefaultKeyMapping=1

call plug#begin(expand('~/.config/nvim/plugged'))

"*************************************************************
"" Plug install packages - Stuff I definitely use
"*************************************************************
Plug 'ryanoasis/vim-devicons'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'lambdalisue/fern.vim'
Plug 'lambdalisue/fern-git-status.vim'
Plug 'lambdalisue/nerdfont.vim'
Plug 'lambdalisue/glyph-palette.vim'
Plug 'lambdalisue/fern-hijack.vim'
Plug 'lambdalisue/fern-renderer-nerdfont.vim'
Plug 'jlanzarotta/bufexplorer'
Plug 'qpkorr/vim-bufkill'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'tpope/vim-repeat'
Plug 'svermeulen/vim-easyclip'
Plug 'alvan/vim-closetag'
Plug 'jiangmiao/auto-pairs'
Plug 'Yggdroot/indentLine'
Plug 'OmniSharp/omnisharp-vim'
Plug 'dense-analysis/ale'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'dir': $HOME . '/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'yuki-yano/fzf-preview.vim', { 'branch': 'release/remote', 'do': ':UpdateRemotePlugins'  }

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb' " required by fugitive to :Gbrowse
Plug 'lambdalisue/gina.vim'
Plug 'samoshkin/vim-mergetool'

Plug 'sheerun/vim-polyglot' " syntax highlighting for all languages!
Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }
Plug 'ntpeters/vim-better-whitespace'

" UI Stuff
"Plug 'psliwka/vim-smoothie' " Smooth scrolling, probably better on local
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'jacoborus/tender.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tomasiser/vim-code-dark'
Plug 'joshdick/onedark.vim'
Plug 'gcmt/taboo.vim'
"Plug 'pacha/vem-tabline'
"Plug 'bagrat/vim-buffet'
Plug 'mhinz/vim-startify'
Plug 'wfxr/minimap.vim', {'do': ':!cargo install --locked code-minimap'}
"*************************************************************
"" Plug install packages - Stuff I might need
"*************************************************************
Plug 'mileszs/ack.vim'

" SQL Interface
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'

" Snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
" html
Plug 'mattn/emmet-vim'

call plug#end()
