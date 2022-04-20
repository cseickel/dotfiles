return function()
  require("toggleterm").setup{
    open_mapping = [[<c-\>]],
    hide_numbers = true, -- hide the number column in toggleterm buffers
    shade_filetypes = {},
    shade_terminals = true,
    start_in_insert = true,
    direction = 'float',
    persist_size = false,

    close_on_exit = true, -- close the terminal window when the process exits
    shell = vim.o.shell, -- change the default shell
    -- This field is only relevant if direction is set to 'float'
    float_opts = {
      border = { " ", "▁", " ", "▏", " ", "▔", " ", "▕" },
      winblend = 0,
      height = function ()
        return  math.ceil(math.min(vim.o.lines, math.max(20, vim.o.lines - 10)))
      end,
      width = function ()
        return math.ceil(math.min(vim.o.columns, math.max(181, vim.o.columns - 30)))
      end
    },
    highlights = {
      FloatBorder = {
        link="VertSplit"
      },
    },
  }
end
