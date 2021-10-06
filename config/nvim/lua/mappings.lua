-- make sure to run this code before calling setup()
-- refer to the full lists at https://github.com/folke/which-key.nvim/blob/main/lua/which-key/plugins/presets/init.lua
--local trouble = require('trouble')
local presets = require("which-key.plugins.presets")
presets.operators["v"] = nil


local focus_tree = function()
    require('packer').loader('nvim-tree.lua')
    if require('nvim-tree.view').win_open() then
        vim.cmd("1wincmd w")
    else
        vim.cmd("NvimTreeFindFile")
        vim.cmd("setlocal winhighlight=Normal:NvimTreeNormal,NormalNC:NvimTreeNormalNC")
        vim.cmd("setlocal cursorline")
        local lib = require('nvim-tree.lib')
        local folder = vim.fn.getcwd()
        lib.change_dir(folder)
    end
end

vim.cmd([[
    vmap ;  <cmd>HopChar2<cr>
    vmap gc <cmd>HopChar1<cr>
    vmap gw <cmd>HopWord<cr>
    vmap gl <cmd>HopLine<cr>
    vmap g/ <cmd>HopPattern<cr>
]])
require("which-key").register({
    [";"] = { "<cmd>HopChar2<cr>",         "Hop Bigram" },
    g = {
        name = "Go",
        c = { "<cmd>HopChar1<cr>",         "Hop Character" },
        w = { "<cmd>HopWord<cr>",          "Hop Word" },
        l = { "<cmd>HopLine<cr>",          "Hop Line" },
        ["/"] = { "<cmd>HopPattern<cr>",   "Hop Pattern" },
    },
    h = { "Focus window to the LEFT" },
    j = { "Focus window BELOW" },
    k = { "Focus window ABOVE" },
    l = { "Focus window to the RIGHT" },
    H = { "Previous Tab" },
    L = { "Next Tab" },
    K = { "Show documentation"},
    s = { "Substitute Word" },
    ["\\"] = { focus_tree,                                    "Open  Tree" },
    --["|"] = { "<cmd>NvimTreeClose<cr>",                       "Close Tree" },
    ["|"] = { "<cmd>NvimTreeClose<cr>",                       "Close Tree" },
    ["["] = {
        name = "Previous...",
        d = { "<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>",  "Previous Diagnostic" },
        l = { "<cmd>lprevious<cr>",                           "Previous Location List" },
        q = { "<cmd>cprevious<cr>",                           "Previous Quickfix" },
        x = { "<cmd>ConflictMarkerPrevHunk<cr>",              "Previous Conflict" }
    },
    ["]"] = {
        name = "Next...",
        d = { "<cmd>lua vim.lsp.diagnostic.goto_next()<cr>",  "Next Diagnostic" },
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

local goto_preview = require('goto-preview')

require("which-key").register({
    ["."] = { "Set Working Directory from current file" },
    [","] = { "<cmd>HopChar1<cr>",                            "Hop Character" },
    ["b"] = { "<cmd>BufExplorer<cr>",                         "Show Buffers" },
    ["="] = { "Format Document" },
    a = { "<cmd>lua vim.lsp.buf.code_action()<cr>",             "Code actions" },
    c = {
        name = "Conflict Resolution",
        b = { "<cmd>ConflictMarkerBoth<cr>",                  "Keep Both" },
        o = { "<cmd>ConflictMarkerOurselves<cr>",             "Keep Ourselves (Top/HEAD)" },
        n = { "<cmd>ConflictMarkerOurselves<cr>",             "Keep None" },
        t = { "<cmd>ConflictMarkerThemselves<cr>",            "Keep Themselves (Bottom)" },
    },
    d = { "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>", "Preview Diagnostic" },
    D = { "<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>",    "Show all Diagnostics" },
    h = { "<cmd>Telescope help_tags<cr>",                     "VIM Help" },
    j = { showSymbolFinder,                                   "Jump to Method, Class, etc"},
    J = { "f,ls<cr><esc>",                                    "Newline at next comma" },
    l = { "Show Location List" },
    L = { "Close Location List" },
    m = { "add Mark" },
    q = { "Show Quickfix" },
    Q = { "Close Quickfix" },
    f = {
        name = "File...", -- optional group name
        b = { "<cmd>Telescope file_browser<cr>",              "File Browser" },
        d = { "<cmd>Telescope zoxide list<cr>",               "Directory picker (zoxide)" },
        f = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Find in this file" },
        g = { "<cmd>Telescope live_grep<cr>",                 "Grep" },
        o = { "<cmd>Telescope find_files<cr>",                "Open File" },
        r = { "<cmd>Telescope oldfiles<cr>",                  "Recent Files" },
    },
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
        p = { goto_preview.goto_preview_definition,           "Preview Definition"},
        P = { goto_preview.close_all_win,                     "Close Previews"},
    },
    n = { "<cmd>lua vim.lsp.buf.rename()<cr>",                "Rename symbol" },
    ["?"] = { "<cmd>lua vim.lsp.buf.signature_help()<cr>",    "Show signature help" },
    S = { "Save Terminal (yank)" },
    s = { "Open Saved Terminal (paste)" },
    t = { "Open  Terminal" },
    T = { "Close Terminal" },
    z = { ":call ToggleWindowZoom(0)<cr>",                     "Zoom Window (toggle)" },
    Z = { ":call ToggleWindowZoom(1)<cr>",                     "Zoom Window in Copy Mode (no decorations)" },
}, { prefix = "<leader>" })

