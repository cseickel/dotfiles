return {
  "folke/snacks.nvim",
  opts = {
    gh = {
      -- your gh configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    picker = {
      sources = {
        gh_issue = {
          -- your gh_issue picker configuration comes here
          -- or leave it empty to use the default settings
        },
        gh_pr = {
          -- your gh_pr picker configuration comes here
          -- or leave it empty to use the default settings
        }
      }
    },
  },
  keys = {
    { "<leader>gh", desc = "GitHub" },
    {
      "<leader>ghi",
      desc = "GitHub Issues",
      function()
        Snacks.picker.gh_issue()
      end
    },
    -- {
    --   "<leader>ghI",
    --   desc = "GitHub: Open Issue",
    --   function()
    --     -- issue number is the first number in the branch name
    --     local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]
    --     local number = string.match(branch, "(%d+)")
    --     Snacks.picker.gh_issue({ number = number })
    --   end
    -- },
    {
      "<leader>ghp",
      desc = "Githib Pull Requests",
      function()
        Snacks.picker.gh_pr()
      end
    },
  },
}
