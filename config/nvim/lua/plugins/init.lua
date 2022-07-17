local function c(name)
  local succuss, func = pcall(require, "plugins.config." .. name)
  if succuss and func then
    return func
  else
    return "require('" .. name .. "').setup({})"
  end
end


local startup = function(use)
  local setup = function(repo, name)
    use { repo, config = "require('" .. name .. "').setup({})" }
  end

  local config = function(name)
    local succuss, func = pcall(require, "plugins.config." .. name)
    if succuss and func then
      func(use)
    end
  end

  use 'wbthomason/packer.nvim'
  use {'lewis6991/impatient.nvim', rocks = 'mpack'}
  use 'nvim-lua/plenary.nvim'

  use "dstein64/nvim-scrollview"
  use "ton/vim-bufsurf"
  config('nvim-ts-autotag')
  config('nvim-navic')
  setup('folke/which-key.nvim', "which-key")
  setup('rmagatti/auto-session', "auto-session")

  use "/home/cseickel/repos/diagnostic-window.nvim/"
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
  use 'wellle/targets.vim'
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

  config 'diffview'
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

  config 'lsp-signature'
  config 'nvim-cmp'
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

