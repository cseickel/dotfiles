local v2 = {
  'lukas-reineke/indent-blankline.nvim',
  version = '2',
  config = function ()
    vim.cmd([[
    highlight IndentBlanklineChar guifg=#303030
    highlight IndentBlanklineContextChar guifg=#585858 gui=Bold
    ]])

    require("indent_blankline").setup({
      char = '▏',
      space_char = " ",
      space_char_blank_line = " ",
      show_current_context = true,
      buftype_exclude = { "terminal" },
      filetype_exclude = { "NvimTree", "neo-tree", "neo-tree-popup", "help", "lazy", "lsp-installer"}
    })
  end
}

local v3 = {
  'lukas-reineke/indent-blankline.nvim',
  version = '3',
  config = function ()
    vim.cmd([[
    highlight IndentBlanklineChar guifg=#303030
    highlight IndentBlanklineContextChar guifg=#585858 gui=Bold
    ]])

    -- require("indent_blankline").setup({
    --   char = '▏',
    --   space_char = " ",
    --   space_char_blank_line = " ",
    --   show_current_context = true,
    --   buftype_exclude = { "terminal" },
    --   filetype_exclude = { "NvimTree", "neo-tree", "neo-tree-popup", "help", "startify", "packer", "lsp-installer"}
    -- })
    require("ibl").setup({
      indent = {
        char = '▏',
        highlight = "IndentBlanklineChar",
      },
      scope = {
        show_start = false,
        show_end = false,
        highlight = "IndentBlanklineContextChar",
      },
      viewport_buffer = {
        min = 500,
        max = 1000,
      },
      exclude = {
        filetypes = {
          "NvimTree", "neo-tree", "neo-tree-popup",
          "help", "gitcommit", "man",
          "octo", "TelescopePrompt", "TelescopeResults",
          "lazy", "packer", "lsp-installer", "mason"
        },
        buftypes = { "terminal" },
      },
    })
  end
}

return v3
