return function (use)
  use {
    'sam4llis/nvim-tundra',
    config = function()
      require('nvim-tundra').setup({})
      vim.opt.background = 'dark'
      vim.cmd('colorscheme tundra')
    end
  }
end
