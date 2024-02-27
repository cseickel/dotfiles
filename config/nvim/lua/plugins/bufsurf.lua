return {
  "ton/vim-bufsurf",
  init = function ()
    -- ignore terminal buffers and neotree
    vim.g.BufSurfIgnore = [[term:\/\/.+,neo-tree .* \[.*\],^$]]
  end,
}
