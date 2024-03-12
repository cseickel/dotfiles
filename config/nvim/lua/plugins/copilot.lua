return {
  "github/copilot.vim",
  init = function ()
    vim.cmd[[
      imap <silent><script><expr> <C-j> copilot#Accept("\<C-j>")
      imap <silent><script><expr> <RIGHT> copilot#Accept("\<RIGHT>")
      let g:copilot_no_tab_map = v:true
      let g:copilot_filetypes = { 'markdown': v:true }
    ]]
  end,
}
