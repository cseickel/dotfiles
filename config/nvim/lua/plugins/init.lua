local function c(name)
  local succuss, func = pcall(require, "plugins.config." .. name)
  if succuss and func then
    return func
  else
    return "require('" .. name .. "').setup()"
  end
end

local startup = function(use)
  vim = vim

  use {'lewis6991/impatient.nvim', rocks = 'mpack'}
  use '~/repos/plenary.nvim'
  use 'dstein64/vim-startuptime'
  use "dstein64/nvim-scrollview"
  use "dhruvasagar/vim-buffer-history"

  use { 'folke/which-key.nvim', config = c("which-key") }
  use {
    'mrjones2014/legendary.nvim',
    requires = {
      "folke/which-key.nvim",
      'stevearc/dressing.nvim'
    },
    config = c("legendary")
  }

  use { 'rmagatti/auto-session', config = c("auto-session") }

  use {
    "~/repos/neo-tree.nvim",
    --"nvim-neo-tree/neo-tree.nvim",
    --branch = "v1.x",
    requires = {
      "MunifTanjim/nui.nvim",
      --'nvim-lua/plenary.nvim',
      'kyazdani42/nvim-web-devicons',
    },
    config = c("neo-tree")
  }

  use "alec-gibson/nvim-tetris"

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
  use { 'wellle/targets.vim' }
  use 'dkarter/bullets.vim'
  use {
    'phaazon/hop.nvim',
    --branch = 'v1',
    config = c("hop")
  }
  --use 'airblade/vim-gitgutter'
  use {
    'lewis6991/gitsigns.nvim',
    --requires = {
      --'nvim-lua/plenary.nvim'
    --},
    config = c("gitsigns")
  }

  use {'kevinhwang91/nvim-bqf', ft = 'qf'}
  use { 'junegunn/fzf', dir = '~/.fzf', run = './install --all' }
  use 'junegunn/fzf.vim'
  use { 'sindrets/diffview.nvim', opt = true, cmd = 'DiffviewOpen',
    config = function()
      local cb = require'diffview.config'.diffview_callback
      require'diffview'.setup {
        diff_binaries = false,    -- Show diffs for binaries
        file_panel = {
          width = 40,
          use_icons = true        -- Requires nvim-web-devicons
        },
        key_bindings = {
          disable_defaults = false,                   -- Disable the default key bindings
          -- The `view` bindings are active in the diff buffers, only when the current
          -- tabpage is a Diffview.
          view = {
            ["j"]             = cb("next_entry"),         -- Bring the cursor to the next file entry
            ["<down>"]        = cb("next_entry"),
            ["k"]             = cb("prev_entry"),         -- Bring the cursor to the previous file entry.
            ["<up>"]          = cb("prev_entry"),
            ["\\"]            = cb("focus_files"),        -- Bring focus to the files panel
            ["|"]             = cb("toggle_files"),       -- Toggle the files panel.
          },
          file_panel = {
            ["j"]             = cb("next_entry"),         -- Bring the cursor to the next file entry
            ["<down>"]        = cb("next_entry"),
            ["k"]             = cb("prev_entry"),         -- Bring the cursor to the previous file entry.
            ["<up>"]          = cb("prev_entry"),
            ["<cr>"]          = cb("select_entry"),       -- Open the diff for the selected entry.
            ["<2-LeftMouse>"] = cb("select_entry"),
            ["<space>"]       = cb("toggle_stage_entry"), -- Stage / unstage the selected entry.
            ["a"]             = cb("stage_all"),          -- Stage all entries.
            ["A"]             = cb("unstage_all"),        -- Unstage all entries.
            ["R"]             = cb("refresh_files"),      -- Update stats and entries in the file list.
            ["\\"]            = cb("focus_files"),        -- Bring focus to the files panel
            ["|"]             = cb("toggle_files"),       -- Toggle the files panel.
          }
        }
      }
    end
  }
  use 'rhysd/conflict-marker.vim'
  use 'nanotee/zoxide.vim'

  use 'svermeulen/vim-cutlass'
  use 'ojroques/vim-oscyank'
  use 'alvan/vim-closetag'
  use 'tmsvg/pear-tree'
  use 'sbdchd/neoformat'

  use {
    'mfussenegger/nvim-dap',
    requires = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
    },
    config = c("nvim-dap")
  }

  use 'mhinz/vim-startify'

  use { 'norcalli/nvim-colorizer.lua', config = c('colorizer') }
  use 'christianchiarulli/nvcode-color-schemes.vim'

  use {
    'williamboman/nvim-lsp-installer',
    requires = {
      {
        'ray-x/lsp_signature.nvim',
        --commit="be39dacc17d51531f9e3a50f88de0a45683c6634"
      },
      'neovim/nvim-lspconfig',
      'jose-elias-alvarez/nvim-lsp-ts-utils',
      'jose-elias-alvarez/null-ls.nvim',
      --'nvim-lua/plenary.nvim',
      'b0o/schemastore.nvim'
    },
    config = c("lspconfig")
    --run = function()
    --    vim.cmd('LspInstall angularls')
    --    vim.cmd('LspInstall bashls')
    --    vim.cmd('LspInstall cssls')
    --    vim.cmd('LspInstall dockerls')
    --    vim.cmd('LspInstall gopls')
    --    vim.cmd('LspInstall graphql')
    --    vim.cmd('LspInstall html')
    --    vim.cmd('LspInstall jdtls')
    --    vim.cmd('LspInstall jsonls')
    --    vim.cmd('LspInstall omnisharp')
    --    vim.cmd('LspInstall pylsp')
    --    vim.cmd('LspInstall sumneko_lua')
    --    vim.cmd('LspInstall tailwindcss')
    --    vim.cmd('LspInstall tsserver')
    --    vim.cmd('LspInstall yamlls')
    --    vim.cmd('lspinstall vimls')
    --    vim.cmd('lspinstall xml')
    --end
  }

  use {
    "hrsh7th/nvim-cmp",
    as = "cmp",
    opt = true,
    event='InsertEnter',
    requires = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-calc',
      --'SirVer/ultisnips',
      --'honza/vim-snippets',
      'hrsh7th/vim-vsnip',
      'hrsh7th/vim-vsnip-integ',
      'rafamadriz/friendly-snippets',
      {
        'David-Kunz/cmp-npm',
        config = c('cmp-npm')
      }
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
      'jvgrootveld/telescope-zoxide',
      "nvim-telescope/telescope-project.nvim"
    },
    config = c("telescope")
  }


  use {
    'akinsho/nvim-toggleterm.lua',
    opt = true,
    keys = "<C-\\>",
    config = c("nvim-toggleterm")
  }

  use { 'ThePrimeagen/harpoon' }
  --use 'abecodes/tabout.nvim'
  use {
    'vuki656/package-info.nvim',
    requires = { "MunifTanjim/nui.nvim" },
    config = c('package-info')
  }


  -- UI Stuff
  use 'psliwka/vim-smoothie'
  use {
    'nvim-lualine/lualine.nvim',
    config = c("lualine")
  }
  use 'gcmt/taboo.vim'

  use 'ryanoasis/vim-devicons'
  use {
    'lukas-reineke/indent-blankline.nvim',
    config = c("indent-blankline")
  }

  --use '~/repos/dwm.vim'
  use {
    'nvim-treesitter/nvim-treesitter',
    commit = '668de0951a36ef17016074f1120b6aacbe6c4515',
    run = ':TSUpdate',
    config = c("nvim-treesitter")
  }


  use {
    'thalesmello/vim-textobj-methodcall',
    requires = {
      { 'kana/vim-textobj-user' }
    }
  }
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

