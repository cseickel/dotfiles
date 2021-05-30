local vim = vim
vim.o.completeopt = "menuone,noselect"
local custom_border = { " ", "▁", " ", "▏", " ", "▔", " ", "▕" }
vim.lsp.handlers["textDocument/hover"] =
  vim.lsp.with(
  vim.lsp.handlers.hover,
  {
    border = 'single'
  }
)

vim.lsp.handlers["textDocument/signatureHelp"] =
  vim.lsp.with(
  vim.lsp.handlers.signature_help,
  {
    border = 'single'
  }
)

require'lsp_signature'.on_attach({
    bind = true, -- This is mandatory, otherwise border config won't get registered.
    handler_opts = {
        border = "single"
    },
})
require'compe'.setup {
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

LspInstall = require'lspinstall'
Compe = require'compe'
local function setup_servers()
	LspInstall.setup()
	local servers = LspInstall.installed_servers()
	for _, server in pairs(servers) do
		require'lspconfig'[server].setup{
            capabilities = capabilities,
            on_attach = require'lsp_signature'.on_attach
        };
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
		enable = false
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
      Method = 'ƒ',
      Function = '',
      Constructor = '',
      Variable = '',
      Class = '',
      Interface = 'ﰮ',
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

local omnisharp_data = {}
local function omnisharp_callback()
    return omnisharp_data.callback
end

--function _G.omnisharp_complete(items)
--    for _, item in pairs(items) do
--        item.user_data = vim.fn.json_encode({ hover = item.info })
--        item.dup = 0
--    end
--    omnisharp_data.callback = false
--    omnisharp_data.items = items
--end
--
--local function omnisharp_trigger(prefix, score_func)
--    vim.api.nvim_call_function('OmniSharpTrigger',{ prefix })
--    omnisharp_data.callback = true
--end
--require('completion').addCompletionSource('omnisharp', {  
--    item = omnisharp_complete,
--    trigger = omnisharp_trigger,
--    callback = omnisharp_callback
--})
--
--vim.g.completion_chain_complete_list = {
--    default = {
--        { ins_complete = false, complete_items = { 'lsp', 'UltiSnips', 'path' } },
--        { ins_complete = false, complete_items = { 'lsp'} },
--        { ins_complete = false, complete_items = { 'UltiSnips' } },
--        { ins_complete = false, complete_items = { 'path' } },
--    },
--    cs = {
--        { ins_complete = false, complete_items = { 'path', 'UltiSnips', 'buffers' } },
--        { ins_complete = true, mode = { 'omni' } },
--    },
--}

require'trouble'.setup {
    position = "top", -- position of the list can be: bottom, top, left, right
    height = 10, -- height of the trouble list when position is top or bottom
    width = 50, -- width of the list when position is left or right
    icons = true, -- use devicons for filenames
    mode = "lsp_workspace_diagnostics", -- "lsp_workspace_diagnostics", "lsp_document_diagnostics", "quickfix", "lsp_references", "loclist"
    fold_open = "", -- icon used for open folds
    fold_closed = "", -- icon used for closed folds
    action_keys = { -- key mappings for actions in the trouble list
        close = "q", -- close the list
        cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
        refresh = "r", -- manually refresh
        jump = {"<cr>", "<tab>"}, -- jump to the diagnostic or open / close folds
        jump_close = {"o"}, -- jump to the diagnostic and close the list
        toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
        toggle_preview = "P", -- toggle auto_preview
        hover = "K", -- opens a small poup with the full multiline message
        preview = "p", -- preview the diagnostic location
        close_folds = {"zM", "zm"}, -- close all folds
        open_folds = {"zR", "zr"}, -- open all folds
        toggle_fold = {"zA", "za"}, -- toggle fold of current file
        previous = "k", -- preview item
        next = "j" -- next item
    },
    indent_lines = true, -- add an indent guide below the fold icons
    auto_open = false, -- automatically open the list when you have diagnostics
    auto_close = false, -- automatically close the list when you have no diagnostics
    auto_preview = false, -- automatyically preview the location of the diagnostic. <esc> to close preview and go back to last window
    auto_fold = false, -- automatically fold a file trouble list at creation
    signs = {
        -- icons / text used for a diagnostic
        error = "",
        warning = "",
        hint = "",
        information = "",
        other = "﫠"
    },
    use_lsp_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
}

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
    prompt_position = "bottom",
    prompt_prefix = "> ",
    selection_caret = "> ",
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "descending",
    layout_strategy = "horizontal",
    layout_defaults = {
      horizontal = {
        mirror = false,
      },
      vertical = {
        mirror = false,
      },
    },
    file_sorter =  require'telescope.sorters'.get_fuzzy_file,
    file_ignore_patterns = {},
    generic_sorter =  require'telescope.sorters'.get_generic_fuzzy_sorter,
    shorten_path = true,
    winblend = 0,
    width = 0.95,
    preview_cutoff = 120,
    results_height = 1,
    results_width = 0.8,
    border = {},
    borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    color_devicons = true,
    use_less = true,
    set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
    file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
    grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
    qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,

    -- Developer configurations: Not meant for general override
    buffer_previewer_maker = require'telescope.previewers'.buffer_previewer_maker
  }
}

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
        --return  math.ceil(math.min(vim.o.lines, math.max(20, vim.o.lines - 14)))
        return  math.ceil(math.min(vim.o.lines, math.max(20, vim.o.lines - 8)))
    end,
    width = function () 
        return math.ceil(math.min(vim.o.columns, math.max(80, vim.o.columns - 30)))
    end 
  }
}

local state = {}

local function open_shadow_win()
    local opts =  {
        relative= 'editor',
        style= 'minimal',
        width= vim.o.columns,
        height= vim.o.lines,
        row= 0,
        col= 0,
    }
    local shadow_winhl = 'Normal:NormalNC,EndOfBuffer:NormalNC'
    local shadow_bufnr = vim.api.nvim_create_buf(false,true)
    local shadow_winid = vim.api.nvim_open_win(shadow_bufnr,true,opts)
    vim.api.nvim_win_set_option(shadow_winid,'winhl',shadow_winhl)
    vim.api.nvim_win_set_option(shadow_winid,'winblend',50)
    return shadow_winid
end

local shadow_term = require('toggleterm.terminal').Terminal:new({
    on_close = function(term)
        vim.api.nvim_win_close(state.shadow_winid, true);
    end,
})

function _G.shadow_term_toggle()
    state.shadow_winid = open_shadow_win()
    shadow_term:toggle()
end
