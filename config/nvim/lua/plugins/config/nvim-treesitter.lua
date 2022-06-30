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
      --"html",
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
      disable = { "html" },  -- list of language that will be disabled
    },
    indent = {
      enable = true
    }
  }
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
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
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
