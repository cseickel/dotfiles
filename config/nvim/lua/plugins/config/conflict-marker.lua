return function(use)
  use {
    'rhysd/conflict-marker.vim',
    config = function()
      vim.cmd[[
        " disable the default highlight group
        let g:conflict_marker_highlight_group = ''
        let g:conflict_marker_enable_mappings = 0

        " Include text after begin and end markers in Highlights
        let g:conflict_marker_begin = '^<<<<<<< .*$'
        let g:conflict_marker_end   = '^>>>>>>> .*$'

        highlight ConflictMarkerBegin guibg=#00875f
        highlight ConflictMarkerOurs guibg=#005f5f
        highlight ConflictMarkerTheirs guibg=#005f87
        highlight ConflictMarkerEnd guibg=#5f87af
        highlight ConflictMarkerCommonAncestorsHunk guibg=#754a81
      ]]
    end
  }
end