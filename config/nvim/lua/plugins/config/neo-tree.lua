local mine = function ()
  -- See ":help neo-tree-highlights" for a list of available highlight groups
  vim.cmd([[
  "let g:neo_tree_remove_legacy_commands = 1
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
    enable_git_status = true,
    log_level = "trace",
    log_to_file = true,
    open_files_in_last_window = false,
    sort_case_insensitive = true,
    popup_border_style = "NC", -- "double", "none", "rounded", "shadow", "single" or "solid"
    use_popups_for_input = true,
    default_component_configs = {
      container = {
        --enable_character_fade = false
      },
      indent = {
        with_markers = true,
        with_arrows = true,
        padding = 0
      },
      git_status = {
        --symbols = {
        --  -- Change type
        --  added     = "+",
        --  deleted   = "✖",
        --  modified  = "*",
        --  renamed   = "",
        --  -- Status type
        --  untracked = "",
        --  ignored   = "",
        --  unstaged  = "",
        --  staged    = "",
        --  conflict  = "",
        --},
        --symbols =false
      },
      --icon = {
      --  folder_closed = "",
      --  folder_open = "",
      --  folder_empty = "ﰊ",
      --  default = "*",
      --},
      name = {
        trailing_slash = true,
      },
    },
    event_handlers = {
      {
        event = "neo_tree_buffer_enter",
        handler = function()
          vim.cmd 'highlight! Cursor blend=100'
        end
      },
      {
        event = "neo_tree_buffer_leave",
        handler = function()
          vim.cmd 'highlight! Cursor guibg=#5f87af blend=0'
        end
      },
      {
        event = "file_opened",
        handler = function(state)
          require("neo-tree").close_all("filesystem")
        end
      },
    },
    nesting_rules = {
      ts = { ".d.ts", "js", "css", "html", "scss" }
    },
    window = {
      mapping_options = {
        noremap = true,
        nowait = true,
      },
      mappings = {
        ["a"] = { "add", config = { show_path = "relative" }}
      }
    },
    filesystem = {
      async_directory_scan = true,
      --hijack_netrw_behavior = "open_current",
      follow_current_file = true,
      use_libuv_file_watcher = true,
      bind_to_cwd = true,
      filtered_items = {
        visible = false,
        hide_dotfiles = true,
        hide_gitignored = true,
        hide_by_pattern = {
          "*custom.lua"
        }
      },
      find_command = "fd",
      find_args = {
        fd = {
          "--exclude", ".git",
        }
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
          ["K"] = "close_node",
          ["J"] = function (state)
            local utils = require("neo-tree.utils")
            local node = state.tree:get_node()
            if utils.is_expandable(node) then
              if not node:is_expanded() then
                require("neo-tree.sources.filesystem").toggle_directory(state, node)
              end
              local children = state.tree:get_nodes(node:get_id())
              if children and #children > 0 then
                local first_child = children[1]
                require("neo-tree.ui.renderer").focus_node(state, first_child:get_id())
              end
            end
          end,
          ["<space>"] = function (state)
            local node = state.tree:get_node()
            if require("neo-tree.utils").is_expandable(node) then
              state.commands["toggle_directory"](state)
            else
              state.commands["close_node"](state)
            end
          end,
          ["S"] = "split_with_window_picker",
          ["s"] = "vsplit_with_window_picker",
        },
      },
    }
  }

  require("neo-tree").setup(config)
end


local quickstart = function ()
      -- Unless you are still migrating, remove the deprecated commands from v1.x
      vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

      -- If you want icons for diagnostic errors, you'll need to define them somewhere:
      vim.fn.sign_define("DiagnosticSignError",
        {text = " ", texthl = "DiagnosticSignError"})
      vim.fn.sign_define("DiagnosticSignWarn",
        {text = " ", texthl = "DiagnosticSignWarn"})
      vim.fn.sign_define("DiagnosticSignInfo",
        {text = " ", texthl = "DiagnosticSignInfo"})
      vim.fn.sign_define("DiagnosticSignHint",
        {text = "", texthl = "DiagnosticSignHint"})
      -- NOTE: this is changed from v1.x, which used the old style of highlight groups
      -- in the form "LspDiagnosticsSignWarning"

      require("neo-tree").setup({
        close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        default_component_configs = {
          indent = {
            indent_size = 2,
            padding = 1, -- extra padding on left hand side
            -- indent guides
            with_markers = true,
            indent_marker = "│",
            last_indent_marker = "└",
            highlight = "NeoTreeIndentMarker",
            -- expander config, needed for nesting files
            with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
            expander_collapsed = "",
            expander_expanded = "",
            expander_highlight = "NeoTreeExpander",
          },
          icon = {
            folder_closed = "",
            folder_open = "",
            folder_empty = "ﰊ",
            default = "*",
          },
          modified = {
            symbol = "[+]",
            highlight = "NeoTreeModified",
          },
          name = {
            trailing_slash = false,
            use_git_status_colors = true,
          },
          git_status = {
            symbols = {
              -- Change type
              added     = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
              modified  = "", -- or "", but this is redundant info if you use git_status_colors on the name
              deleted   = "✖",-- this can only be used in the git_status source
              renamed   = "",-- this can only be used in the git_status source
              -- Status type
              untracked = "",
              ignored   = "",
              unstaged  = "",
              staged    = "",
              conflict  = "",
            }
          },
        },
        window = {
          position = "left",
          width = 40,
          mappings = {
            ["<space>"] = "toggle_node",
            ["<2-LeftMouse>"] = "open",
            ["<cr>"] = "open",
            ["S"] = "open_split",
            ["s"] = "open_vsplit",
            ["t"] = "open_tabnew",
            ["C"] = "close_node",
            ["a"] = "add",
            ["A"] = "add_directory",
            ["d"] = "delete",
            ["r"] = "rename",
            ["y"] = "copy_to_clipboard",
            ["x"] = "cut_to_clipboard",
            ["p"] = "paste_from_clipboard",
            ["c"] = "copy", -- takes text input for destination
            ["m"] = "move", -- takes text input for destination
            ["q"] = "close_window",
            ["R"] = "refresh",
          }
        },
        nesting_rules = {},
        filesystem = {
          filtered_items = {
            visible = false, -- when true, they will just be displayed differently than normal items
            hide_dotfiles = true,
            hide_gitignored = true,
            hide_by_name = {
              ".DS_Store",
              "thumbs.db"
              --"node_modules"
            },
            never_show = { -- remains hidden even if visible is toggled to true
              --".DS_Store",
              --"thumbs.db"
            },
          },
          follow_current_file = true, -- This will find and focus the file in the active buffer every
                                       -- time the current file is changed while the tree is open.
          hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
                                                  -- in whatever position is specified in window.position
                                -- "open_current",  -- netrw disabled, opening a directory opens within the
                                                  -- window like netrw would, regardless of window.position
                                -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
          use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
                                          -- instead of relying on nvim autocmd events.
          window = {
            mappings = {
              ["<bs>"] = "navigate_up",
              ["."] = "set_root",
              ["H"] = "toggle_hidden",
              ["/"] = "fuzzy_finder",
              ["f"] = "filter_on_submit",
              ["<c-x>"] = "clear_filter",
            }
          }
        },
        buffers = {
          show_unloaded = true,
          window = {
            mappings = {
              ["bd"] = "buffer_delete",
              ["<bs>"] = "navigate_up",
              ["."] = "set_root",
            }
          },
        },
        git_status = {
          window = {
            position = "float",
            mappings = {
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

local clean = function ()
end

local issue = function ()
  vim.cmd([[
  let g:neo_tree_remove_legacy_commands = 1
]])

require("neo-tree").setup({
  close_if_last_window = true,
  close_floats_on_escape_key = true,
  default_source = "filesystem",
  enable_diagnostics = true,
  enable_git_status = true,
  git_status_async = true,
  popup_border_style = "rounded",
  resize_timer_interval = -1,
  default_component_configs = {
    indent = {
      indent_size = 2,
      padding = 1,
      -- indent guides
      with_markers = true,
      indent_marker = "│",
      last_indent_marker = "└",
      highlight = "NeoTreeIndentMarker",
      -- expander config, needed for nesting files
      with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
      expander_collapsed = "",
      expander_expanded = "",
      expander_highlight = "NeoTreeExpander",
    },
    icon = {
      folder_closed = "",
      folder_open = "",
      folder_empty = "",
      default = "*",
    },
    modified = {
      symbol = "[+]",
      highlight = "NeoTreeModified",
    },
    name = {
      trailing_slash = false,
      use_git_status_colors = true,
    },
    git_status = {
      align = "right",
      symbols = {
        -- Change type
        added = "✚",
        deleted = "✖",
        modified = "",
        renamed = "",
        -- Status type
        untracked = "",
        ignored = "",
        unstaged = "",
        staged = "",
        conflict = "",
      },
    },
  },
  window = {
    position = "right",
    width = 40,
    mappings = {
      ["<C-s>"] = "open_split",
      ["<C-t>"] = "open_tabnew",
      ["<C-v>"] = "open_vsplit",
      ["<CR>"] = "open",
      ["A"] = "add_directory",
      ["a"] = "add",
      ["df"] = "delete",
      ["dd"] = "cut_to_clipboard",
      ["gq"] = "close_window",
      ["gr"] = "refresh",
      ["h"] = "close_node",
      ["p"] = "paste_from_clipboard",
      ["r"] = "rename",
      ["w"] = "open_with_window_picker",
      ["yy"] = "copy_to_clipboard",
    },
  },
  nesting_rules = {},
  filesystem = {
    renderers = {
      directory = {
        { "indent" },
        { "icon" },
        { "current_filter" },
        { "name", zindex = 10 },
        { "clipboard", zindex = 10 },
        { "diagnostics", errors_only = true, zindex = 20, align = "right" },
      },
      file = {
        { "indent" },
        { "icon" },
        {
          "name",
          use_git_status_colors = true,
          zindex = 10,
        },
        { "clipboard", zindex = 10 },
        { "bufnr", zindex = 10 },
        { "modified", zindex = 20, align = "right" },
        { "diagnostics", zindex = 20, align = "right" },
        { "git_status", zindex = 20, align = "right" },
      },
    },
    filtered_items = {
      visible = false, -- when true, they will just be displayed differently than normal items
      hide_dotfiles = true,
      hide_gitignored = true,
      hide_by_name = {
        ".DS_Store",
        "thumbs.db",
        --"node_modules"
      },
      never_show = { -- remains hidden even if visible is toggled to true
        --".DS_Store",
        --"thumbs.db"
      },
    },
    follow_current_file = true, -- This will find and focus the file in the active buffer every
    -- time the current file is changed while the tree is open.
    hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
    -- in whatever position is specified in window.position
    -- "open_current",  -- netrw disabled, opening a directory opens within the
    -- window like netrw would, regardless of window.position
    -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
    use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
    -- instead of relying on nvim autocmd events.
    window = {
      mappings = {
        ["<BS>"] = "navigate_up",
        ["<CR>"] = "set_root",
        ["g."] = "toggle_dotfiles",
        ["gi"] = "toggle_gitignored",
        ["l"] = "expand_directory_or_edit_file",
        ["o"] = "system_open",
      },
    },
    commands = {
      expand_directory_or_edit_file = function(state)
        local node = state.tree:get_node()
        if node.type == "directory" then
          if not node:is_expanded() then
            require("neo-tree.sources.filesystem").toggle_directory(state, node)
          elseif node:has_children() then
            require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
          end
        elseif node.type == "file" then
          require("neo-tree.sources.common.commands").open(state)
        end
      end,
      system_open = function(state)
        local node = state.tree:get_node()
        local path = node:get_id()
        vim.api.nvim_command("silent !open " .. path)
      end,
      toggle_dotfiles = function(state)
        state.filtered_items.visible = false
        state.filtered_items.hide_dotfiles = not state.filtered_items.hide_dotfiles
        require("neo-tree.sources.manager").refresh("filesystem")
      end,
      toggle_gitignored = function(state)
        state.filtered_items.visible = false
        state.filtered_items.hide_gitignored = not state.filtered_items.hide_gitignored
        require("neo-tree.sources.manager").refresh("filesystem")
      end,
    },
  },
})

vim.cmd([[
  nnoremap <silent> <Leader>E :Neotree toggle<CR>
]])
end

local example = function ()
  
    require("neo-tree").setup({
      window = {
        mappings = {
          ["a"] = {
            "add",
            nowait = true,
            config = {
              show_path = "none" -- "none", "relative", "absolute"
            }
          },
        }
      }
    })
end

return mine
