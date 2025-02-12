-------------------------------------------------------------------------------
-- Workspace Diagnostics Plugin
-- https://github.com/artemave/workspace-diagnostics.nvim
-- Populates project-wide lsp diagnostics, regardless of what files are opened.
-------------------------------------------------------------------------------

return {
  "artemave/workspace-diagnostics.nvim",
  event        = { "BufReadPre", "BufNewFile" },
  config = function()
    require("workspace-diagnostics").setup()

    ---------------------------------------------------------------------------
    --- Key Mappings

    vim.api.nvim_set_keymap('n', '<leader>da', '', {
      noremap = true,
      callback = function()
        for _, client in ipairs(vim.lsp.get_clients()) do
          require("workspace-diagnostics").populate_workspace_diagnostics(client, 0)
        end
      end,
      desc = "Populate workspace diagnostics"
    })
  end,
}
