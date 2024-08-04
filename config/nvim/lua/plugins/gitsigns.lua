local gitgutter = {
  'airblade/vim-gitgutter',
  init = function()
    vim.g.gitgutter_sign_added = '┃'
    vim.g.gitgutter_sign_modified = '┃'
    vim.g.gitgutter_sign_removed = '▁'
    vim.g.gitgutter_sign_removed_first_line = '▔'
    vim.g.gitgutter_sign_removed_above_and_below = '🮀'
    vim.g.gitgutter_sign_modified_removed = '┻'
    vim.g.gitgutter_sign_priority = 100
  end
}

local gitsigns = {
  'lewis6991/gitsigns.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim'
  },
  config = function()
    require('gitsigns').setup({
      signs = {
        add          = { text = '┃'},
        change       = { text = '┃'},
        delete       = { text = '▁'},
        topdelete    = { text = '▔'},
        changedelete = { text = '┻'},
      },
      watch_gitdir = {
        interval = 3000,
        follow_files = true
      },
      sign_priority = 100,
    })
  end
}

return gitsigns
