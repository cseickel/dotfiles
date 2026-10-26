local function project (key, path, name)
  return {
    key = key,
    desc = name or path,
    action = function()
      vim.fn.chdir(path)
      vim.cmd("Neotree current")
    end
  }
end

return {
  "folke/snacks.nvim",
  lazy = false,
  opts = {
    gh = {
      -- your gh configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    picker = {
      enabled = true,
      ui_select = true,
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
    dashboard = {
      enabled = true,
      sections = {
        -- fixed list: one key per project
        project("d", "~/sql", "DB"),
        project("c", "~/claude-instructions", "claude-instructions"),
        project("r", "~/claude-instructions/rva-3", "rva-3"),
        project("f", "~/claude-instructions/fdw-sync", "fdw-sync"),
        project("n", "~/notes", "notes"),
        -- automatic list: git roots of recently opened files, numbered keys
        { section = "projects", title = "Recent projects", padding = 1 },
      },
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
