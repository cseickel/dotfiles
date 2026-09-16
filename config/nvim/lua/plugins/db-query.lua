return {
  dir = "~/repos/db-query.nvim",
  lazy = false,
  dependencies = {
    "tpope/vim-dadbod",
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
  },
  opts = {
    connections = function ()
      local abspath = vim.fn.expand("~/.secrets/connections.json")
      if vim.fn.filereadable(abspath) == 1 then
        return vim.json.decode(table.concat(vim.fn.readfile(abspath), "\n"))
      end
      return {}
    end,
    parquet = true,
    format = "csv",
  },
  config = function(_, opts)
    require("db-query").setup(opts)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "sql", "mysql", "plsql" },
      callback = function(event)
        vim.keymap.set("n", "<M-x>", function()
          require("db-query").execute({ csv = true })
        end, { buffer = event.buf, desc = "Execute query" })

        vim.keymap.set("x", "<M-x>", function()
          require("db-query").execute({ visual = true, csv = true })
        end, { buffer = event.buf, desc = "Execute query" })

        vim.keymap.set("n", "<C-CR>", function()
          require("db-query").execute({ statement = true, csv = true })
        end, { buffer = event.buf, desc = "Execute query at cursor" })
      end,
    })
  end,
}
