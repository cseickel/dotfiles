-- make sure to run this code before calling setup()
-- refer to the full lists at https://github.com/folke/which-key.nvim/blob/main/lua/which-key/plugins/presets/init.lua
--local trouble = require('trouble')

local presets = require("which-key.plugins.presets")
presets.operators["v"] = nil


local diagSplitState = {}
---Determines if the window exists and is valid.
---@param state table The current state of the plugin.
---@return boolean True if the window exists and is valid, false otherwise.
local window_exists = function(state)
  local window_exists
  local winid = state.winid or 0
  local bufnr = state.bufnr or 0

  if winid < 1 then
    window_exists = false
  else
    window_exists = vim.api.nvim_win_is_valid(winid)
      and vim.api.nvim_win_get_number(winid) > 0
      and vim.api.nvim_win_get_buf(winid) == bufnr
  end

  if not window_exists then
    if bufnr > 0 and vim.api.nvim_buf_is_valid(bufnr) then
      local success, err = pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
      if not success and err:match("E523") then
        vim.schedule_wrap(function()
          vim.api.nvim_buf_delete(bufnr, { force = true })
        end)()
      end
    end
    state.winid = nil
    state.bufnr = nil
  end
  return window_exists
end

local showDiagInNewSplit = function ()
  local NuiSplit = require("nui.split")
  local linenr = vim.api.nvim_win_get_cursor(0)[1]
  local diag = vim.diagnostic.get(0, { lnum = linenr - 1 })
  if #diag == 0 then
    return
  end

  local lines = {}
  for _, d in ipairs(diag) do
    for line in d.message:gmatch("([^\n]*)\n?") do
      table.insert(lines, line)
    end
  end

  if window_exists(diagSplitState) then
    vim.api.nvim_win_set_height(diagSplitState.winid, #lines)
  else
    local win_options = {
      position = "bottom",
      relative = "win",
      size = #lines,
      buf_options = {
        swapfile = false,
        undolevels = -1,
      },
    }
    local win = NuiSplit(win_options)
    win:mount()
    diagSplitState.winid = win.winid
    diagSplitState.bufnr = win.bufnr
  end

  vim.api.nvim_buf_set_lines(diagSplitState.bufnr, 0, -1, true, lines)
end

local showSymbolFinder = function ()
  local preview_width = vim.o.columns - 20 - 65
  if preview_width < 80 then
    preview_width = 80
  end
  local opts= {
    symbols = {
      "interface",
      "class",
      "constructor",
      "method",
    },
    entry_maker = require('telescope-custom').gen_from_lsp_symbols(),
    layout_config = {
      width = { padding=10 },
      preview_width=preview_width
    }
  }
  if vim.bo.filetype == "vim" or vim.bo.filetype == "lua" then
    opts.symbols = { "function" }
  end
  require('telescope.builtin').lsp_document_symbols(opts)
end
local getQuickfixOptions = function()
  local width = math.min(vim.o.columns - 2, 180)
  local height = math.min(vim.o.lines - 10, 60)
  local opt = {
    layout_strategy = 'vertical',
    layout_config = {
      width = width,
      height = height
    },
    entry_maker = require('telescope-custom').gen_from_quickfix({width = width}),
  }
  return opt
end

local showDefinition = function ()
  require("telescope.builtin").lsp_definitions(getQuickfixOptions())
end

local showImplementation = function ()
  require("telescope.builtin").lsp_implementations(getQuickfixOptions())
end

local showReferences = function ()
  require("telescope.builtin").lsp_references(getQuickfixOptions())
end

local showType = function ()
  require("telescope.builtin").lsp_type_definitions(getQuickfixOptions())
end

local getProjectRoot = function()
  local cwd = vim.fn.getcwd()
  local project_dir = cwd
  local match = cwd:match("/invest%-apps/([%w%s%.%-%_]+)")
  if match then
    project_dir = "~/invest-apps/" .. match
  end
  if cwd:find("/.dotfiles/config", 0,  true) then
    project_dir = "~/.dotfiles/config"
  end
  return project_dir
end

local findFile = function ()
  require("telescope.builtin").find_files({cwd=getProjectRoot()})
end

local grepProject = function ()
  require("telescope.builtin").live_grep({cwd=getProjectRoot()})
end

vim.cmd [[
  noremap ,, <cmd>lua require("hop").hint_char2({inclusive_jump=false})<cr>
  noremap ,. <cmd>lua require("hop").hint_char2({inclusive_jump=true})<cr>
]]
local mappings = {
  [";"] = {"<Plug>(buf-surf-back)",               "Previous Buffer"},
  ["'"] = {"<Plug>(buf-surf-forward)",            "Next Buffer"},
  [",,"] = { "Hop Char 2" },
  [",."] = { "Hop AFTER Char 2" },
  h = { "Focus window to the LEFT" },
  j = { "Focus window BELOW" },
  k = { "Focus window ABOVE" },
  l = { "Focus window to the RIGHT" },
  H = { "Start of Line" },
  L = { "End of Line" },
  K = { "Show documentation"},
  ["\\"] = { "<cmd>Neotree current reveal toggle<cr>",             "Open Tree in Current Window" },
  ["|"] = { "<cmd>Neotree reveal<cr>",                      "Open Tree in Sidebar" },
  ["["] = {
      name = "Previous...",
      d = { "<cmd>lua vim.diagnostic.goto_prev()<cr>",      "Previous Diagnostic" },
      g = { "<cmd>Gitsigns prev_hunk<cr>",                  "Previous Git Hunk" },
      h = { "<cmd>lua require('harpoon.ui').nav_prev()<cr>","Previous Harpoon" },
      l = { "<cmd>lprevious<cr>",                           "Previous Location List" },
      q = { "<cmd>cprevious<cr>",                           "Previous Quickfix" },
      x = { "<cmd>ConflictMarkerPrevHunk<cr>",              "Previous Conflict" }
  },
  ["]"] = {
      name = "Next...",
      d = { "<cmd>lua vim.diagnostic.goto_next()<cr>",      "Next Diagnostic" },
      g = { "<cmd>Gitsigns next_hunk<cr>",                  "Next Git Hunk" },
      h = { "<cmd>lua require('harpoon.ui').nav_next()<cr>","Next Harpoon" },
      l = { "<cmd>lnext<cr>",                               "Next Location List" },
      q = { "<cmd>cnext<cr>",                               "Next Quickfix" },
      x = { "<cmd>ConflictMarkerNextHunk<cr>",              "Next Conflict" }
  },
  ["<leader>"] = {
    ["."] = { "Set Working Directory from current file" },
    ["="] = { "<cmd>Neoformat<cr>",                           "Format Document" },
    a = { "<cmd>lua vim.lsp.buf.code_action()<cr>",           "Code actions" },
    b = { "<cmd>Neotree reveal buffers current<cr>",          "Show Buffers Tree" },
    c = {
        name = "Conflict Resolution",
        b = { "<cmd>ConflictMarkerBoth<cr>",                  "Keep Both" },
        o = { "<cmd>ConflictMarkerOurselves<cr>",             "Keep Ourselves (Top/HEAD)" },
        n = { "<cmd>ConflictMarkerOurselves<cr>",             "Keep None" },
        t = { "<cmd>ConflictMarkerThemselves<cr>",            "Keep Themselves (Bottom)" },
    },
    d = { "<cmd>lua vim.diagnostic.open_float()<cr>",         "Preview Diagnostic" },
   -- D = { "<cmd>lua vim.diagnostic.setqflist()<cr>",          "Show all Diagnostics" },
    D = { showDiagInNewSplit,                                 "Show Line Diagnostics in Split" },
    j = { showSymbolFinder,                                   "Jump to Method, Class, etc"},
    J = { "f,ls<cr><esc>",                                    "Newline at next comma" },
    q = { "Show Quickfix" },
    Q = { "Close Quickfix" },
    f = {
        name = "File...", -- optional group name
        b = { "<cmd>Neotree float filebrowser<cr>",           "File Browser" },
        d = { "<cmd>Telescope zoxide list<cr>",               "Directory picker (zoxide)" },
        f = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Find in this file" },
        g = { grepProject,                                    "Grep" },
        o = { findFile,                                       "Open File" },
    },
    g = {
        name = "Go to...",
        --d = { "<cmd>lua vim.lsp.buf.definition()<cr>",        "Go to Definition"},
        --i = { "<cmd>lua vim.lsp.buf.implementation()<cr>",    "Go to Implementation"},
        --r = { "<cmd>lua vim.lsp.buf.references()<cr>",        "Find References"},
        --t = { "<cmd>lua vim.lsp.buf.type_definition()<cr>",   "Go to Type Definition"},
        d = { showDefinition,                                 "Go to Definition"},
        i = { showImplementation,                             "Go to Implementation"},
        r = { showReferences,                                 "Find References"},
        t = { showType,                                       "Go to Type Definition"},
    },
    n = { "<cmd>lua vim.lsp.buf.rename()<cr>",                "Rename symbol" },
    ["?"] = { "<cmd>lua vim.lsp.buf.signature_help()<cr>",    "Show signature help" },
    p = { "<cmd>Gitsigns preview_hunk<cr>",                   "Preview Hunk" },
    r = { "<cmd>Gitsigns reset_hunk<cr>",                     "Reset Hunk" },
    R = { "<cmd>Gitsigns reset_buffer<cr>",                   "Reset Buffer" },
    s = { "<cmd>Neotree reveal git_status current<cr>",       "Show Git Status" },
    t = { "Open  Terminal" },
    T = { "Close Terminal" },
    z = { ":call ToggleWindowZoom(0)<cr>",                     "Zoom Window (toggle)" },
    Z = { ":call ToggleWindowZoom(1)<cr>",                     "Zoom Window in Copy Mode (no decorations)" },
    w = {
        name = "Switch to window...",
        ["1"] = { "Switch to window 1"},
        ["2"] = { "Switch to window 2"},
        ["3"] = { "Switch to window 3"},
        ["4"] = { "Switch to window 4"},
        ["5"] = { "Switch to window 5"},
        ["6"] = { "Switch to window 6"},
        ["7"] = { "Switch to window 7"},
        ["8"] = { "Switch to window 8"},
        ["9"] = { "Switch to window 9"},
        ["0"] = { "Switch to window 10"},
    },
  }
}
require("which-key").register(mappings)

_G.test_symbols = function()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.lsp.buf_request_all(bufnr, "textDocument/documentSymbol", {}, function(...)
    print(vim.inspect(...))
  end)
end

vim.api.nvim_set_keymap("n", ",S", "<cmd>lua _G.test_symbols()<cr>", {noremap = true, silent = true})
