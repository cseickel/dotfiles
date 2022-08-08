local mine = function(use)
	use {
		"~/repos/neo-tree.nvim",
		requires = { 
      'mrbjarksen/neo-tree-diagnostics.nvim',
		},
    config = function()
      -- See ":help neo-tree-highlights" for a list of available highlight groups
      vim.cmd([[
      "let g:neo_tree_remove_legacy_commands = 1
      hi NeoTreeCursorLine gui=bold guibg=#333333
      ]])

      local config = {
        sources = {
          "filesystem",
          "buffers",
          "git_status",
          "diagnostics",
        },
        close_floats_on_escape_key = true,
        --enable_diagnostics = false,
        --enable_git_status = false,
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
            padding = 2
          },
          git_status = {
            symbols = {
              -- Change type
              added     = "",
              deleted   = "✖",
              modified  = "",
              renamed   = "",
              -- Status type
              untracked = "",
              ignored   = "",
              unstaged  = "",
              staged    = "",
              conflict  = "",
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
        },
        nesting_rules = {
          --ts = { ".d.ts", "js", "css", "html", "scss" }
        },
        window = {
          mapping_options = {
            noremap = true,
            nowait = true,
          },
          mappings = {
            ["a"] = { "add", config = { show_path = "relative" }},
            ["z"] = "close_all_nodes",
            ["Z"] = "expand_all_nodes",
          }
        },
        diagnostics = {
          follow_behavior = { -- Behavior when `follow_current_file` is true
            always_focus_file = false, -- Focus the followed file, even when focus is currently on a diagnostic item belonging to that file.
            expand_followed = true, -- Ensure the node of the followed file is expanded
            collapse_others = false, -- Ensure other nodes are collapsed
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
                }
              }
            end
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
              --{ "source" },
              --{ "code" },
            },
          },
        },
        filesystem = {
          --async_directory_scan = false,
          cwd_target = {
            sidebar = "tab",
            current = "tab",
          },
          hijack_netrw_behavior = "open_current",
          follow_current_file = true,
          group_empty_dirs = true,
          use_libuv_file_watcher = true,
          bind_to_cwd = true,
          filtered_items = {
            visible = false,
            show_hidden_count = true,
            hide_dotfiles = true,
            hide_gitignored = false,
            hide_by_pattern = { }
          },
          find_command = "fd",
          find_args = {
            fd = {
              "--exclude", ".git",
              "--exclude", "node_modules",
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
  }
end

local mem_issue = function(use)
	use {
		"~/repos/neo-tree.nvim",
		requires = { 
			"nvim-lua/plenary.nvim",
			"kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
      'mrbjarksen/neo-tree-diagnostics.nvim',
		},
    config = function()
      -- See ":help neo-tree-highlights" for a list of available highlight groups
      vim.cmd([[
      "let g:neo_tree_remove_legacy_commands = 1
      hi NeoTreeCursorLine gui=bold guibg=#333333
      ]])

      local config = {
        enable_diagnostics = false,
        enable_git_status = false,
        close_floats_on_escape_key = true,
        --enable_diagnostics = false,
        --enable_git_status = false,
        log_level = "trace",
        log_to_file = true,
        open_files_in_last_window = true,
        sort_case_insensitive = true,
        popup_border_style = "rounded", -- "double", "none", "rounded", "shadow", "single" or "solid"
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
        },
        window = {
          mapping_options = {
            noremap = true,
            nowait = true,
          },
          mappings = {
            ["a"] = { "add", config = { show_path = "relative" }},
            ["z"] = "close_all_nodes",
            ["Z"] = "expand_all_nodes",
          }
        },
        filesystem = {
          --async_directory_scan = false,
          cwd_target = {
            sidebar = "tab",
            current = "tab",
          },
          hijack_netrw_behavior = "open_current",
          follow_current_file = false,
          use_libuv_file_watcher = false,
          --filtered_items = {
          --  visible = false,
          --  show_hidden_count = true,
          --  hide_dotfiles = true,
          --  hide_gitignored = false,
          --  hide_by_pattern = { }
          --},
          components = {
            indent = function(_, node)
              local indent = node.level * 2
              local indent_str = string.rep(" ", indent)
              return { text = indent_str }
            end,
            name = function(_, node)
              local highlight = "NeoTreeFileName"
              --local text = node.name
              --if node.type == "directory" then
              --  highlight = highlights.DIRECTORY_NAME
              --  if config.trailing_slash and text ~= "/" then
              --    text = text .. "/"
              --  end
              --end

              --if node.level == 1 then
              --  highlight = highlights.ROOT_NAME
              --else
                --local filtered_by = require("neo-tree.sources.common.components").filtered_by(config, node, state)
                --highlight = filtered_by.highlight or highlight
                --if config.use_git_status_colors then
                --  local git_status = state.components.git_status({}, node, state)
                --  if git_status and git_status.highlight then
                --    highlight = git_status.highlight
                --  end
                --end
              --end

              return {
                text = node.name .. " ",
                highlight = highlight,
              }
            end
          },
          renderers = {
            file = {
              {"indent"},
              {"name"},
            },
            directory = {
              {"indent"},
              {"name"},
            },
          }
        }
      }

      require("neo-tree").setup(config)
    end
  }
end

local issue = function(use)
	use {
		"~/repos/neo-tree.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
			"kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
    config = function()
      require("neo-tree").setup({
        window = {
          width = 30
        },
        filesystem = {
          filtered_items = {
            hide_dotfiles = false,
            hide_hidden = false,
            hide_gitignored = false
          }
        },
        enable_diagnostics = false,
        enable_git_status = false,
      })

    end
	}
end

return mine
