return function()
  require'nvim-treesitter.configs'.setup {
    ensure_installed = {
      "bash",
      "c",
      "c_sharp",
      "css",
      "dockerfile",
      "go",
      "graphql",
      "lua",
      "javascript",
      "json",
      "json5",
      "jsonc",
      "html",
      "markdown",
      "java",
      "typescript",
      "python",
      "r",
      "regex",
      "scss",
      "vim",
      "yaml"
    }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    highlight = {
      enable = true,              -- false will disable the whole extension
      --disable = { "html" },  -- list of language that will be disabled
    },
    indent = {
      enable = true
    }
  }

  local ts_parsers = require("nvim-treesitter.parsers")
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("treesitter", {clear = true}),
    pattern = { "*" },
    callback = function()
      local ft = vim.bo.filetype
      if not ft then
        return
      end
      local parser = ts_parsers.filetype_to_parsername[ft]
      if not parser then
        return
      end
      local is_installed = ts_parsers.has_parser(ts_parsers.ft_to_lang(ft))
      if not is_installed then
        vim.cmd("TSInstall " .. parser)
      end
    end,
  })

  require('nvim-treesitter.configs').setup {
    textobjects = {
      select = {
        enable = true,

        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,

        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ab"] = "@block.outer",
          ["ib"] = "@block.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@block.outer",
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@block.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@block.outer",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@block.outer",
        },
      },
    },
  }
end
