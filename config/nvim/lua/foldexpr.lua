vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact" },
  callback = function()
    vim.opt_local.foldmethod = "marker"
    vim.opt_local.foldmarker = "#region,#endregion"
    vim.opt_local.foldlevel = 0
  end,
})
