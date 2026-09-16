local function is_parser_installed(lang)
    local installed = require("nvim-treesitter").get_installed()
    return vim.tbl_contains(installed, lang)
end

local function is_parser_available(lang)
    local available = require("nvim-treesitter").get_available()
    return vim.tbl_contains(available, lang)
end

local function start_treesitter(buf, lang)
    if not vim.treesitter.language.add(lang) then
        vim.notify(
            "Cannot load treesitter parser for language " .. lang,
            vim.log.levels.WARN
        )
        return
    end
    vim.treesitter.start(buf)
    vim.bo[buf].syntax = "ON"
    if vim.treesitter.query.get(lang, "indents") then
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
end

local autocmd_created = false
local function add_autocmd()
  if autocmd_created then
    return
  end
  vim.api.nvim_create_autocmd("FileType", {
      callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match)
          if not lang then
              return
          end
          local buf = ev.buf
          if is_parser_installed(lang) then
              start_treesitter(buf, lang)
          elseif is_parser_available(lang) then
              require("nvim-treesitter").install({ lang }):await(function()
                  start_treesitter(buf, lang)
              end)
          end
      end,
  })
  autocmd_created = true
end

local hamsta = {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    add_autocmd()
  end
}

local romus = {
  "romus204/tree-sitter-manager.nvim",
  dependencies = {}, -- tree-sitter CLI must be installed system-wide
  config = function()
    require("tree-sitter-manager").setup({
      -- Default Options
      ensure_installed = {
        "bash",
        "c",
        "css",
        "dockerfile",
        "go",
        "graphql",
        "hcl",
        "lua",
        "javascript",
        "json",
        "json5",
        "html",
        "markdown",
        "markdown_inline",
        "java",
        "typescript",
        "python",
        "query",
        "r",
        "regex",
        "scss",
        "sql",
        "vim",
        "yaml"
      }, -- list of parsers to install at the start of a neovim session
      -- border = nil, -- border style for the window (e.g. "rounded", "single"), if nil, use the default border style defined by 'vim.o.winborder'. See :h 'winborder' for more info.
      auto_install = true, -- if enabled, install missing parsers when editing a new file
      -- highlight = true, -- treesitter highlighting is enabled by default
      -- languages = {}, -- override or add new parser sources
      -- parser_dir = vim.fn.stdpath("data") .. "/site/parser",
      -- query_dir = vim.fn.stdpath("data") .. "/site/queries",
      languages = {
        d2 = {
          install_info = {
            url = "https://github.com/ravsii/tree-sitter-d2/",
            use_repo_queries = true, -- copy queries/ from the cloned repo
          },
        },
      },
    })
  end
}

return hamsta
