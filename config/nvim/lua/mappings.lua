-- make sure to run this code before calling setup()
-- refer to the full lists at https://github.com/folke/which-key.nvim/blob/main/lua/which-key/plugins/presets/init.lua
--local trouble = require('trouble')

local presets = require("which-key.plugins.presets")
presets.operators["v"] = nil

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

local openNeotree = function ()
  local cmd = require("neo-tree.command")
  local manager = require("neo-tree.sources.manager")
  cmd.execute({
    action = "focus",
    source = "filesystem",
    position = "current"
  })
  local tabnr = vim.api.nvim_get_current_tabpage()
  local winid = vim.api.nvim_get_current_win()
  local state = manager.get_state("filesystem", tabnr, winid)
  return state
end

local findDirectory = function ()
  local filter = require("neo-tree.sources.filesystem.lib.filter")
  local state = openNeotree()
  filter.show_filter(state, true, "directory")
end

local findFile = function ()
  local filter = require("neo-tree.sources.filesystem.lib.filter")
  local state = openNeotree()
  filter.show_filter(state, true, true)
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

local grepProject = function ()
  require("telescope.builtin").live_grep({cwd=getProjectRoot()})
end

local hop = require('hop')
vim.cmd [[
  noremap ,, <cmd>HopChar2<cr>
  noremap ,. <cmd>lua require("hop").hint_char2({direction = require'hop.hint'.HintDirection.AFTER_CURSOR, hint_offset=1 })<cr>
  noremap ,/ <cmd>HopPattern<cr>
]]
local mappings = {
  [";"] = {"<Plug>(buf-surf-back)",               "Previous Buffer"},
  ["'"] = {"<Plug>(buf-surf-forward)",            "Next Buffer"},
  [",,"] = { "Hop Char 2" },
  [",."] = { "Hop AFTER Char 2" },
  [",."] = { "Hop  Pattern" },
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
      c = { "<cmd>ConflictMarkerPrevHunk<cr>",              "Previous Conflict" },
      d = { "<cmd>lua vim.diagnostic.goto_prev()<cr>",      "Previous Diagnostic" },
      g = { "<cmd>Gitsigns prev_hunk<cr>",                  "Previous Git Hunk" },
      l = { "<cmd>lprevious<cr>",                           "Previous Location List" },
      q = { "<cmd>cprevious<cr>",                           "Previous Quickfix" },
  },
  ["]"] = {
      name = "Next...",
      c = { "<cmd>ConflictMarkerNextHunk<cr>",              "Next Conflict" },
      d = { "<cmd>lua vim.diagnostic.goto_next()<cr>",      "Next Diagnostic" },
      g = { "<cmd>Gitsigns next_hunk<cr>",                  "Next Git Hunk" },
      l = { "<cmd>lnext<cr>",                               "Next Location List" },
      q = { "<cmd>cnext<cr>",                               "Next Quickfix" },
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
    D = { "<cmd>lua require('diagnostic-window').show()<cr>","Show Line Diagnostics in Split" },
    j = { showSymbolFinder,                                   "Jump to Method, Class, etc"},
    J = { "f,ls<cr><esc>",                                    "Newline at next comma" },
    q = { "Show Quickfix" },
    Q = { "Close Quickfix" },
    f = {
        name = "File...", -- optional group name
        d = { findDirectory,                                  "Directory picker (neo-tree)" },
        f = { findFile,                                       "Find File (neo-tree)" },
        g = { grepProject,                                    "Grep" },
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
