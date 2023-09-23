return {
  'smoka7/hop.nvim',
  version = '2.*',
  config = function()
    require("hop").setup()
    vim.cmd[[
      noremap ,, <cmd>HopChar2<cr>
      noremap ,. <cmd>lua require("hop").hint_char2({direction = require'hop.hint'.HintDirection.AFTER_CURSOR, hint_offset=1 })<cr>
      noremap ,/ <cmd>HopPattern<cr>
    ]]
  end
}
