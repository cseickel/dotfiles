require("which-key").register({
    K = { "Show documentation"},
    ["["] = {
        name = "Previous...",
        d = { "<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>",  "Previous Diagnostic" },
        l = { "<cmd>lprevious<cr>",                           "Previous Location List" },
        q = { "<cmd>cprevious<cr>",                           "Previous Quickfix" },
    },
    ["]"] = {
        name = "Next...",
        d = { "<cmd>lua vim.lsp.diagnostic.goto_next()<cr>",  "Next Diagnostic" },
        l = { "<cmd>lnext<cr>",                               "Next Location List" },
        q = { "<cmd>cnext<cr>",                               "Next Quickfix" },
    },
})

require("which-key").register({
    ["."] = { "Set Working Directory" },
    [","] = { "Show Buffers" },
    h = { "<cmd>Telescope help_tags<cr>", "VIM Help" },
    m = { "add Mark" },
    q = { "Show Quickfix" },
    f = {
        name = "File...", -- optional group name
        b = { "<cmd>Telescope buffers<cr>",                   "Switch Buffer" },
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
        d = { "<cmd>lua vim.lsp.buf.definition()<cr>",        "Go to Definition"},
        i = { "<cmd>lua vim.lsp.buf.Implementation()<cr>",    "Go to Implementation"},
        r = { "<cmd>lua vim.lsp.buf.references()<cr>",        "Find References"},
        t = { "<cmd>lua vim.lsp.buf.type_definition()<cr>",   "Go to Type Definition"},
    },
    n = { "<cmd>lua vim.lsp.buf.rename()<cr>",                "Rename symbol" },
    a = { "<cmd>lua vim.lsp.buf.code_action()<cr>",           "Code actions" },
    s = { "<cmd>lua vim.lsp.buf.signature_help()<cr>",        "Show signature help" },
    t = { "<cmd>call ShowTrouble()<cr>",                      "Show Trouble (diagnostics)" },
    T = { "<cmd>TroubleClose<cr>",                            "Close Trouble" },
    z = { ":call ToggleWindowZoom()<cr>",                     "Zoom Window (toggle)" },
}, { prefix = "<leader>" })
