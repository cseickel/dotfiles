local vim = vim
vim.o.completeopt = "menuone,noselect"

local custom_border = { " ", "▁", " ", "▏", " ", "▔", " ", "▕" }
require'nvim-web-devicons'.setup({ default = true })
vim.fn.sign_define("LspDiagnosticsSignError",
    {text = "", texthl = "LspDiagnosticsSignError"})
vim.fn.sign_define("LspDiagnosticsSignWarning",
    {text = "", texthl = "LspDiagnosticsSignWarning"})
vim.fn.sign_define("LspDiagnosticsSignInformation",
    {text = "", texthl = "LspDiagnosticsSignInformation"})
vim.fn.sign_define("LspDiagnosticsSignHint",
    {text = "", texthl = "LspDiagnosticsSignHint"})
vim.lsp.handlers["textDocument/hover"] =
  vim.lsp.with(
  vim.lsp.handlers.hover,
  {
    border = 'single'
  }
)
--vim.lsp.handlers["textDocument/signatureHelp"] =
--  vim.lsp.with(
--  vim.lsp.handlers.signature_help,
--  {
--    border = 'single'
--  }
--)

--vim.lsp.handlers['textDocument/codeAction'] = require'lsputil.codeAction'.code_action_handler
--vim.lsp.handlers['textDocument/references'] = function() vim.cmd('Trouble lsp_references') end
--vim.lsp.handlers['textDocument/definition'] = function() MyTrouble('lsp_definitions') end
--vim.lsp.handlers['textDocument/declaration'] = require'lsputil.locations'.declaration_handler
--vim.lsp.handlers['textDocument/typeDefinition'] = require'lsputil.locations'.typeDefinition_handler
--vim.lsp.handlers['textDocument/implementation'] = require'lsputil.locations'.implementation_handler
--vim.lsp.handlers['textDocument/documentSymbol'] = require'lsputil.symbols'.document_handler
--vim.lsp.handlers['workspace/symbol'] = require'lsputil.symbols'.workspace_handler

require('compe').setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = true;

  source = {
    path = true;
    buffer = true;
    calc = true;
    nvim_lsp = true;
    nvim_lua = true;
    vsnip = true;
    ultisnips = false;
  };
}

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
    print(vim.fn.pumvisible())
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif vim.fn.call("vsnip#available", {1}) == 1 then
    return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
    print(vim.fn.pumvisible())
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
    return t "<Plug>(vsnip-jump-prev)"
  else
    -- If <S-Tab> is not working in your terminal, change it to <C-h>
    return t "<S-Tab>"
  end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})


local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = {
    'documentation',
    'detail',
    'additionalTextEdits',
  }
}

local function lsp_attach()
    require('lsp_signature').on_attach({
        bind = true,
        handler_opts = {
            border = "single"
        },
        hint_enable = false,
        flags = {
          debounce_text_changes = 150,
        },
        extra_trigger_chars = { "(", "," }
    })
end

LspInstall = require'lspinstall'
Compe = require'compe'
local function setup_servers()
    LspInstall.setup()
    local servers = LspInstall.installed_servers()
    for _, server in pairs(servers) do
        require('lspconfig')[server].setup({
            capabilities = capabilities,
            on_attach = lsp_attach
        });
    end
end

setup_servers()

-- Automatically reload after `:LspInstall <server>` so we don't have to restart neovim
LspInstall.post_install_hook = function ()
    setup_servers() -- reload installed servers
    vim.cmd("bufdo e") -- this triggers the FileType autocmd that starts the server
end

require'nvim-treesitter.configs'.setup {
    ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    highlight = {
        enable = true,              -- false will disable the whole extension
        --disable = { "c_sharp" },  -- list of language that will be disabled
    },
    indent = {
        enable = true
    }
}

require('lspkind').init({
    -- enables text annotations
    --
    -- default: true
    with_text = true,

    -- default symbol map
    -- can be either 'default' or
    -- 'codicons' for codicon preset (requires vscode-codicons font installed)
    --
    -- default: 'default'
    preset = 'default',

    -- override preset symbols
    --
    -- default: {}
    symbol_map = {
      Text = '',
      Method = '',
      Function = '',
      Constructor = '',
      Variable = '',
      Class = '',
      Interface = '',
      Module = '',
      Property = '',
      Unit = '',
      Value = '',
      Enum = '了',
      Keyword = '',
      Snippet = '﬌',
      Color = '',
      File = '',
      Folder = '',
      EnumMember = '',
      Constant = '',
      Struct = '',
      Operator = ''
    },
})

--require'trouble'.setup {
--    position = "bottom", -- position of the list can be: bottom, top, left, right
--    height = 10, -- height of the trouble list when position is top or bottom
--    width = 50, -- width of the list when position is left or right
--    icons = true, -- use devicons for filenames
--    mode = "lsp_workspace_diagnostics", -- "lsp_workspace_diagnostics", "lsp_document_diagnostics", "quickfix", "lsp_references", "loclist"
--    fold_open = "", -- icon used for open folds
--    fold_closed = "", -- icon used for closed folds
--    action_keys = { -- key mappings for actions in the trouble list
--        close = "q", -- close the list
--        cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
--        refresh = "r", -- manually refresh
--        jump = {"<cr>", "<tab>"}, -- jump to the diagnostic or open / close folds
--        jump_close = {"o"}, -- jump to the diagnostic and close the list
--        toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
--        toggle_preview = "P", -- toggle auto_preview
--        hover = "K", -- opens a small poup with the full multiline message
--        preview = "p", -- preview the diagnostic location
--        close_folds = {"zM", "zm"}, -- close all folds
--        open_folds = {"zR", "zr"}, -- open all folds
--        toggle_fold = {"zA", "za"}, -- toggle fold of current file
--        previous = "k", -- preview item
--        next = "j" -- next item
--    },
--    indent_lines = true, -- add an indent guide below the fold icons
--    auto_open = false, -- automatically open the list when you have diagnostics
--    auto_close = false, -- automatically close the list when you have no diagnostics
--    auto_preview = false, -- automatyically preview the location of the diagnostic. <esc> to close preview and go back to last window
--    auto_fold = false, -- automatically fold a file trouble list at creation
--    signs = {
--        -- icons / text used for a diagnostic
--        error = "",
--        warning = "",
--        hint = "",
--        information = "",
--        other = "﫠"
--    },
--    use_lsp_diagnostic_signs = true -- enabling this will use the signs defined in your lsp client
--}

require('telescope').setup{
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case'
    },
    mappings = {
      i = {
        ["<esc>"] = require('telescope.actions').close
      },
    },
    prompt_prefix = "🔍 ",
    selection_caret = " ",
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "ascending",
    layout_strategy = "horizontal",
    layout_config = {
      prompt_position = "top",
      horizontal = {
        width = { padding = 10 },
        height = { padding = 0.1 },
        preview_width = 0.5,
      },
      vertical = {
        width = { padding = 0.05 },
        height = { padding = 1 },
        preview_height = 0.5,
      }
    },
  }
}
require('telescope').load_extension('fzy_native')
require'telescope'.load_extension('zoxide')

require("which-key").setup()

require("dapui").setup({
  icons = {
    expanded = "⯆",
    collapsed = "⯈",
    circular = "↺"
  },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = {"<CR>", "<2-LeftMouse>"},
    open = "o",
    remove = "d",
    edit = "e",
  },
  sidebar = {
    elements = {
      -- You can change the order of elements in the sidebar
      "scopes",
      "stacks",
      "watches"
    },
    width = 40,
    position = "left" -- Can be "left" or "right"
  },
  tray = {
    elements = {
      "repl"
    },
    height = 10,
    position = "bottom" -- Can be "bottom" or "top"
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil   -- Floats will be treated as percentage of your screen.
  }
})

local dap = require('dap')
dap.adapters.netcoredbg = {
  type = 'executable',
  command = '/usr/bin/netcoredbg',
  args = {'--interpreter=vscode'}
}

dap.configurations.cs = {
  {
    type = "netcoredbg",
    name = "launch - netcoredbg",
    request = "launch",
    program = function()
        return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/netcoreapp3.1/', 'file')
    end,
  },
}

require("toggleterm").setup{
  open_mapping = [[<c-\>]],
  hide_numbers = true, -- hide the number column in toggleterm buffers
  shade_filetypes = {},
  shade_terminals = true,
  start_in_insert = true,
  direction = 'float',
  persist_size = false,

  close_on_exit = true, -- close the terminal window when the process exits
  shell = vim.o.shell, -- change the default shell
  -- This field is only relevant if direction is set to 'float'
  float_opts = {
    -- The border key is *almost* the same as 'nvim_win_open'
    -- see :h nvim_win_open for details on borders however
    -- the 'curved' border is a custom border type
    -- not natively supported but implemented in this plugin.
    --border = 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
    border = custom_border,
    winblend = 0,
    highlights = {
      border = "VertSplit",
      background = "Normal",
    },
    height = function ()
        return  math.ceil(math.min(vim.o.lines, math.max(20, vim.o.lines - 10)))
    end,
    width = function ()
        return math.ceil(math.min(vim.o.columns, math.max(181, vim.o.columns - 30)))
    end
  }
}

-- This is not currently being used
--local function open_shadow_win()
--    local opts =  {
--        relative= 'editor',
--        style= 'minimal',
--        width= vim.o.columns,
--        height= vim.o.lines,
--        row= 0,
--        col= 0,
--    }
--    local shadow_winhl = 'Normal:NormalNC,EndOfBuffer:NormalNC'
--    local shadow_bufid = vim.api.nvim_create_buf(false,true)
--    local shadow_winid = vim.api.nvim_open_win(shadow_bufid,true,opts)
--    vim.api.nvim_buf_set_option(shadow_bufid, 'bufhidden', 'delete')
--    vim.api.nvim_win_set_option(shadow_winid, 'winhl', shadow_winhl)
--    vim.api.nvim_win_set_option(shadow_winid, 'winblend', 60)
--    return shadow_winid
--end
--
--local shadow_term = require('toggleterm.terminal').Terminal:new({
--    on_close = function(term)
--        vim.api.nvim_win_close(state.shadow_winid, true);
--    end,
--})
--
--function _G.shadow_term_toggle()
--    state.shadow_winid = open_shadow_win()
--    shadow_term:toggle()
--    local shadow_bufid = vim.api.nvim_win_get_buf(state.shadow_winid)
--    vim.api.nvim_buf_set_name(shadow_bufid, "SHADOW")
--end
--
--vim.cmd([[
--    augroup shadow_term_autocmds
--        autocmd!
--        autocmd WinEnter SHADOW bwipeout!
--    augroup END
--]])

local tree_cb = require'nvim-tree.config'.nvim_tree_callback
function _G.open_nvim_tree_selection(targetWindow)
    local lib = require "nvim-tree.lib"
    local node = lib.get_node_at_cursor()
    local windows = {}
    if node then
        if node.entries ~= nil then
            lib.unroll_dir(node)
        else
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
        end
    end
end
--vim.g.nvim_tree_disable_keybindings = 1
vim.g.nvim_tree_disable_default_keybindings = 1
vim.g.nvim_tree_bindings = {
    { key = "<CR>",           cb = ":lua _G.open_nvim_tree_selection('smart')<cr>" }, -- open in MAIN if one window, or NEW if multiple
    { key = "<2-LeftMouse>", cb = ":lua _G.open_nvim_tree_selection('smart')<cr>"}, -- open in MAIN if one window, or NEW if multiple
    { key = "e",             cb = tree_cb("edit")}, -- show window chooserF
    { key = "n",             cb = ":lua _G.open_nvim_tree_selection('new')<cr>"},  -- open in NEW windowF
    { key = "m",             cb = ":lua _G.open_nvim_tree_selection('main')<cr>"}, -- open in MAIN windowF
    { key = "<C-t>",         cb = tree_cb("tabnew")},
    { key = ".",             cb = tree_cb("cd")},
    { key = "<BS>",          cb = tree_cb("dir_up")},
    { key = "<",             cb = tree_cb("prev_sibling")},
    { key = ">",             cb = tree_cb("next_sibling")},
    { key = "I",             cb = tree_cb("toggle_ignored")},
    { key = "h",             cb = tree_cb("toggle_dotfiles")},
    { key = "R",             cb = tree_cb("refresh")},
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
    { key = "H",            cb = "<cmd>tabprevious<cr>"},
    { key = "L",            cb = "<cmd>tabnext<cr>"}
}


-- Lua
local cb = require'diffview.config'.diffview_callback

require'diffview'.setup {
  diff_binaries = false,    -- Show diffs for binaries
  file_panel = {
    width = 40,
    use_icons = true        -- Requires nvim-web-devicons
  },
  key_bindings = {
    disable_defaults = false,                   -- Disable the default key bindings
    -- The `view` bindings are active in the diff buffers, only when the current
    -- tabpage is a Diffview.
    view = {
        ["j"]             = cb("next_entry"),         -- Bring the cursor to the next file entry
        ["<down>"]        = cb("next_entry"),
        ["k"]             = cb("prev_entry"),         -- Bring the cursor to the previous file entry.
        ["<up>"]          = cb("prev_entry"),
        ["\\"]            = cb("focus_files"),        -- Bring focus to the files panel
        ["|"]             = cb("toggle_files"),       -- Toggle the files panel.
    },
    file_panel = {
        ["j"]             = cb("next_entry"),         -- Bring the cursor to the next file entry
        ["<down>"]        = cb("next_entry"),
        ["k"]             = cb("prev_entry"),         -- Bring the cursor to the previous file entry.
        ["<up>"]          = cb("prev_entry"),
        ["<cr>"]          = cb("select_entry"),       -- Open the diff for the selected entry.
        ["<2-LeftMouse>"] = cb("select_entry"),
        ["<space>"]       = cb("toggle_stage_entry"), -- Stage / unstage the selected entry.
        ["a"]             = cb("stage_all"),          -- Stage all entries.
        ["A"]             = cb("unstage_all"),        -- Unstage all entries.
        ["R"]             = cb("refresh_files"),      -- Update stats and entries in the file list.
        ["\\"]            = cb("focus_files"),        -- Bring focus to the files panel
        ["|"]             = cb("toggle_files"),       -- Toggle the files panel.
    }
  }
}

require('tabout').setup({
    tabkey = '<Tab>', -- key to trigger tabout
    act_as_tab = true, -- shift content if tab out is not possible
    completion = true, -- if the tabkey is used in a completion pum
    tabouts = {
        {open = "'", close = "'"},
        {open = '"', close = '"'},
        {open = '`', close = '`'},
        {open = '(', close = ')'},
        {open = '[', close = ']'},
        {open = '{', close = '}'},
        {open = '<', close = '>'}
    },
    ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
    exclude = {} -- tabout will ignore these filetypes
})

require('package-info').setup()

local custom_theme = require'lualine.themes.wombat'
custom_theme.insert.a.bg = '#ffffaf'
--custom_theme.insert.a.bg = '#d7d700'
custom_theme.replace.a.bg = '#ff5555'
custom_theme.visual.a.bg = '#c586c0'
custom_theme.command = { a = { bg = '#cccccc', fg = '#101010' } }
custom_theme.normal.b.bg = '#6a6a6a'
custom_theme.normal.b.fg = '#bbbbbb'
custom_theme.inactive.c.bg = '#444444'

local cbg = '#363636'
custom_theme.normal.b.bg = '#444444'
custom_theme.normal.b.fg = '#bbbbbb'
custom_theme.normal.y = custom_theme.normal.b
custom_theme.inactive.b = custom_theme.normal.b
custom_theme.inactive.c = { bg = cbg, fg = '#bbbbbb' }
custom_theme.inactive.y = custom_theme.normal.b

custom_theme.normal.c = { bg = cbg, fg = custom_theme.normal.a.bg, gui="bold" }
custom_theme.insert.c = { bg = cbg, fg = custom_theme.insert.a.bg, gui="bold" }
custom_theme.visual.c = { bg = cbg, fg = custom_theme.visual.a.bg, gui="bold" }
custom_theme.replace.c = { bg = cbg, fg = custom_theme.replace.a.bg, gui="bold" }
custom_theme.command.c = { bg = cbg, fg = custom_theme.command.a.bg, gui="bold" }

local diag_config = {
    'diagnostics',
    -- table of diagnostic sources, available sources:
    -- nvim_lsp, coc, ale, vim_lsp
    sources = { 'nvim_lsp' },
    -- displays diagnostics from defined severity
    sections = {'error', 'warn', 'info', 'hint'},
    -- all colors are in format #rrggbb
    symbols = {error = ' ', warn = ' ', info = ' ', hint = ' '}
}
--require'tabline'.setup {enable = false}
require'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = custom_theme,
    --component_separators = {'|', '|'},
    --section_separators = {'', ''},
    --component_separators = { '', '' },
    --section_separators = {'', ''},
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'filetype' },
    lualine_c = { 'filename'},
    lualine_x = { diag_config },
    lualine_y = {  },
    lualine_z = { 'location'},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = { 'filetype'},
    lualine_c = { 'filename' },
    lualine_x = { diag_config },
    lualine_y = { '"WIN #" .. vim.api.nvim_win_get_number(0)' },
    lualine_z = {}
  },
 -- tabline = {
 --       lualine_a = {},
 --       lualine_b = { 'branch' },
 --       lualine_c = {},
 --       lualine_x = { require'tabline'.tabline_tabs },
 --       lualine_y = {},
 --       lualine_z = {},
 -- },
  extensions = { 'nvim-tree', 'quickfix' }
}
