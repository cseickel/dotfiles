return {
  "kopecmaciej/vi-sql.nvim",
  config = function()
    require("vi-sql").setup({
      hide_key = "<C-q>",
    })
  end,
  cmd = { "ViSQL", "ViSQLJump" },
  keys = {
    { "<leader>vs", "<cmd>ViSQL<cr>", desc = "Open vi-sql" },
    { "<leader>vj", ":ViSQLJump ", desc = "vi-sql: jump to table", silent = false },
  },
}
