-- make sure to run this code before calling setup()
-- refer to the full lists at https://github.com/folke/which-key.nvim/blob/main/lua/which-key/plugins/presets/init.lua
--local trouble = require('trouble')
local presets = require("which-key.plugins.presets")
presets.operators["v"] = nil


require("which-key").register({
    [";"] = { "Start of Line" },
    ["'"] = { "End of Line" },
    [",p"] = { "<cmd>lua require('harpoon.mark').add_file()<cr>", "Harpoon Add File" },
    [",,"] = { "<cmd>HopChar2<cr>",                      "Hop 2 Char" },
    g = {
        name = "Go to Harpoon...",
        ["1"] = { "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", "File 1" },
        ["2"] = { "<cmd>lua require('harpoon.ui').nav_file(2)<cr>", "File 2" },
        ["3"] = { "<cmd>lua require('harpoon.ui').nav_file(3)<cr>", "File 3" },
        ["4"] = { "<cmd>lua require('harpoon.ui').nav_file(4)<cr>", "File 4" },
        ["5"] = { "<cmd>lua require('harpoon.ui').nav_file(5)<cr>", "File 5" },
        ["6"] = { "<cmd>lua require('harpoon.ui').nav_file(6)<cr>", "File 6" },
        ["7"] = { "<cmd>lua require('harpoon.ui').nav_file(7)<cr>", "File 7" },
        ["8"] = { "<cmd>lua require('harpoon.ui').nav_file(8)<cr>", "File 8" },
        ["9"] = { "<cmd>lua require('harpoon.ui').nav_file(9)<cr>", "File 9" },
        ["0"] = { "<cmd>lua require('harpoon.ui').nav_file(10)<cr>", "File 10" },
    },
    h = { "Focus window to the LEFT" },
    j = { "Focus window BELOW" },
    k = { "Focus window ABOVE" },
    l = { "Focus window to the RIGHT" },
    H = { "Start of Line" },
    L = { "End of Line" },
    K = { "Show documentation"},
    ["\\"] = { "<cmd>NeoTreeReveal<cr>",                     "Open  Tree" },
    ["|"] = { "<cmd>NeoTreeFloat<cr>",                       "Float Tree" },
    ["["] = {
        name = "Previous...",
        d = { "<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>",  "Previous Diagnostic" },
        h = { "<cmd>lua require('harpoon.ui').nav_prev()<cr>", "Previous Harpoon" },
        l = { "<cmd>lprevious<cr>",                           "Previous Location List" },
        q = { "<cmd>cprevious<cr>",                           "Previous Quickfix" },
        x = { "<cmd>ConflictMarkerPrevHunk<cr>",              "Previous Conflict" }
    },
    ["]"] = {
        name = "Next...",
        d = { "<cmd>lua vim.lsp.diagnostic.goto_next()<cr>",  "Next Diagnostic" },
        h = { "<cmd>lua require('harpoon.ui').nav_next()<cr>", "Next Harpoon" },
        l = { "<cmd>lnext<cr>",                               "Next Location List" },
        q = { "<cmd>cnext<cr>",                               "Next Quickfix" },
        x = { "<cmd>ConflictMarkerNextHunk<cr>",              "Next Conflict" }
    },
})

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

require("which-key").register({
  ["<leader>"] = {
    ["."] = { "Set Working Directory from current file" },
    ["="] = { "<cmd>Neoformat<cr>",                           "Format Document" },
    a = { "<cmd>lua vim.lsp.buf.code_action()<cr>",           "Code actions" },
    b = { "<cmd>NeoTreeFocus buffers<cr>",                    "Show Buffers Tree" },
    c = {
        name = "Conflict Resolution",
        b = { "<cmd>ConflictMarkerBoth<cr>",                  "Keep Both" },
        o = { "<cmd>ConflictMarkerOurselves<cr>",             "Keep Ourselves (Top/HEAD)" },
        n = { "<cmd>ConflictMarkerOurselves<cr>",             "Keep None" },
        t = { "<cmd>ConflictMarkerThemselves<cr>",            "Keep Themselves (Bottom)" },
    },
    d = { "<cmd>lua vim.lsp.diagnostic.open_float()<cr>",     "Preview Diagnostic" },
    D = { "<cmd>lua vim.lsp.diagnostic.setqflist()<cr>",      "Show all Diagnostics" },
    H = { "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", "Harpoon Menu" },
    j = { showSymbolFinder,                                   "Jump to Method, Class, etc"},
    J = { "f,ls<cr><esc>",                                    "Newline at next comma" },
    l = { "Show Location List" },
    L = { "Close Location List" },
    q = { "Show Quickfix" },
    Q = { "Close Quickfix" },
    f = {
        name = "File...", -- optional group name
        b = { "<cmd>NeoTreeFloat<cr>",                        "File Browser" },
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
    s = { "<cmd>NeoTreeFloat git_status<cr>",                 "Show Git Status" },
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
})

