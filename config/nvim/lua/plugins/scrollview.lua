return {
  "dstein64/nvim-scrollview",
  config = function ()
    require('scrollview').setup({
      current_only = true,
      winblend = 60,
      column = 1,
      signs_on_startup = { 'conflicts', 'diagnostics' },
      diagnostics_severities = { vim.diagnostic.severity.ERROR },
      signs_column = 0,
      diagnostics_error_symbol = { '-', '=', '≡', },
    })
  end
}
