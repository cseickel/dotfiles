return {
  "pmizio/typescript-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  config = function()
    local navic = require("nvim-navic")
    local navbuddy = require("nvim-navbuddy")
    local tstools = require("typescript-tools")
    tstools.setup({
      on_attach = function(client, bufnr)
        navic.attach(client, bufnr)
        navbuddy.attach(client, bufnr)
      end,
    })
  end,
}
