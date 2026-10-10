return {
    "fei6409/log-highlight.nvim",
    ft = "log",
    init = function()
      local LOG_LINE = "^%[202%d%-%d%d%-%d%dT%d%d:%d%d:%d%d[%.+%-Z][^%]]*%]"
      vim.filetype.add({
        extension = {
          txt = function(_, bufnr)
            for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, 5, false)) do
              if line:match(LOG_LINE) then
                return "log"
              end
            end
            return "text"
          end,
        },
      })
    end,
    opts = {},
  }
