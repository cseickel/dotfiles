return function()
  require('gitsigns').setup({
    signs = {
      add          = {hl = 'GitGutterAdd'   , text = '┃'},
      change       = {hl = 'GitGutterChange', text = '┃'},
      delete       = {hl = 'GitGutterDelete', text = '▁'},
      topdelete    = {hl = 'GitGutterDelete', text = '▔'},
      changedelete = {hl = 'GitGutterChangeDelete', text = '┻'},
    },
    watch_gitdir = {
      interval = 3000,
      follow_files = true
    }
  })
end
