local mine = function ()
  -- See ":help neo-tree-highlights" for a list of available highlight groups
  vim.cmd([[
  let g:neo_tree_remove_legacy_commands = 1
  hi link NeoTreeDirectoryName Directory
  hi link NeoTreeDirectoryIcon NeoTreeDirectoryName
  hi NeoTreeCursorLine gui=bold guibg=#333333
  ]])

  local harpoon_index = function(config, node, state)
    local Marked = require("harpoon.mark")
    local path = node:get_id()
    local succuss, index = pcall(Marked.get_index_of, path)
    if succuss and index and index > 0 then
      return {
        text = string.format(" ⥤ %d", index),
        highlight = config.highlight or "NeoTreeDirectoryIcon",
      }
    else
      return {}
    end
  end


  local config = {
    close_if_last_window = true,
    close_floats_on_escape_key = true,
    git_status_async = true,
    log_level = "debug",
    log_to_file = true,
    open_files_in_last_window = false,
    popup_border_style = "NC", -- "double", "none", "rounded", "shadow", "single" or "solid"
    remove_legacy_commands = true,
    --  enable_git_status = true,
    --  enable_diagnostics = true,
    --  event_handlers = {
    --    {
    --      event = "file_opened",
    --      handler = function(file_path)
    --        require("neo-tree.sources.filesystem").reset_search()
    --      end
    --    },
    --  },
    default_component_configs = {
      indent = {
        with_markers = true,
        padding = 0
      },
      icon = {
        folder_closed = "",
        folder_open = "",
        folder_empty = "ﰊ",
        default = "*",
      },
      name = {
        trailing_slash = true,
      },
    },
    filesystem = {
      hijack_netrw_behavior = "open_split",
      follow_current_file = false,
      use_libuv_file_watcher = true,
      bind_to_cwd = true,
      filters = {
        show_hidden = false,
        respect_gitignore = true,
        --gitignore_source = "git status",
        gitignore_source = "git check-ignore",
        exclude_items = {
          "plugins", "test.lua", "gitconfig"
        },
        show_filtered = {
          exclude = true,
          gitignore = true,
          hidden = true
        }
      },
      find_command = "fd",
      find_args = {
        "--exclude", ".git",
      },
      find_by_full_path_words = true,
      window = {
        position = "left",
        popup = {
          position = { col = "100%", row = "2" },
          size = function(state)
            local root_name = vim.fn.fnamemodify(state.path, ":~")
            local root_len = string.len(root_name) + 4
            return {
              width = math.max(root_len, 50),
              height = vim.o.lines - 6
            }
          end
        },
        mappings = {
          --["f"] = "fuzzy_finder",
          --["/"] = "none",
          --["o"] = "open",
          ["q"] = "close_window",
          ["D"] = "show_debug_info",
        },
      },
      commands = {
      },
      components = {
        harpoon_index = harpoon_index,
      },
      renderers = {
        --  directory = {
        --    {"icon"},
        --    {"name", use_git_status_colors = false},
        --    {
        --      text = "/",
        --      highlight = "NeoTreeDirectoryName",
        --    },
        --    {"harpoon_index"},
        --    {"diagnostics"},
        --    {"git_status"},
        --  },
        file = {
          {"icon"},
          {"name", use_git_status_colors = true},
          {"harpoon_index"},
          {"diagnostics"},
          {"git_status", highlight = "NeoTreeDimText"},
        }
      }
    },
    git_status = {
      window = {
        position = "right",
        mappings = {
          ["q"] = "close_window",
        },
      },
    },
    buffers = {
      window = {
        position = "right",
        mappings = {
          ["q"] = "close_window",
        },
      },
      show_unloaded = true,
      components = {
        harpoon_index = harpoon_index,
      },
      renderers = {
        file = {
          {"icon"},
          {"name", use_git_status_colors = true},
          {"harpoon_index"},
          {"bufnr"},
          {"diagnostics"},
          {"git_status", highlight = "NeoTreeDimText"},
        }
      }
    }
  }

  local config2 = {
    filesystem = {
      window = {
        position = "split"
      }
    }
  }

  require("neo-tree").setup(config)
end


local quickstart = function ()
  -- See ":help neo-tree-highlights" for a list of available highlight groups
  vim.cmd([[
hi link NeoTreeDirectoryName Directory
hi link NeoTreeDirectoryIcon NeoTreeDirectoryName
]])

  require("neo-tree").setup({
    close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_diagnostics = true,
    default_component_configs = {
      indent = {
        indent_size = 2,
        padding = 1, -- extra padding on left hand side
        with_markers = true,
        indent_marker = "│",
        last_indent_marker = "└",
        highlight = "NeoTreeIndentMarker",
      },
      icon = {
        folder_closed = "",
        folder_open = "",
        folder_empty = "ﰊ",
        default = "*",
      },
      name = {
        trailing_slash = false,
        use_git_status_colors = true,
      },
      git_status = {
        highlight = "NeoTreeDimText", -- if you remove this the status will be colorful
      },
    },
    filesystem = {
      filters = { --These filters are applied to both browsing and searching
        show_hidden = false,
        respect_gitignore = true,
      },
      follow_current_file = false, -- This will find and focus the file in the active buffer every
      -- time the current file is changed while the tree is open.
      use_libuv_file_watcher = false, -- This will use the OS level file watchers
      -- to detect changes instead of relying on nvim autocmd events.
      hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
      -- in whatever position is specified in window.position
      -- "open_split",  -- netrw disabled, opening a directory opens within the
      -- window like netrw would, regardless of window.position
      -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
      window = {
        position = "left",
        width = 40,
        mappings = {
          ["<2-LeftMouse>"] = "open",
          ["<cr>"] = "open",
          ["S"] = "open_split",
          ["s"] = "open_vsplit",
          ["C"] = "close_node",
          ["<bs>"] = "navigate_up",
          ["."] = "set_root",
          ["H"] = "toggle_hidden",
          ["I"] = "toggle_gitignore",
          ["R"] = "refresh",
          ["/"] = "fuzzy_finder",
          --["/"] = "filter_as_you_type", -- this was the default until v1.28
          --["/"] = "none" -- Assigning a key to "none" will remove the default mapping
          ["f"] = "filter_on_submit",
          ["<c-x>"] = "clear_filter",
          ["a"] = "add",
          ["d"] = "delete",
          ["r"] = "rename",
          ["c"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["m"] = "move", -- takes text input for destination
          ["q"] = "close_window",
        }
      }
    },
    buffers = {
      show_unloaded = true,
      window = {
        position = "left",
        mappings = {
          ["<2-LeftMouse>"] = "open",
          ["<cr>"] = "open",
          ["S"] = "open_split",
          ["s"] = "open_vsplit",
          ["<bs>"] = "navigate_up",
          ["."] = "set_root",
          ["R"] = "refresh",
          ["a"] = "add",
          ["d"] = "delete",
          ["r"] = "rename",
          ["c"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["bd"] ="buffer_delete",
        }
      },
    },
    git_status = {
      window = {
        position = "float",
        mappings = {
          ["<2-LeftMouse>"] = "open",
          ["<cr>"] = "open",
          ["S"] = "open_split",
          ["s"] = "open_vsplit",
          ["C"] = "close_node",
          ["R"] = "refresh",
          ["d"] = "delete",
          ["r"] = "rename",
          ["c"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["A"]  = "git_add_all",
          ["gu"] = "git_unstage_file",
          ["ga"] = "git_add_file",
          ["gr"] = "git_revert_file",
          ["gc"] = "git_commit",
          ["gp"] = "git_push",
          ["gg"] = "git_commit_and_push",
        }
      }
    }
  })
  vim.cmd([[nnoremap \ :NeoTreeReveal<cr>]])
end

return mine
