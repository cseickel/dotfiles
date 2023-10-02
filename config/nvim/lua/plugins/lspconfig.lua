return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "jose-elias-alvarez/nvim-lsp-ts-utils",
    "nvimtools/none-ls.nvim",
    --'jayp0521/mason-null-ls.nvim',
    "nvim-lua/plenary.nvim",
    "b0o/schemastore.nvim",
    "folke/neodev.nvim",
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      -- A list of servers to automatically install if they're not already installed. Example: { "rust_analyzer@nightly", "sumneko_lua" }
      -- This setting has no relation with the `automatic_installation` setting.
      ensure_installed = {
        "bashls",
        "dockerls",
        "gopls",
        "graphql",
        "html",
        "pylsp",
        "jsonls",
        "marksman",
        "pyright",
        "sqlls",
        "lua_ls",
        "tailwindcss",
        "terraformls",
        "tsserver",
        "vimls",
        "yamlls",
      },

      -- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed.
      -- This setting has no relation with the `ensure_installed` setting.
      -- Can either be:
      --   - false: Servers are not automatically installed.
      --   - true: All servers set up via lspconfig are automatically installed.
      --   - { exclude: string[] }: All servers set up via lspconfig, except the ones provided in the list, are automatically installed.
      --       Example: automatic_installation = { exclude = { "rust_analyzer", "solargraph" } }
      automatic_installation = true,
    })
    require("neodev").setup({})

    vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
    vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
    vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
    vim.fn.sign_define("DiagnosticSignHint", { text = " ", texthl = "DiagnosticSignHint" })

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
      -- Use a sharp border with `FloatBorder` highlights
      border = "single",
    })
    vim.diagnostic.config({
      update_in_insert = false,
    })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.resolveSupport = {
      properties = {
        "documentation",
        "detail",
        "additionalTextEdits",
      },
    }

    -- for nvim-ufo
    vim.wo.foldlevel = 99 -- feel free to decrease the value
    vim.wo.foldenable = true
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    }

    local cspell_extra_args = function(params)
      local project_root = params.root or vim.fn.system("git rev-parse --show-toplevel") or vim.fn.getcwd()
      return {
        "--config",
        project_root .. "/cspell.json",
      }
    end
    local null_ls = require("null-ls")
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
    null_ls.setup({
      fallback_severity = vim.diagnostic.severity.HINT,
      should_attach = function(bufnr)
        local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
        if ft == "dbui" or ft == "dbout" or ft:match("sql") then
          return false
        end
        return true
      end,
      sources = {
        null_ls.builtins.code_actions.cspell.with({
          extra_args = cspell_extra_args,
        }),
        --null_ls.builtins.code_actions.refactoring,
        null_ls.builtins.diagnostics.cspell.with({
          extra_args = cspell_extra_args,
        }),
        null_ls.builtins.diagnostics.write_good,
        null_ls.builtins.diagnostics.actionlint,
      },
      -- on_attach = function(client, bufnr)
      --   -- Format on save
      --   -- This causes bugs, sometimes I lose data because of this...
      --   if client.supports_method("textDocument/formatting") then
      --     vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      --     vim.api.nvim_create_autocmd("BufWritePre", {
      --       group = augroup,
      --       buffer = bufnr,
      --       callback = function()
      --         local success, msg = pcall(vim.lsp.buf.format, { bufnr = bufnr })
      --         if not success then
      --           vim.notify("Unable to auto format buffer.", vim.log.levels.WARN)
      --         end
      --       end,
      --     })
      --   end
      -- end,
    })
    --require("mason-null-ls").setup({
    --  automatic_installation = true,
    --})

    local lspconfig = require("lspconfig")
    local navic = require("nvim-navic")

    lspconfig.jsonls.setup({
      settings = {
        json = {
          schemas = require("schemastore").json.schemas(),
        },
      },
    })

    -- make sure to only run this once!
    --local tsserver_on_attach = function(client, bufnr)
    --  -- disable tsserver formatting if you plan on formatting via null-ls
    --  client.server_capabilities.document_formatting = false
    --  client.server_capabilities.document_range_formatting = false

    --  local ts_utils = require("nvim-lsp-ts-utils")

    --  -- defaults
    --  ts_utils.setup({
    --    enable_import_on_completion = true,
    --    -- eslint
    --    eslint_enable_code_actions = true,
    --    eslint_enable_disable_comments = true,
    --    eslint_bin = "eslint_d",
    --    eslint_enable_diagnostics = false,
    --    eslint_opts = {},

    --    -- formatting
    --    enable_formatting = true,
    --    formatter = "prettier",
    --    formatter_opts = {},

    --    -- update imports on file move
    --    update_imports_on_move = true,
    --    require_confirmation_on_move = false,
    --    watch_dir = nil,

    --    -- filter diagnostics
    --    filter_out_diagnostics_by_severity = {},
    --    filter_out_diagnostics_by_code = {},
    --  })

    --  -- required to fix code action ranges and filter diagnostics
    --  ts_utils.setup_client(client)

    --  -- no default maps, so you may want to define some here
    --  local opts = { silent = true }
    --  vim.api.nvim_buf_set_keymap(bufnr, "n", ",go", ":TSLspOrganize<CR>", opts)
    --  vim.api.nvim_buf_set_keymap(bufnr, "n", ",gR", ":TSLspRenameFile<CR>", opts)
    --  vim.api.nvim_buf_set_keymap(bufnr, "n", ",gi", ":TSLspImportAll<CR>", opts)

    --  navic.attach(client, bufnr)
    --end

    --lspconfig.setup ({
    --  capabilities = capabilities,
    --})

    --lspconfig.tsserver.setup({
    --  capabilities = capabilities,
    --  on_attach = tsserver_on_attach,
    --})

    -- cspell: disable
    local other_servers_with_doc_symbols = {
      --"omnisharp",
      "gopls",
      --"graphql",
      "yamlls",
      "html",
      "pylsp",
      "terraformls",
      "vimls",
      "bashls",
      --"angularls"
    }
    -- cspell: enable
    for _, server in ipairs(other_servers_with_doc_symbols) do
      if lspconfig[server] then
        lspconfig[server].setup({
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            navic.attach(client, bufnr)
          end,
        })
      end
    end

    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      on_attach = navic.attach,
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
          },
          diagnostics = {
            globals = {
              "vim",
              "describe",
              "it",
              "before_each",
              "after_each",
              "pending",
            },
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
        },
      },
    })

    vim.cmd([[ do User LspAttachBuffers ]])
  end,
}
