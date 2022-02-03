local vim = vim
vim.o.completeopt = "menuone,noselect"

vim.fn.sign_define("LspDiagnosticsSignError",
    {text = " ", texthl = "LspDiagnosticsSignError"})
vim.fn.sign_define("LspDiagnosticsSignWarning",
    {text = " ", texthl = "LspDiagnosticsSignWarning"})
vim.fn.sign_define("LspDiagnosticsSignInformation",
    {text = " ", texthl = "LspDiagnosticsSignInformation"})
vim.fn.sign_define("LspDiagnosticsSignHint",
    {text = "", texthl = "LspDiagnosticsSignHint"})

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

vim.cmd'au BufEnter * NeoRoot'
