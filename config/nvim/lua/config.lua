local vim = vim
vim.o.completeopt = "menuone,noselect"

local custom_border = { " ", "▁", " ", "▏", " ", "▔", " ", "▕" }
require'nvim-web-devicons'.setup({ default = true })
vim.fn.sign_define("LspDiagnosticsSignError",
    {text = " ", texthl = "LspDiagnosticsSignError"})
vim.fn.sign_define("LspDiagnosticsSignWarning",
    {text = " ", texthl = "LspDiagnosticsSignWarning"})
vim.fn.sign_define("LspDiagnosticsSignInformation",
    {text = " ", texthl = "LspDiagnosticsSignInformation"})
vim.fn.sign_define("LspDiagnosticsSignHint",
    {text = "", texthl = "LspDiagnosticsSignHint"})
vim.lsp.diagnostic.show_line_diagnostics({ border = 'single' })

vim.lsp.handlers["textDocument/hover"] =
  vim.lsp.with(vim.lsp.handlers.hover, {
    -- Use a sharp border with `FloatBorder` highlights
    border = "single",
  })

-- enable border for signature
--vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
--  vim.lsp.handlers.signature_help,
--  {
--    border = "single",
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
            ["<Esc>"] = require('telescope.actions').close,
            ["<C-b>"] = function()
                vim.cmd("close!")
                require('telescope.builtin').file_browser()
            end,
            ["<C-d>"] = function ()
                vim.cmd("close!")
                require('telescope').extensions.zoxide.list()
            end,
            ["<C-f>"] = function()
                vim.cmd("close!")
                require('telescope.builtin').current_buffer_fuzzy_find()
            end,
            ["<C-g>"] = function()
                vim.cmd("close!")
                require('telescope.builtin').live_grep()
            end,
            ["<C-o>"] = function()
                vim.cmd("close!")
                require('telescope.builtin').find_files()
            end,
            ["<C-r>"] = function()
                vim.cmd("close!")
                require('telescope.builtin').oldfiles()
            end,
        }
    },
    pickers = {
        lsp_code_actions = {
            theme = "cursor"
        },
        find_files = {
            hidden = true
        }
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
require("telescope._extensions.zoxide.config").setup({
  mappings = {
    default = {
      after_action = function(selection)
        vim.cmd([[
            func! OpenFileFinder(timer)
                lua require('telescope.builtin').find_files()
            endfunc
            call timer_start(1, "OpenFileFinder", {'repeat': 1})
            ]])
      end
    }
  }
})

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
    size = 40,
    position = "left" -- Can be "left" or "right"
  },
  tray = {
    elements = {
      "repl"
    },
    size = 10,
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


