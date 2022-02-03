local utils = require("neo-tree.utils")

local base = {
  window = {
    mappings = {
      ["/"] = "hi"
    }
  }
}

local over = {
  window = {
    mappings = {
      ["/"] = nil
    }
  }
}
print(vim.inspect(over))


local merged = vim.deepcopy(base, over)

print(vim.inspect(merged))
