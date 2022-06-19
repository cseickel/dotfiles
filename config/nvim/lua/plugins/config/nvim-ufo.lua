return function ()
  vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
  vim.wo.foldcolumn = '1'
  vim.wo.foldlevel = 99 -- feel free to decrease the value
  vim.wo.foldenable = true

  require('ufo').setup()
end
