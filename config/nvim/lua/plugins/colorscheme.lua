-- cSpell: disable
local monokai = {
  "loctvl842/monokai-pro.nvim",
  config = function()
    require("monokai-pro").setup({
      filter = "spectrum",
    })
    vim.cmd([[colorscheme monokai-pro]])
  end,
}

local vscode = {
  "Mofiqul/vscode.nvim",
  config = function()
    require("vscode").setup()
    require("vscode").load()
  end,
}

return vscode
