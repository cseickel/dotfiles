local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

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

  local module = function(name)
    local succuss, func = pcall(require, "plugins.config." .. name)
    if succuss and func then
      func(use)
    end
  end

  -- dependencies
  use 'wbthomason/packer.nvim'
  use {'lewis6991/impatient.nvim', rocks = 'mpack'}
  use 'nvim-lua/plenary.nvim'
  use "MunifTanjim/nui.nvim"
  module "nvim-web-devicons"

  -- Navigation
  setup('rmagatti/auto-session', "auto-session")
  module "bufsurf"
  module 'neo-tree'
  module "hop"
  module "scrollview"
  module "telescope"
  use 'nanotee/zoxide.vim'
  use "samjwill/nvim-unception"

  -- SQL Interface
  use 'tpope/vim-dadbod'
  use 'kristijanhusak/vim-dadbod-ui'
  use 'kristijanhusak/vim-dadbod-completion'

  -- Git
  module "gitsigns"
  module 'diffview'
  module 'conflict-marker'
  module 'octo'

  -- Lsp / Completion / Format
  use 'editorconfig/editorconfig-vim'
  module "lspconfig"
  module 'lsp-signature'
  --use 'sbdchd/neoformat'
  use 'github/copilot.vim'
  module 'nvim-cmp'
  module "nvim-dap"
  module "lspkind-nvim"
  --setup('vuki656/package-info.nvim', "package-info")
  module 'nvim-ts-autotag'
  use "cseickel/diagnostic-window.nvim"


  -- UI Stuff
  use { 'rrethy/vim-hexokinase', run = 'make hexokinase' }
  use 'christianchiarulli/nvcode-color-schemes.vim'
  use 'psliwka/vim-smoothie'
  module 'taboo' 
  use "itchyny/vim-gitbranch" -- for statusline
  module "indent-blankline"
  module 'nvim-navic'
  module "which-key"
  --module "tundra"

  -- faster edits
  use 'antoinemadec/FixCursorHold.nvim'
  use 'tpope/vim-repeat'
  use 'tpope/vim-eunuch'
  use 'tpope/vim-surround'
  use 'tpope/vim-fugitive'
  use 'wellle/targets.vim'
  use 'dkarter/bullets.vim'
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  module "playground"
  module "nvim-treesitter"
  module "vim-textobj-user"
  use 'svermeulen/vim-cutlass'
  module 'nvim-osc52'
  module 'close-tag'
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

