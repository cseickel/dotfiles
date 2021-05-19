vim.o.completeopt = "menuone,noselect"
LspInstall = require'lspinstall'

local on_attach = function()
    require'compe'.setup({
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
            calc = true;
            nvim_lsp = true;
            nvim_lua = true;
            spell = true;
            ultisnips = true;
            buffer = true;
        };
    }, 0)
end
local function setup_servers()
	LspInstall.setup()
	local servers = LspInstall.installed_servers()
	for _, server in pairs(servers) do
		require'lspconfig'[server].setup{on_attach=on_attach};
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
		disable = { "c_sharp" },  -- list of language that will be disabled
	},
	indent = {
		enable = false
	}
}

require'trouble'.setup {
    height = 10, -- height of the trouble list
    icons = true, -- use devicons for filenames
    mode = "quickfix", -- "lsp_workspace_diagnostics", "lsp_document_diagnostics", "quickfix", "lsp_references", "loclist"
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
    auto_preview = true, -- automatyically preview the location of the diagnostic. <esc> to close preview and go back to last window
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
