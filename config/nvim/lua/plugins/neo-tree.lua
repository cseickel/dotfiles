local mine = function(use)
  local M = {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "main",
    dependencies = {
      {
        "mrbjarksen/neo-tree-diagnostics.nvim",
        branch = "refresh-config"
      },
      "miversen33/netman.nvim",
    },
    -- cmd = "Neotree",
    --keys = {
    --  { "\\", "<cmd>Neotree current reveal toggle<cr>", "Open Tree in Current Window" },
    --  { "|", "<cmd>Neotree reveal<cr>", "Open Tree in Sidebar" },
    --},
    config = function()
      local events = require("neo-tree.events")
      -- See ":help neo-tree-highlights" for a list of available highlight groups
      vim.cmd([[
      hi NeoTreeCursorLine gui=bold guibg=#333333
      ]])

      local config = {
        sources = {
          "filesystem",
          "buffers",
          "git_status",
          "diagnostics",
          "netman.ui.neo-tree",
          "document_symbols",
        },
        log_level = "trace",
        log_to_file = false,
        open_files_in_last_window = true,
        sort_case_insensitive = true,
        popup_border_style = "rounded", -- "double", "none", "rounded", "shadow", "single" or "solid"
        default_component_configs = {
          container = {
            --enable_character_fade = false
            --padding_right = 8,
          },
          indent = {
            with_markers = true,
            with_arrows = true,
            with_expanders = true,
            padding = 2,
          },
          git_status = {
            symbols = {
              -- Change type
              added = "+",
              deleted = "✖",
              modified = "M",
              renamed = "",
              -- Status type
              untracked = "",
              ignored = "",
              unstaged = "",
              staged = "",
              conflict = "",
            },
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
            --use_git_status_colors = false,
          },
          created = {
            enabled = false,
          },
        },
        event_handlers = {
          {
            event = events.NEO_TREE_BUFFER_ENTER,
            handler = function()
              vim.cmd("highlight! Cursor blend=100")
            end,
          },
          {
            event = events.NEO_TREE_BUFFER_LEAVE,
            handler = function()
              vim.cmd("highlight! Cursor guibg=#5f87af blend=0")
            end,
          },
          --{
          --  event = "neo_tree_window_before_open",
          --  handler = function(args)
          --    print("neo_tree_window_before_open", vim.inspect(args))
          --  end
          --},
          -- {
          --   event = "neo_tree_window_after_open",
          --   handler = function(args)
          --     if args.position == "left" or args.position == "right" then
          --       vim.cmd("wincmd =")
          --     end
          --   end
          -- },
          --{
          --  event = "neo_tree_window_before_close",
          --  handler = function(args)
          --    print("neo_tree_window_before_close", vim.inspect(args))
          --  end
          --},
          -- {
          --   event = "neo_tree_window_after_close",
          --   handler = function(args)
          --     if args.position == "left" or args.position == "right" then
          --       vim.cmd("wincmd =")
          --     end
          --   end
          -- }
        },
        nesting_rules = {
          --ts = { ".d.ts", "js", "css", "html", "scss" }
        },
        window = {
          auto_expand_width = false,
          width = 40,
          mapping_options = {
            noremap = true,
            nowait = true,
          },
        },
        diagnostics = {
          window = {
            relative = "win",
            position = "bottom",
          },
          follow_behavior = { -- Behavior when `follow_current_file` is true
            always_focus_file = false, -- Focus the followed file, even when focus is currently on a diagnostic item belonging to that file.
            expand_followed = true, -- Ensure the node of the followed file is expanded
            collapse_others = false, -- Ensure other nodes are collapsed
          },
          refresh = {
            delay = 1000, -- Time (in ms) to wait before updating diagnostics. Might resolve some issues with Neovim hanging.
            event = "vim_diagnostic_changed", -- Event to use for updating diagnostics (for example `"neo_tree_buffer_enter"`)
            -- Set to `false` or `"none"` to disable automatic refreshing
            max_items = 100, -- The maximum number of diagnostic items to attempt processing
            -- Set to `false` for no maximum
          },
          components = {
            linenr = function(config, node)
              local lnum = tostring(node.extra.diag_struct.lnum + 1)
              local pad = string.rep(" ", 4 - #lnum)
              return {
                {
                  text = pad .. lnum,
                  highlight = "LineNr",
                },
                {
                  text = "▕ ",
                  highlight = "NeoTreeDimText",
                },
              }
            end,
          },
          renderers = {
            file = {
              { "indent" },
              { "icon" },
              { "grouped_path" },
              { "name", highlight = "NeoTreeFileNameOpened" },
              --{ "diagnostic_count", show_when_none = true },
              { "diagnostic_count", highlight = "NeoTreeDimText", severity = "Error", right_padding = 0 },
              { "diagnostic_count", highlight = "NeoTreeDimText", severity = "Warn", right_padding = 0 },
              { "diagnostic_count", highlight = "NeoTreeDimText", severity = "Info", right_padding = 0 },
              { "diagnostic_count", highlight = "NeoTreeDimText", severity = "Hint", right_padding = 0 },
              { "clipboard" },
            },
            diagnostic = {
              { "indent" },
              { "icon" },
              { "linenr" },
              { "name" },
              { "source" },
              --{ "code" },
            },
          },
        },
        document_symbols = {
          follow_cursor = true,
        },
        buffers = {
          window = {
            auto_expand_width = false,
            width = 40,
            mapping_options = {
              noremap = true,
              nowait = true,
            },
            mappings = {
              ["<esc>"] = "cancel",
              ["a"] = { "add", config = { show_path = "relative" } },
              ["l"] = "none",
              ["z"] = "close_all_nodes",
              ["Z"] = "expand_all_nodes",
              ["gu"] = "git_unstage_file",
              ["ga"] = "git_add_file",
              ["gr"] = "git_revert_file",
              ["gc"] = "git_commit",
              ["gp"] = "git_push",
              ["pp"] = "focus_preview",
            },
          },
        },
        filesystem = {
          async_directory_scan = "always",
          scan_mode = "deep",
          cwd_target = {
            sidebar = "tab",
            current = "window",
          },
          check_gitignore_in_search = false,
          hijack_netrw_behavior = "open_current",
          follow_current_file = { enabled = true },
          group_empty_dirs = false,
          use_libuv_file_watcher = true,
          bind_to_cwd = true,
          filtered_items = {
            visible = false,
            show_hidden_count = true,
            hide_dotfiles = true,
            hide_gitignored = true,
          },
          find_command = "fd",
          find_args = {
            fd = {
              "--exclude",
              ".git",
              "--exclude",
              "node_modules",
            },
          },
          find_by_full_path_words = true,
          -- renderers = {
          --   message = {
          --     { "indent", with_markers = true },
          --     { "name", highlight = "NeoTreeMessage" },
          --   },
          -- },
          window = {
            position = "left",
            popup = {
              position = { col = "100%", row = "2" },
              size = function(state)
                local root_name = vim.fn.fnamemodify(state.path, ":~")
                local root_len = string.len(root_name) + 4
                return {
                  width = math.max(root_len, 50),
                  height = vim.o.lines - 6,
                }
              end,
            },
            mappings = {
              ["/"] = "none",
              ["f"] = "fuzzy_sorter",
              ["K"] = "close_node",
              ["J"] = function(state)
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
              ["<space>"] = function(state)
                local node = state.tree:get_node()
                if require("neo-tree.utils").is_expandable(node) then
                  state.commands["toggle_directory"](state)
                else
                  state.commands["close_node"](state)
                end
              end,
              ["<esc>"] = "cancel",
              ["a"] = { "add", config = { show_path = "relative" } },
              ["l"] = "none",
              ["z"] = "close_all_nodes",
              ["Z"] = "expand_all_nodes",
              ["gu"] = "git_unstage_file",
              ["ga"] = "git_add_file",
              ["gr"] = "git_revert_file",
              ["gc"] = "git_commit",
              ["gp"] = "git_push",
              ["pp"] = "focus_preview",
            },
          },
        },
      }

      require("neo-tree").setup(config)
    end,
  }

  local local_repo = vim.fn.expand("~/repos/neo-tree.nvim")
  if vim.fn.isdirectory(local_repo) == 1 then
    M[0] = nil
    M.branch = nil
    M.dir = local_repo
  end
  return M
end

local issue = function()
  return {
    -- file tree
    dir = "~/repos/neo-tree.nvim",
    dependencies = {
      'nvim-lua/plenary.nvim',
      'kyazdani42/nvim-web-devicons',
    },
    keys = {
      { '<leader>e', '<cmd>Neotree show current<cr>' },
      { '<leader>E', '<cmd>Neotree show current reveal=true<cr>' },
    },
    config = function()
      require 'neo-tree'.setup {
        close_if_last_window = true,
        popup_border_style = 'solid',
        enable_git_status = true,
        enable_diagnostics = true,
        default_component_configs = {
          indent = {
            indent_size = 2,
            padding = 1, -- extra padding on left hand side
            with_markers = true,
            indent_marker = '│',
            last_indent_marker = '└',
            highlight = 'NeoTreeIndentMarker',
          },
          icon = {
            folder_closed = '',
            folder_open = '',
            folder_empty = "",
            default = '',
          },
          name = {
            trailing_slash = false,
            use_git_status_colors = true,
          },
        },
        filesystem = {
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false,
          }
        },
      }
    end
  }
end

return mine()
