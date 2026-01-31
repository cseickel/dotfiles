return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = true,
  keys = {
    { "<leader>cc", nil, desc = "Claude Code" },
    { "<leader>ccs", "<cmd>ClaudeCodeAdd %<cr>", desc = "Send current buffer" },
    { "<leader>ccs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    {
      "<leader>ccs",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Send file",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
    },
    -- Diff management
    { "<leader>cca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ccd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
