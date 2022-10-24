return function(use)
  use {
    "dstein64/nvim-scrollview",
    config = function ()
      vim.cmd[[
        let g:scrollview_current_only=1
        let g:scrollview_winblend=60
        let g:scrollview_column=1
      ]]
    end
  }
end
