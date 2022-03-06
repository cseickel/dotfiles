local Job = require("plenary.job")

Job:new({
  command = "find",
  args = {"/", "-iname", "e"},
  maximum_results = 10,
  on_start = function ()
    print("start")
  end,
  on_stdout = function(_, data, _)
    print(data)
  end,
  on_stderr = function(_, data, _)
    print(data)
  end,
  on_exit = function(_, code, _)
    print("exit", code)
  end,
}):start()

require("neo-tree").setup({
  filesystem = {
    filtered_items = {
      dotfiles = true,
      gitignored = true,
      exclude_by_name = {
        ".DS_Store",
        "thumbs.db",
        "node_modules"
      },
      show_hidden = { -- just alter their display instead of completely removing them from the tree
        dotfiles = true,
        gitignored = true,
        excluded = false
      }
    }
  }
})


require("neo-tree").setup({
  filesystem = {
    filtered_items = {
      dotfiles = "hidden", -- or "marked"
      gitignored = "marked", -- or "marked"
      exclude_by_name = {
        [".DS_Store"] = "never show",
        ["thumbs.db"] = "never show",
        ["node_modules"] = "marked"
      },
    }
  }
})
