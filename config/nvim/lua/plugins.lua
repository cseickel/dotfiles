return require('packer').startup(function(use)
    use 'kyazdani42/nvim-web-devicons'
    use 'kyazdani42/nvim-tree.lua'

    use 'antoinemadec/FixCursorHold.nvim'
    use 'jlanzarotta/bufexplorer'
    use 'tpope/vim-repeat'
    use 'machakann/vim-sandwich'
    use 'tpope/vim-eunuch'
    use 'airblade/vim-gitgutter'
    use {'junegunn/fzf', dir = '~/.fzf', run = './install --all' }
    use 'junegunn/fzf.vim'
    use 'sindrets/diffview.nvim'
    use 'rhysd/conflict-marker.vim'
    use 'nanotee/zoxide.vim'

    use 'svermeulen/vim-easyclip'
    use 'alvan/vim-closetag'
    use 'tmsvg/pear-tree'
    use 'sbdchd/neoformat'

    use 'mfussenegger/nvim-dap'
    use 'rcarriga/nvim-dap-ui'

    use 'mhinz/vim-startify'

    --use {'rrethy/vim-hexokinase',  run = 'make hexokinase' }
    use { 'norcalli/nvim-colorizer.lua', config = function() require'colorizer'.setup() end }
    use 'christianchiarulli/nvcode-color-schemes.vim'

    -- All of the new functionality in neovim 5
    use 'neovim/nvim-lspconfig'
    use 'kabouzeid/nvim-lspinstall'
    use 'onsails/lspkind-nvim'
    use 'hrsh7th/nvim-compe'
    use 'ray-x/lsp_signature.nvim'
    use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
    use 'nvim-lua/popup.nvim'
    use 'nvim-lua/plenary.nvim'
    use 'nvim-telescope/telescope.nvim'
    use 'nvim-telescope/telescope-fzy-native.nvim'
    use 'jvgrootveld/telescope-zoxide'
    use 'folke/which-key.nvim'
    use 'akinsho/nvim-toggleterm.lua'
    use 'abecodes/tabout.nvim'
    use 'vuki656/package-info.nvim'
    --use 'lewis6991/gitsigns.nvim'
    use 'pwntester/octo.nvim'


    -- UI Stuff
    use 'psliwka/vim-smoothie'
    use 'shadmansaleh/lualine.nvim'
    --use 'kdheepak/tabline.nvim'

    use 'ryanoasis/vim-devicons'
    use 'lukas-reineke/indent-blankline.nvim'
    use 'gcmt/taboo.vim'
    use 'dstein64/nvim-scrollview'
    use 'cseickel/dwm.vim'

    use 'mileszs/ack.vim'

    -- SQL Interface
    use 'tpope/vim-dadbod'
    use 'kristijanhusak/vim-dadbod-ui'

    -- Snippets
    use 'SirVer/ultisnips'
    use 'honza/vim-snippets'
    use 'hrsh7th/vim-vsnip'
    use 'hrsh7th/vim-vsnip-integ'
end)

