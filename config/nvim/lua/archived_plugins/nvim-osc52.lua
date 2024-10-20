return {
  'ojroques/nvim-osc52',
  config = function()
    local function copy()
      if vim.v.event.operator == 'y' and vim.v.event.regname == 'c' then
        require('osc52').copy_register('c')
      end
    end

    vim.api.nvim_create_autocmd('TextYankPost', {callback = copy})
  end
}
