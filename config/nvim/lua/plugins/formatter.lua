return {
	"mhartington/formatter.nvim",
	config = function()
		-- Utilities for creating configurations
    local ft = require("formatter.filetypes")

		-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
		require("formatter").setup({
			-- Enable or disable logging
			logging = false,
			-- Set the log level
			log_level = vim.log.levels.WARN,
			-- All formatter configurations are opt-in
			filetype = {
				-- Formatter configurations for filetype "lua" go here
				-- and will be executed in order
				cs = { ft.cs.dotnet_format },
				css = { ft.css.prettier },
				go = { ft.go.gofmt },
				graphql = { ft.graphql.prettier },
				html = { ft.html.prettier },
				javascript = { ft.javascript.prettier },
				json = { ft.json.prettier },
				lua = { ft.lua.stylua },
				markdown = { ft.markdown.prettier },
				python = { ft.python.black },
				sh = { ft.sh.shfmt },
				sql = { ft.sql.pgformat },
				typescript = { ft.typescript.prettier },
				typescriptreact = { ft.typescriptreact.prettier },
				yaml = { ft.yaml.prettier },

				-- Use the special "*" filetype for defining formatter configurations on
				-- any filetype
				["*"] = {
					-- "formatter.filetypes.any" defines default configurations for any
					-- filetype
					ft.any.remove_trailing_whitespace,
				},
			},
		})
	end,
}
