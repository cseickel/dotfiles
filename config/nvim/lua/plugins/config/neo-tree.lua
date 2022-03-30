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
    default_component_configs = {
      indent = {
        with_markers = true,
        with_arrows = true,
        padding = 0
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
      }
    },
    nesting_rules = {
      ts = { ".d.ts", "js", "css", "html", "scss" }
    },
    filesystem = {
      hijack_netrw_behavior = "open_current",
      follow_current_file = false,
      use_libuv_file_watcher = true,
      bind_to_cwd = true,
      filtered_items = {
        hide_dotfiles = true,
        hide_gitignored = true,
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
          --["f"] = "fuzzy_finder",
          --["/"] = "none",
          --["o"] = "open",
          ["q"] = "close_window",
          ["D"] = "show_debug_info",
        ["J"] = function(state)
          local tree = state.tree
          local node = tree:get_node()
          local siblings = tree:get_nodes(node:get_parent_id())
          local renderer = require('neo-tree.ui.renderer')
          renderer.focus_node(state, siblings[#siblings]:get_id())
        end,
        ["K"] = function(state)
          local tree = state.tree
          local node = tree:get_node()
          local siblings = tree:get_nodes(node:get_parent_id())
          local renderer = require('neo-tree.ui.renderer')
          renderer.focus_node(state, siblings[1]:get_id())
        end
        },
      },
      commands = {
      },
      components = {
        harpoon_index = harpoon_index,
      },
      --renderers = {
      --  --  directory = {
      --  --    {"icon"},
      --  --    {"name", use_git_status_colors = false},
      --  --    {
      --  --      text = "/",
      --  --      highlight = "NeoTreeDirectoryName",
      --  --    },
      --  --    {"harpoon_index"},
      --  --    {"diagnostics"},
      --  --    {"git_status"},
      --  --  },
      --  file = {
      --    { "indent" },
      --    { "icon" },
      --    {
      --      "container",
      --      width = "100%",
      --      content = {
      --        {
      --          "name",
      --          use_git_status_colors = true,
      --          zindex = 10
      --        },
      --        -- {
      --        --   "symlink_target",
      --        --   zindex = 10,
      --        --   highlight = "NeoTreeSymbolicLinkTarget",
      --        -- },
      --        { "clipboard", zindex = 10 },
      --        { "harpoon_index", zindex = 10 },
      --        { "diagnostics", errors_only = true, zindex = 20, align = "right" },
      --        { "git_status", zindex = 20, align = "right" },
      --      },
      --    },
      --  },
      --},
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
          {"clipboard"},
          {"harpoon_index"},
          {"bufnr"},
          {"diagnostics"},
          {"git_status", highlight = "NeoTreeDimText"},
        }
      }
    }
  }

  require("neo-tree").setup(config)
end


local quickstart = function ()
  -- See ":help neo-tree-highlights" for a list of available highlight groups
      vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

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
            symbols = {
              -- Change type
              added     = "✚",
              deleted   = "✖",
              modified  = "",
              renamed   = "",
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
            ["f"] = "filter_on_submit",
            ["<c-x>"] = "clear_filter",
            ["a"] = "add",
            ["d"] = "delete",
            ["r"] = "rename",
            ["y"] = "copy_to_clipboard",
            ["x"] = "cut_to_clipboard",
            ["p"] = "paste_from_clipboard",
            ["c"] = "copy", -- takes text input for destination
            ["m"] = "move", -- takes text input for destination
            ["q"] = "close_window",
          }
        },
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
        },
        buffers = {
          show_unloaded = true,
          window = {
            mappings = {
              ["bd"] = "buffer_delete",
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
  local config = {
    close_if_last_window = true,
    popup_border_style = 'rounded',
    use_popups_for_input = true,
    enable_git_status = true,
    enable_diagnostics = false,
    default_component_configs = {
      indent = {
        indent_size = 2,
        padding = 0,
        with_markers = true,
        indent_marker = '│',
        last_indent_marker = '└',
        highlight = 'NeoTreeIndentMarker',
      },
      icon = {
        folder_closed = ' ',
        folder_open = ' ',
        folder_empty = '',
        default = '',
      },
      name = {
        trailing_slash = false,
        use_git_status_colors = true,
      },
      git_status = {
        symbols = {
          -- Change type
          added = '+',
          deleted = '',
          modified = '',
          renamed = '➜',
          -- Status type
          untracked = '',
          ignored = '',
          unstaged = '',
          staged = '✓',
          conflict = '',
        },
      },
    },
    renderers = {
      directory = {
        { 'indent' },
        { 'icon' },
        { 'current_filter' },
        { 'name' },
        {
          'symlink_target',
          highlight = 'NeoTreeSymbolicLinkTarget',
        },
        { 'clipboard' },
        { 'git_status' },
      },
      file = {
        { 'indent' },
        { 'icon' },
        {
          'name',
          use_git_status_colors = true,
        },
        {
          'symlink_target',
          highlight = 'NeoTreeSymbolicLinkTarget',
        },
        { 'bufnr' },
        { 'clipboard' },
        { 'git_status' },
      },
    },
    window = {
      position = 'right',
      width = 40,
      mappings = {
        ['o'] = 'open',
        ['<cr>'] = 'open',
        ['S'] = 'open_split',
        ['s'] = 'open_vsplit',
        ['R'] = 'refresh',
        ['a'] = 'add',
        ['d'] = 'delete',
        ['r'] = 'rename',
        ['c'] = 'copy_to_clipboard',
        ['x'] = 'cut_to_clipboard',
        ['p'] = 'paste_from_clipboard',
        ['q'] = 'close_window',

        ['<bs>'] = 'none',
        ['.'] = 'none',
        ['m'] = 'none',
      },
    },
    filesystem = {
      window = {
        mappings = {
          ['H'] = 'toggle_hidden',
          ['I'] = 'toggle_gitignore',
          ['C'] = 'close_node',
          ['z'] = 'close_all_nodes',
          ['<C-x>'] = 'clear_filter',
          ['f'] = 'filter_on_submit',
          ['/'] = 'fuzzy_finder',
          ['h'] = 'navigate_up',
          ['l'] = 'set_root',
        },
      },
      filtered_items = {
        visible = false,
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_by_name = {
          '.DS_Store',
          'thumbs.db',
        },
        never_show = {
          '.DS_Store',
          'thumbs.db',
        },
      },
      follow_current_file = true,
      hijack_netrw_behavior = 'open_default',
      use_libuv_file_watcher = true,
    },
    buffers = {
      show_unloaded = true,
      window = {
        mappings = {
          ['d'] = 'buffer_delete',
        },
      },
    },
    git_status = {
      window = {
        mappings = {
          ['A'] = 'git_add_all',
          ['u'] = 'git_unstage_file',
          ['a'] = 'git_add_file',
          ['d'] = 'git_revert_file',
          ['gc'] = 'git_commit',
          ['gp'] = 'git_push',
        },
      },
    },
  }

  vim.cmd [[
    let g:neo_tree_remove_legacy_commands = 1
    nnoremap <silent> <C-p> <cmd>Neotree toggle reveal<cr>
    nnoremap <silent> <C-b> <cmd>Neotree toggle reveal float buffers<cr>
    nnoremap <silent> <C-g> <cmd>Neotree toggle reveal float git_status<cr>
  ]]

  require('neo-tree').setup(config)
end

local example = function ()
  
  require('neo-tree').setup({
    window = {
      mappings = {
        ["J"] = function(state)
          local tree = state.tree
          local node = tree:get_node()
          local siblings = tree:get_nodes(node:get_parent_id())
          local renderer = require('neo-tree.ui.renderer')
          renderer.focus_node(state, siblings[#siblings]:get_id())
        end,
        ["K"] = function(state)
          local tree = state.tree
          local node = tree:get_node()
          local siblings = tree:get_nodes(node:get_parent_id())
          local renderer = require('neo-tree.ui.renderer')
          renderer.focus_node(state, siblings[1]:get_id())
        end
      }
    }
  })
end

return mine
