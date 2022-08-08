return function(use)
  use {
    'folke/which-key.nvim',
    config = function()
      -- make sure to run this code before calling setup()
      -- refer to the full lists at https://github.com/folke/which-key.nvim/blob/main/lua/which-key/plugins/presets/init.lua
      local presets = require("which-key.plugins.presets")
      presets.operators["v"] = nil

      require("which-key").setup({
        window = {
          border = "single"
        }
      })
    end
  }
end
