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
    "yioneko/nvim-vtsls"
	},
	config = function()
		require("mason").setup()
		--require("mason-lspconfig").setup({
		--  -- A list of servers to automatically install if they're not already installed. Example: { "rust_analyzer@nightly", "sumneko_lua" }
		--  -- This setting has no relation with the `automatic_installation` setting.
		--  ensure_installed = {
		--    "bashls",
		--    --"denols",
		--    "dockerls",
		--    "gopls",
		--    "graphql",
		--    "html",
		--    "pylsp",
		--    "jsonls",
		--    "marksman",
		--    "pyright",
		--    "sqlls",
		--    "lua_ls",
		--    "tailwindcss",
		--    --"terraformls",
		--    "vtsls",
		--    "vimls",
		--    "yamlls",
		--  },

		--  -- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed.
		--  -- This setting has no relation with the `ensure_installed` setting.
		--  -- Can either be:
		--  --   - false: Servers are not automatically installed.
		--  --   - true: All servers set up via lspconfig are automatically installed.
		--  --   - { exclude: string[] }: All servers set up via lspconfig, except the ones provided in the list, are automatically installed.
		--  --       Example: automatic_installation = { exclude = { "rust_analyzer", "solargraph" } }
		--  automatic_installation = true,
		--})
		require("neodev").setup({})

		vim.diagnostic.config({
			update_in_insert = false,
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.INFO] = " ",
					[vim.diagnostic.severity.HINT] = " ",
				},
				numhl = {
					[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
					[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
					[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
					[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
				},
			},
		})

		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
			-- Use a sharp border with `FloatBorder` highlights
			winborder = "rounded",
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

		_G.find_cspell = function()
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

		vim.api.nvim_exec(
			[[
      augroup FindCspellConfig
        autocmd!
        autocmd BufEnter * lua find_cspell()
      augroup END
    ]],
			false
		)

		local cspell_config = {
			find_json = function()
				return vim.b.cspell_config_file_path
			end,
			---@param payload AddToJSONSuccess
			on_add_to_json = function(payload)
				-- Includes:
				-- payload.new_word
				-- payload.cspell_config_path
				-- payload.generator_params

				-- For example, you can format the cspell config file after you add a word
				os.execute(string.format(
					-- Sort the words array in the cspell.json file, and output with newlines and indents
					"jq -S '.words |= sort' %s > %s.tmp && mv %s.tmp %s",
					payload.cspell_config_path,
					payload.cspell_config_path,
					payload.cspell_config_path,
					payload.cspell_config_path
				))
			end,
		}

		local null_ls = require("null-ls")
		local cspell = require("cspell")

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

		-- cspell: disable
		local servers_with_doc_symbols = {
			--"omnisharp",
			"gopls",
			--"graphql",
			"yamlls",
			"html",
			"pylsp",
			--"terraformls",
			"vimls",
			"bashls",
			--"vtsls",
			--"angularls",
			--"ts_ls"
		}
		-- cspell: enable
		for _, server in ipairs(servers_with_doc_symbols) do
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

		lspconfig.denols.setup({
			capabilities = capabilities,
			root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
			single_file_support = false,
			init_options = {
				lint = true,
				unstable = true,
				suggest = {
					imports = {
						hosts = {
							["https://deno.land"] = true,
							["https://cdn.nest.land"] = true,
							["https://crux.land"] = true,
						},
					},
				},
			},

			on_attach = navic.attach,
		})

		require("lspconfig.configs").vtsls = require("vtsls").lspconfig

		lspconfig.vtsls.setup({
			capabilities = capabilities,
			on_attach = navic.attach,
			single_file_support = false,
			reuse_client = function()
				return true
			end,
			root_dir = function(filename, bufnr)
				local denoRootDir = lspconfig.util.root_pattern("deno.json", "deno.json")(filename)
				if denoRootDir then
					-- this seems to be a deno project; returning nil so that tsserver does not attach
					return nil
				end

				return lspconfig.util.root_pattern("package.json")(filename)
			end,
			settings = {
				typescript = {
					tsserver = {
						maxTsServerMemory = 8192, -- Increase memory limit (e.g., 8GB)
					},
				},
				vtsls = {
					autoUseWorkspaceTsdk = true,
					experimental = {
						completion = {
							enableServerSideFuzzyMatch = true,
							entriesLimit = 100,
						},
					},
				},
			},
		})

		--vim.cmd([[ do User LspAttachBuffers ]])
	end,
}
