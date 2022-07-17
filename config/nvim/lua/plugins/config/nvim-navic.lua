return function(use)
  use {
    "SmiteshP/nvim-navic",
    config = function()
      require("nvim-navic").setup({
        separator = "  "
      })
    end
  }
end
