return function()
  local tree_cb = require'nvim-tree.config'.nvim_tree_callback
  function _G.open_nvim_tree_selection(targetWindow)
    local lib = require "nvim-tree.lib"
    local node = lib.get_node_at_cursor()
    local windows = {}
    if node then
      if node.entries ~= nil then
        lib.unroll_dir(node)
      else
        if node.absolute_path then
          local nonFloatingWindowCount = 0
          for _, win in pairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.api.nvim_win_get_config(win).relative == "" then
              nonFloatingWindowCount = nonFloatingWindowCount + 1
              windows[vim.api.nvim_win_get_number(win)] = win;
              if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)) == node.absolute_path then
                vim.api.nvim_set_current_win(win)
                vim.cmd("call DWM_Focus()")
                return
              end
            end
          end
          if nonFloatingWindowCount < 2 then
            vim.cmd("vsplit" .. node.absolute_path)
          else
            if targetWindow == "smart" then
              -- if there are no windows to the right of the "main" window,
              -- then we are not in a tiling layout and we should just reuse
              -- that main window.
              local treeWidth = vim.api.nvim_win_get_width(windows[1])
              local mainWidth = vim.api.nvim_win_get_width(windows[2])
              local combinedWidth = treeWidth + 1 + mainWidth
              if combinedWidth == vim.o.columns then
                targetWindow = "main"
              else
                targetWindow = "new"
              end
            end
            if targetWindow == "main" then
              vim.cmd("2wincmd w")
            elseif targetWindow == "new" then
              vim.cmd("call DWM_New()")
            else
              error("'" .. targetWindow .. "' is not a valid choice for targetWindow in open_nvim_tree_selection(targetWindow)")
            end
            vim.cmd("e " .. node.absolute_path)
          end
        else
          if node.name == [[..]] then
            vim.cmd("tcd ..")
          end
        end
      end
    end
  end
  local lib = require('nvim-tree.lib')
  _G.nvim_tree_toggle_all = function ()
    local pops = require('nvim-tree.populate')
    local state = not pops.config.filter_dotfiles
    pops.config.filter_ignored = state
    pops.config.filter_dotfiles = state
    lib.refresh_tree()
  end
  local opt = {
    auto_close = true,
    update_cwd = false,
    update_focused_file = {
      enable = true,
      update_cwd = true
    },
    diagnostics = {
      enable = true,
    },
    view = {
      width = 40,
      mappings = {
        custom_only = true,
        list = {
          { key = "<CR>",           cb = ":lua _G.open_nvim_tree_selection('smart')<cr>" }, -- open in MAIN if one window, or NEW if multiple
          { key = "<2-LeftMouse>", cb = ":lua _G.open_nvim_tree_selection('smart')<cr>"}, -- open in MAIN if one window, or NEW if multiple
          { key = "e",             cb = tree_cb("edit")}, -- show window chooserF
          { key = "n",             cb = ":lua _G.open_nvim_tree_selection('new')<cr>"},  -- open in NEW windowF
          { key = "m",             cb = ":lua _G.open_nvim_tree_selection('main')<cr>"}, -- open in MAIN windowF
          { key = "<C-t>",         cb = tree_cb("tabnew")},
          { key = ".",             cb = tree_cb("cd")},
          { key = "<BS>",          cb = tree_cb("dir_up")},
          { key = "b",             cb = tree_cb("toggle_open_buffers_only") },
          { key = "h",             cb = "<cmd>lua _G.nvim_tree_toggle_all()<cr>"},
          { key = "R",             cb = tree_cb("refresh") },
          { key = "a",             cb = tree_cb("create")},
          { key = "d",             cb = tree_cb("remove")},
          { key = "r",             cb = tree_cb("rename")},
          { key = "<C-r>",         cb = tree_cb("full_rename")},
          { key = "x",             cb = tree_cb("cut")},
          { key = "c",             cb = tree_cb("copy")},
          { key = "p",             cb = tree_cb("paste")},
          { key = "y",             cb = tree_cb("copy_name")},
          { key = "Y",             cb = tree_cb("copy_path")},
          { key = "gy",            cb = tree_cb("copy_absolute_path")},
          { key = "[c",            cb = tree_cb("prev_git_item")},
          { key = "]c",            cb = tree_cb("next_git_item")},
          { key = "q",             cb = tree_cb("close")},
          { key = "-",             cb = ":call SmartWindowResize('v', 0)<cr>"},
          { key = "=",             cb = ":call SmartWindowResize('v', 1)<cr>"},

        }
      }
    }
  }
  require("nvim-tree").setup(opt)
  vim.cmd([[
function! UpdateNvimTreeBuffers(timerId) abort
lua require('nvim-tree').refresh()
lua require('nvim-tree.lib').redraw()
lua require('nvim-tree').find_file()
endfunction

augroup nvim_tree_autocmds
autocmd!
autocmd BufWinEnter * silent! call UpdateNvimTreeBuffers(0)
autocmd BufDelete * silent! call timer_start(10, 'UpdateNvimTreeBuffers')
augroup END
]])
end
