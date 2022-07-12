local function c(name)
  local succuss, func = pcall(require, "plugins.config." .. name)
  if succuss and func then
    return func
  else
    return "require('" .. name .. "').setup({})"
  end
end


local startup = function(use)
  vim = vim
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use {'lewis6991/impatient.nvim', rocks = 'mpack'}
  use 'nvim-lua/plenary.nvim'
  use 'dstein64/vim-startuptime'

  --use 'Mofiqul/vscode.nvim'
  use "dstein64/nvim-scrollview"
  use "ton/vim-bufsurf"
  use {
    'rcarriga/nvim-notify',
    config = function()
      --vim.notify = require('notify')
    end
  }

  use {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    config = c("nvim-ts-autotag")
  }
  use { "SmiteshP/nvim-navic", config = c("nvim-navic") }

  use { 'folke/which-key.nvim', config = c("which-key") }

  use { 'rmagatti/auto-session', config = c("auto-session") }

  use { "/home/cseickel/repos/diagnostic-window.nvim/" }
  use {
    "/home/cseickel/repos/neo-tree.nvim",
    --"nvim-neo-tree/neo-tree.nvim",
    --branch = "v2.x",
    requires = {
      "MunifTanjim/nui.nvim",
      'nvim-lua/plenary.nvim',
      'kyazdani42/nvim-web-devicons',
      "/home/cseickel/repos/example-source",
      {
        -- only needed if you want to use the "open_window_picker" command
        's1n7ax/nvim-window-picker',
        config = function()
          require'window-picker'.setup()
        end,
      }
    },
    config = c("neo-tree")
  }

  --This is good if you use multiple windows in tmux, but my screen is too small
  --use({
  --  "aserowy/tmux.nvim",
  --  config = function()
  --    require("tmux").setup({
  --      -- overwrite default configuration
  --      -- here, e.g. to enable default bindings
  --      copy_sync = {
  --        -- enables copy sync and overwrites all register actions to
  --        -- sync registers *, +, unnamed, and 0 till 9 from tmux in advance
  --        enable = true,
  --      },
  --      navigation = {
  --        -- enables default keybindings (C-hjkl) for normal mode
  --        enable_default_keybindings = true,
  --      },
  --      resize = {
  --        -- enables default keybindings (A-hjkl) for normal mode
  --        enable_default_keybindings = true,
  --      }
  --    })
  --  end
  --})

  use { 'kyazdani42/nvim-web-devicons', config = c("nvim-web-devicons") }
  use 'editorconfig/editorconfig-vim'
  --
  -- SQL Interface
  use 'tpope/vim-dadbod'
  use 'kristijanhusak/vim-dadbod-ui'
  use 'kristijanhusak/vim-dadbod-completion'

  use 'antoinemadec/FixCursorHold.nvim'
  use 'tpope/vim-repeat'
  use 'tpope/vim-eunuch'
  use 'tpope/vim-surround'
  use 'tpope/vim-fugitive'
  use { 'wellle/targets.vim' }
  use 'dkarter/bullets.vim'
  use {
    'phaazon/hop.nvim',
    branch = 'v2',
    config = c("hop")
  }

  use {
    'lewis6991/gitsigns.nvim',
    requires = {
      'nvim-lua/plenary.nvim'
    },
    config = c("gitsigns")
  }

  use {'kevinhwang91/nvim-bqf', ft = 'qf'}

  use {
    'sindrets/diffview.nvim',
    opt = true,
    cmd = 'DiffviewOpen',
    config = c("diffview")
  }

  use 'rhysd/conflict-marker.vim'
  use 'nanotee/zoxide.vim'

  use 'svermeulen/vim-cutlass'
  use 'ojroques/vim-oscyank'
  use 'alvan/vim-closetag'
  --use 'tmsvg/pear-tree'
  --use 'sbdchd/neoformat'

  use {
    'mfussenegger/nvim-dap',
    requires = {
      'rcarriga/nvim-dap-ui',
      'rcarriga/cmp-dap',
      'theHamsta/nvim-dap-virtual-text',
    },
    config = c("nvim-dap")
  }

  use {
    'neovim/nvim-lspconfig',
    requires = {
      'williamboman/nvim-lsp-installer',
      'jose-elias-alvarez/nvim-lsp-ts-utils',
      'jose-elias-alvarez/null-ls.nvim',
      --'ray-x/lsp_signature.nvim',
      'nvim-lua/plenary.nvim',
      'b0o/schemastore.nvim'
    },
    config = c("lspconfig")
  }

  use {
    "hrsh7th/nvim-cmp",
    opt = true,
    event='InsertEnter',
    requires = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-calc',
      'hrsh7th/vim-vsnip',
      'hrsh7th/vim-vsnip-integ',
      'rafamadriz/friendly-snippets',
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp-document-symbol",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      {
        'David-Kunz/cmp-npm',
        config = c('cmp-npm')
      },
    },
    config = c("nvim-cmp")
  }

  use 'github/copilot.vim'

  use {
    'onsails/lspkind-nvim',
    opt = true,
    event='InsertEnter',
    config = c("lspkind-nvim")
  }

  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      'nvim-telescope/telescope-fzy-native.nvim',
      --'jvgrootveld/telescope-zoxide',
    },
    config = c("telescope")
  }

  use {
    'vuki656/package-info.nvim',
    requires = { "MunifTanjim/nui.nvim" },
    config = c('package-info')
  }


  -- UI Stuff
  use {
    'rrethy/vim-hexokinase',
    run = 'make hexokinase',
  }

  use 'christianchiarulli/nvcode-color-schemes.vim'
  use 'psliwka/vim-smoothie'
  use 'gcmt/taboo.vim'
  use "itchyny/vim-gitbranch" -- for statusline

  use {
    'lukas-reineke/indent-blankline.nvim',
    config = c("indent-blankline")
  }

  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use { "nvim-treesitter/playground", config = c("playground") }
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = c("nvim-treesitter")
  }

  --use {
  --  "ThePrimeagen/refactoring.nvim",
  --  requires = {
  --    {"nvim-lua/plenary.nvim"},
  --    {"nvim-treesitter/nvim-treesitter"}
  --  },
  --  config = c("refactoring")
  --}

  use {
    'Julian/vim-textobj-variable-segment',
    requires = {
      { 'kana/vim-textobj-user' }
    }
  }
end

return require('packer').startup({
  startup,
  config = {
      display = {
        open_fn = function()
          return require('packer.util').float({ border = 'single' })
        end
      }
  }
})

