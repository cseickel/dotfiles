local config = function()
  local cb = require'diffview.config'.diffview_callback
  require'diffview'.setup {
    diff_binaries = false,    -- Show diffs for binaries
    file_panel = {
      width = 40,
      use_icons = true        -- Requires nvim-web-devicons
    },
    key_bindings = {
      disable_defaults = false,                   -- Disable the default key bindings
      -- The `view` bindings are active in the diff buffers, only when the current
      -- tabpage is a Diffview.
      view = {
        ["j"]             = cb("next_entry"),         -- Bring the cursor to the next file entry
        ["<down>"]        = cb("next_entry"),
        ["k"]             = cb("prev_entry"),         -- Bring the cursor to the previous file entry.
        ["<up>"]          = cb("prev_entry"),
        ["\\"]            = cb("focus_files"),        -- Bring focus to the files panel
        ["|"]             = cb("toggle_files"),       -- Toggle the files panel.
      },
      file_panel = {
        ["j"]             = cb("next_entry"),         -- Bring the cursor to the next file entry
        ["<down>"]        = cb("next_entry"),
        ["k"]             = cb("prev_entry"),         -- Bring the cursor to the previous file entry.
        ["<up>"]          = cb("prev_entry"),
        ["<cr>"]          = cb("select_entry"),       -- Open the diff for the selected entry.
        ["<2-LeftMouse>"] = cb("select_entry"),
        ["<space>"]       = cb("toggle_stage_entry"), -- Stage / unstage the selected entry.
        ["a"]             = cb("stage_all"),          -- Stage all entries.
        ["A"]             = cb("unstage_all"),        -- Unstage all entries.
        ["R"]             = cb("refresh_files"),      -- Update stats and entries in the file list.
        ["\\"]            = cb("focus_files"),        -- Bring focus to the files panel
        ["|"]             = cb("toggle_files"),       -- Toggle the files panel.
      }
    }
  }
end

return function(use)
  use {
    'sindrets/diffview.nvim',
    opt = true,
    cmd = 'DiffviewOpen',
    config = config
  }
end
