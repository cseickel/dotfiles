return {
  'gcmt/taboo.vim',
  config = function ()
    vim.cmd[[
      "let g:taboo_tab_format=" %d %f %m %x⎹"
      let g:taboo_tab_format=" %d%U .../%P %m %x▕"
      let g:taboo_renamed_tab_format=" %d %l %m %x▕"
      let g:taboo_close_tab_label = ""
      let g:taboo_modified_tab_flag="פֿ"
    ]]
  end
}
