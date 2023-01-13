return {
  "ton/vim-bufsurf",
  config = function()
    vim.cmd([[
      function! DeleteBuffer() abort
          BufSurfBack
          bd#
      endfunction

      nnoremap <silent> <M-q>     :call DeleteBuffer()<cr>
    ]])
  end,
}
