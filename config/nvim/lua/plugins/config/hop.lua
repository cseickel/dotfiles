return function (use)
  use {
    'phaazon/hop.nvim',
    branch = 'v2',
    config = function()
      require("hop").setup()
    end
  }
end
