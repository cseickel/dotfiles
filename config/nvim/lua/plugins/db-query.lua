local function run_fence_query(cmd)
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local open

  for n, line in ipairs(lines) do
    if line:match("^%s*```") then
      if not open then
        if n > cur then
          break -- next block starts below the cursor
        end
        open = n
      elseif cur <= n then
        if n - open < 2 then
          break -- empty block
        end
        vim.api.nvim_buf_set_mark(0, "<", open + 1, 0, {})
        vim.api.nvim_buf_set_mark(0, ">", n - 1, 0, {})
        vim.cmd("'<,'>DBQuery -f csv")
        return
      else
        open = nil -- block closed above the cursor
      end
    end
  end

  vim.notify("Not inside a code fence", vim.log.levels.WARN)
end

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

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "typescript" },
      callback = function(event)
        vim.keymap.set("n", "<C-CR>", run_fence_query, { buffer = event.buf, desc = "Run DBQuery on the code fence under the cursor" })
        vim.keymap.set("n", "<M-x>", run_fence_query, { buffer = event.buf, desc = "Run DBQuery on the code fence under the cursor" })
      end,
    })
  end,
}
