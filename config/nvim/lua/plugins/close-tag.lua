return {
  "alvan/vim-closetag",
  config = function()
    vim.cmd([[
      let g:closetag_filenames = '*.html,*.xhtml,*.phtml'
      let g:closetag_xhtml_filenames = '*.xhtml,*.jsx'
      let g:closetag_filetypes = 'html,xhtml,phtml'
      let g:closetag_xhtml_filetypes = 'xhtml,jsx'
      let g:closetag_emptyTags_caseSensitive = 1
      let g:closetag_regions = {
      \ 'typescript.tsx': 'jsxRegion,tsxRegion',
      \ 'javascript.jsx': 'jsxRegion',
      \ }
      let g:closetag_shortcut = '>'
      " Add > at current position without closing the current tag,
      let g:closetag_close_shortcut = '<leader>>'
    ]])
  end,
}
