return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "davidmh/cspell.nvim",
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

    _G.find_cspell = function ()
      if vim.bo.buftype ~= "" then
        return
      end
      if vim.b.cspell_config_file_path ~= nil then
        return
      end
      -- use vim.loop to walk up the directory tree until we find a cspell.json file
      local dir = vim.fn.expand("%:p:h")
      -- make sure this is a real directory
      local stat = vim.loop.fs_stat(dir)
      if stat == nil then
        return nil
      end

      while dir ~= nil and dir ~= "" and dir ~= "/" do
        local cspell_json = dir .. "/cspell.json"
        if vim.fn.filereadable(cspell_json) == 1 then
          vim.b.cspell_config_file_path = cspell_json
          return
        end
        dir = vim.fn.fnamemodify(dir, ":h")
      end
      return nil
    end

    vim.api.nvim_exec([[
      augroup FindCspellConfig
        autocmd!
        autocmd BufEnter * lua find_cspell()
      augroup END
    ]], false)

    local cspell_config = {
      find_json = function ()
        return vim.b.cspell_config_file_path
      end,
      ---@param payload AddToJSONSuccess
      on_add_to_json = function(payload)
          -- Includes:
          -- payload.new_word
          -- payload.cspell_config_path
          -- payload.generator_params

          -- For example, you can format the cspell config file after you add a word
          os.execute(
              string.format(
                  -- Sort the words array in the cspell.json file, and output with newlines and indents
                  "jq -S '.words |= sort' %s > %s.tmp && mv %s.tmp %s",
                  payload.cspell_config_path,
                  payload.cspell_config_path,
                  payload.cspell_config_path,
                  payload.cspell_config_path
              )
          )
      end
    }

    local null_ls = require("null-ls")
    local cspell = require('cspell')

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
        cspell.diagnostics.with({ config = cspell_config }),
        cspell.code_actions.with({ config = cspell_config }),
       -- null_ls.builtins.diagnostics.write_good,
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
    local tsserver_on_attach = function(client, bufnr)
      -- disable tsserver formatting if you plan on formatting via null-ls
      -- client.server_capabilities.document_formatting = false
      -- client.server_capabilities.document_range_formatting = false

      -- local ts_utils = require("nvim-lsp-ts-utils")

      -- -- defaults
      -- ts_utils.setup({
      --   enable_import_on_completion = true,
      --   -- eslint
      --   eslint_enable_code_actions = true,
      --   eslint_enable_disable_comments = true,
      --   eslint_bin = "eslint_d",
      --   eslint_enable_diagnostics = false,
      --   eslint_opts = {},

      --   -- formatting
      --   enable_formatting = true,
      --   formatter = "prettier",
      --   formatter_opts = {},

      --   -- update imports on file move
      --   update_imports_on_move = true,
      --   require_confirmation_on_move = false,
      --   watch_dir = nil,

      --   -- filter diagnostics
      --   filter_out_diagnostics_by_severity = {},
      --   filter_out_diagnostics_by_code = {},
      -- })

      -- -- required to fix code action ranges and filter diagnostics
      -- ts_utils.setup_client(client)

      -- -- no default maps, so you may want to define some here
      -- local opts = { silent = true }
      -- vim.api.nvim_buf_set_keymap(bufnr, "n", ",go", ":TSLspOrganize<CR>", opts)
      -- vim.api.nvim_buf_set_keymap(bufnr, "n", ",gR", ":TSLspRenameFile<CR>", opts)
      -- vim.api.nvim_buf_set_keymap(bufnr, "n", ",gi", ":TSLspImportAll<CR>", opts)

      navic.attach(client, bufnr)
    end

    lspconfig.tsserver.setup({
      capabilities = capabilities,
      on_attach = tsserver_on_attach,
    })

    -- cspell: disable
    local other_servers_with_doc_symbols = {
      --"omnisharp",
      "gopls",
      --"graphql",
      "yamlls",
      "html",
      "pylsp",
      --"terraformls",
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
