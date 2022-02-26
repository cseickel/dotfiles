return function ()
  vim.cmd([[
  highlight IndentBlanklineChar guifg=#303030
  highlight IndentBlanklineContextChar guifg=#585858
  ]])

  require("indent_blankline").setup({
    char = '▏',
    space_char = " ",
    space_char_blank_line = " ",
    show_current_context = true,
    buftype_exclude = { "terminal" },
    filetype_exclude = { "NvimTree", "neo-tree", "help", "startify", "packer", "lsp-installer"}
  })
end
