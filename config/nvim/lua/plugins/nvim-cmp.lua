return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-nvim-lua",
		"hrsh7th/cmp-path",
		--'hrsh7th/cmp-calc',
		--"hrsh7th/vim-vsnip",
		--"hrsh7th/vim-vsnip-integ",
		--'rafamadriz/friendly-snippets',
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-nvim-lsp-document-symbol",
		"hrsh7th/cmp-nvim-lsp-signature-help",
		--"petertriho/cmp-git",
		"rcarriga/cmp-dap",
		"onsails/lspkind-nvim",
		"David-Kunz/cmp-npm",
		-- {
		--   "zbirenbaum/copilot-cmp",
		--   dependencies = {
		--     "zbirenbaum/copilot.lua",
		--   },
		-- }
    --"MattiasMTS/cmp-dbee",
	},
	config = function()
		-- require("copilot").setup({
		--   suggestion = { enabled = false },
		--   panel = { enabled = false },
		-- })
		-- require("copilot_cmp").setup()

		require("cmp-npm").setup()

		require("lspkind").init({
			mode = "symbol_text",
			preset = "default",
			symbol_map = {
				Copilot = "",
				Text = "",
				Method = "",
				Function = "",
				Constructor = "",
				Variable = "",
				Class = "",
				Interface = "",
				Module = "",
				Property = "",
				Unit = "",
				Value = "",
				Enum = "了",
				Keyword = "",
				Snippet = "﬌",
				Color = "",
				File = "",
				Folder = "",
				EnumMember = "",
				Constant = "",
				Struct = "",
				Operator = "",
			},
		})

		local cmp = require("cmp")
		cmp.setup({
			enabled = function()
				return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt" or require("cmp_dap").is_dap_buffer()
			end,
			formatting = {
				format = function(entry, vim_item)
					-- fancy icons and a name of kind
					vim_item.kind = require("lspkind").presets.default[vim_item.kind] -- .. " " .. vim_item.kind
					if entry.source.name == "copilot" then
						vim_item.kind = ""
					end
					-- set a name for each source
					vim_item.menu = ({
						copilot = "[Copilot]",
						buffer = "[Buffer]",
						nvim_lsp = "[LSP]",
						vsnip = "[VSnip]",
						nvim_lua = "[Lua]",
						cmp_tabnine = "[TabNine]",
						look = "[Look]",
						path = "[Path]",
						spell = "[Spell]",
						calc = "[Calc]",
						emoji = "[Emoji]",
						npm = "[npm]",
						dap = "[DAP]",
					})[entry.source.name]
					return vim_item
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.close(),
				["<Tab>"] = cmp.mapping.confirm({ select = true }),
			}),
			--snippet = {
			--	expand = function(args)
			--		vim.fn["vsnip#anonymous"](args.body)
			--	end,
			--},
			sources = {
				--{ name = "copilot"},
				--{ name = "nvim_lua" },
				--{ name = "git" },
				{ name = "nvim_lsp", keyword_length = 1 },
				{ name = "dap" },
				{ name = "npm", keyword_length = 3 },
				--{ name = "vsnip", keyword_length = 1 },
				{ name = "path" },
				{ name = "calc" },
				{ name = "buffer", keyword_length = 2 },
				{ name = "nvim_lsp_signature_help" },
			},
			completion = {
				completeopt = "menu,menuone,noinsert,preview",
				--keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(-\w*\)*\)]],
				--keyword_length = 1,
			},
			preselect = cmp.PreselectMode.None,
		})

		--cmp.setup.cmdline("/", {
		--    mapping = cmp.mapping.preset.cmdline(),
		--    sources = {
		--        { name = "buffer" },
		--    },
		--})

		--cmp.setup.cmdline(":", {
		--    mapping = cmp.mapping.preset.cmdline(),
		--    sources = cmp.config.sources({
		--        { name = "path" },
		--    }, {
		--        { name = "cmdline" },
		--    }),
		--})
		--

		--local format = require("cmp_git.format")
		--local sort = require("cmp_git.sort")

		--require("cmp_git").setup({
		--	-- defaults
		--	filetypes = { "gitcommit", "octo" },
		--	remotes = { "upstream", "origin" }, -- in order of most to least prioritized
		--	enableRemoteUrlRewrites = false, -- enable git url rewrites, see https://git-scm.com/docs/git-config#Documentation/git-config.txt-urlltbasegtinsteadOf
		--	github = {
		--		hosts = {}, -- list of private instances of github
		--		issues = {
		--			fields = { "title", "number", "body", "updatedAt", "state" },
		--			filter = "all", -- assigned, created, mentioned, subscribed, all, repos
		--			limit = 100,
		--			state = "all", -- open, closed, all
		--			sort_by = sort.github.issues,
		--			format = format.github.issues,
		--		},
		--		mentions = {
		--			limit = 100,
		--			sort_by = sort.github.mentions,
		--			format = format.github.mentions,
		--		},
		--		pull_requests = {
		--			fields = { "title", "number", "body", "updatedAt", "state" },
		--			limit = 100,
		--			state = "all", -- open, closed, merged, all
		--			sort_by = sort.github.pull_requests,
		--			format = format.github.pull_requests,
		--		},
		--	},
		--	trigger_actions = {
		--		{
		--			debug_name = "github_issues_and_pr",
		--			trigger_character = "#",
		--			action = function(sources, trigger_char, callback, params, git_info)
		--				return sources.github:get_issues_and_prs(callback, git_info, trigger_char)
		--			end,
		--		},
		--		{
		--			debug_name = "github_mentions",
		--			trigger_character = "@",
		--			action = function(sources, trigger_char, callback, params, git_info)
		--				return sources.github:get_mentions(callback, git_info, trigger_char)
		--			end,
		--		},
		--	},
		--})
		vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
	end,
}
