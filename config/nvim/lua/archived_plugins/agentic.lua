return {
  "carlos-algms/agentic.nvim",

  event = "VeryLazy",

  opts = {
    -- Available by default: "claude-acp" | "gemini-acp" | "codex-acp" | "opencode-acp" | "cursor-acp"
    provider = "claude-acp", -- setting the name here is all you need to get started
    acp_providers = {
        ["claude-acp"] = {
            -- ... other config ...
            env = {
                MEMORY_HOST = os.getenv("MEMORY_HOST"),
                MEMORY_PORT = os.getenv("MEMORY_PORT"),
                MEMORY_DATABASE = os.getenv("MEMORY_DATABASE"),
                MEMORY_USER = os.getenv("MEMORY_USER"),
                MEMORY_PASSWORD = os.getenv("MEMORY_PASSWORD"),
                NVIM_SOCKET = vim.v.servername,  -- bonus: fix the neovim socket too
            },
        },
    },
  },

  -- these are just suggested keymaps; customize as desired
  keys = {
    {
      "<C-'>",
      function() require("agentic").add_selection_or_file_to_context() end,
      mode = { "n", "v" },
      desc = "Add file or selection to Agentic to Context"
    },
  },
}
