return {
  dir = "~/repos/db-query.nvim",
  lazy = false,
  dependencies = {
    "tpope/vim-dadbod",
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
  },
  opts = { parquet = true },
  config = function(_, opts)
    require("db-query").setup(opts)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "sql", "mysql", "plsql" },
      callback = function(event)
        vim.keymap.set("n", "<M-x>", function()
          require("db-query").execute()
        end, { buffer = event.buf, desc = "Execute query" })

        vim.keymap.set("x", "<M-x>", function()
          require("db-query").execute({ visual = true })
        end, { buffer = event.buf, desc = "Execute query" })

        require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
      end,
    })
  end,
}
