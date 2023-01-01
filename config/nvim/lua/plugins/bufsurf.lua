return {
  "ton/vim-bufsurf",
  config = function()
    vim.cmd([[
      let g:BufSurfIgnore = 'Neo-tree .*'

      function! DeleteBuffer() abort
          BufSurfBack
          bd#
      endfunction

      nnoremap <silent> <M-q>     :call DeleteBuffer()<cr>
    ]])
  end,
}
