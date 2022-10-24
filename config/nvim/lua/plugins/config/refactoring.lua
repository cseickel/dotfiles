return function(use)
  use {
    "ThePrimeagen/refactoring.nvim",
    requires = {
      {"nvim-lua/plenary.nvim"},
      {"nvim-treesitter/nvim-treesitter"}
    },
    config = function ()
      require('refactoring').setup({
        --prompt_func_return_type = {
        --    go = false,
        --    java = false,

        --    cpp = false,
        --    c = false,
        --    h = false,
        --    hpp = false,
        --    cxx = false,
        --},
        --prompt_func_param_type = {
        --    go = false,
        --    java = false,

        --    cpp = false,
        --    c = false,
        --    h = false,
        --    hpp = false,
        --    cxx = false,
        --},
        --printf_statements = {},
        --print_var_statements = {},
      })
      -- prompt for a refactor to apply when the remap is triggered
      vim.api.nvim_set_keymap(
        "v",
        "<leader>rr",
        ":lua require('refactoring').select_refactor()<CR>",
        { noremap = true, silent = true, expr = false }
      )

      -- You can also use below = true here to to change the position of the printf
      -- statement (or set two remaps for either one). This remap must be made in normal mode.
      vim.api.nvim_set_keymap(
        "n",
        "<leader>rp",
        ":lua require('refactoring').debug.printf({below = false})<CR>",
        { noremap = true }
      )

      -- Print var

      -- Remap in normal mode and passing { normal = true } will automatically find the variable under the cursor and print it
      vim.api.nvim_set_keymap("n", "<leader>rv", ":lua require('refactoring').debug.print_var({ normal = true })<CR>", { noremap = true })
      -- Remap in visual mode will print whatever is in the visual selection
      vim.api.nvim_set_keymap("v", "<leader>rv", ":lua require('refactoring').debug.print_var({})<CR>", { noremap = true })

      -- Cleanup function: this remap should be made in normal mode
      vim.api.nvim_set_keymap("n", "<leader>rc", ":lua require('refactoring').debug.cleanup({})<CR>", { noremap = true })
    end
  }
end
