      local config = {
        filesystem = {
          window = {
            position = "left",
          },
        }
      }
require("neo-tree").setup({
  close_floats_on_escape_key = false,
  filesystem = {
    window = {
      mappings = {
        ["q"] = "close_window",
      },
    },
  }
})

