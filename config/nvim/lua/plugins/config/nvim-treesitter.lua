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
end
