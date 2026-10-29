return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-nvim-lua",
		"hrsh7th/cmp-path",
		--'hrsh7th/cmp-calc',
		"hrsh7th/vim-vsnip",
		"hrsh7th/vim-vsnip-integ",
		--'rafamadriz/friendly-snippets',
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-nvim-lsp-document-symbol",
		"hrsh7th/cmp-nvim-lsp-signature-help",
		--"petertriho/cmp-git",
		"rcarriga/cmp-dap",
		"onsails/lspkind-nvim",
		"David-Kunz/cmp-npm",
		{
		  "zbirenbaum/copilot-cmp",
		  dependencies = {
		    "zbirenbaum/copilot.lua",
		  },
		}
    --"MattiasMTS/cmp-dbee",
	},
	config = function()
		require("copilot").setup({
		  suggestion = { enabled = false },
		  panel = { enabled = false },
		})
		require("copilot_cmp").setup()

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
    local base_format = function(entry, vim_item)
      -- nvim-cmp draws the kind's icon in its own icon column
      vim_item.kind = ""
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
    end

		local cmp = require("cmp")

    local function snippetJumpable(direction)
      return vim.fn["vsnip#jumpable"](direction) == 1
    end

    local function snippetJump(direction)
      local key = direction > 0 and "<Plug>(vsnip-jump-next)" or "<Plug>(vsnip-jump-prev)"
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), "", false)
    end

		cmp.setup({
			enabled = function()
				return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt" or require("cmp_dap").is_dap_buffer()
			end,
			formatting = {
        format = base_format
			},
			mapping = cmp.mapping.preset.insert({
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.close(),
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.confirm({ select = true })
					elseif snippetJumpable(1) then
						snippetJump(1)
					else
						fallback()
					end
				end, { "i", "s" }),
				["<S-Tab>"] = cmp.mapping(function(fallback)
					if snippetJumpable(-1) then
						snippetJump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),
			}),
			snippet = {
				expand = function(args)
					vim.fn["vsnip#anonymous"](args.body)
				end,
			},
			sources = {
				{ name = "copilot"},
				--{ name = "nvim_lua" },
				--{ name = "git" },
        --{ name = "supermaven" },
				{ name = "nvim_lsp", keyword_length = 1 },
				{ name = "dap" },
				{ name = "npm", keyword_length = 3 },
				{ name = "vsnip", keyword_length = 1 },
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

    local SQL_TYPE_ICONS = {
      { "%[%]$", "󰅪" },
      { "^timestamp", "󰃰" },
      { "^date", "󰃭" },
      { "^time", "󰥔" },
      { "^interval", "󱫡" },
      { "^bool", "󰨙" },
      { "int", "󰎠" },
      { "^numeric", "󰎠" },
      { "^decimal", "󰎠" },
      { "^double", "󰎠" },
      { "^real", "󰎠" },
      { "^float", "󰎠" },
      { "^uuid", "󰻾" },
      { "^json", "󰘦" },
      { "char", "󰉿" },
      { "^text", "󰉿" },
    }

    local function sqlTypeIcon(type)
      local lower = type:lower()
      for _, rule in ipairs(SQL_TYPE_ICONS) do
        if lower:find(rule[1]) then
          return rule[2]
        end
      end
      return nil
    end

    local compare = cmp.config.compare
    cmp.setup.filetype({ "sql", "mysql", "plsql" }, {
      sources = {
        { name = "nvim_lsp" },
        { name = "nvim_lsp_signature_help" },
      },
      sorting = {
        comparators = {
          compare.offset,
          compare.exact,
          compare.score,
          compare.sort_text,
          compare.kind,
        },
      },
      formatting = {
        format = function(entry, item)
          item = base_format(entry, item)
          local details = entry.completion_item.labelDetails
          if details and details.description then
            item.icon = sqlTypeIcon(details.description) or item.icon
            item.menu = details.description
          end
          return item
        end,
      },
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
    vim.keymap.set("n", "<Tab>", function()
      return snippetJumpable(1) and "i<Plug>(vsnip-jump-next)" or "<Tab>"
    end, { expr = true, remap = true, desc = "next snippet field" })
    vim.keymap.set("n", "<S-Tab>", function()
      return snippetJumpable(-1) and "i<Plug>(vsnip-jump-prev)" or ""
    end, { expr = true, remap = true, desc = "previous snippet field" })

    -- Shows the jump keys at the end of the cursor line while a snippet has a
    -- field to jump to.
    local snippetHint = vim.api.nvim_create_namespace("snippet-jump-hint")
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "ModeChanged" }, {
      callback = function(event)
        vim.api.nvim_buf_clear_namespace(event.buf, snippetHint, 0, -1)
        if not vim.api.nvim_get_mode().mode:match("^[insS]") then
          return
        end
        local keys = {}
        if snippetJumpable(-1) then
          table.insert(keys, "<S-Tab> (back)")
        end
        if snippetJumpable(1) then
          table.insert(keys, "(next) <Tab>")
        end
        if #keys == 0 then
          return
        end
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1
        vim.api.nvim_buf_set_extmark(event.buf, snippetHint, row, 0, {
          virt_text = { { table.concat(keys, " <-|-> "), "Comment" } },
          virt_text_pos = "eol",
        })
      end,
    })

		vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
	end,
}
