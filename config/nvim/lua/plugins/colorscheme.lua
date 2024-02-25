-- cSpell: disable
local monokai = {
	"loctvl842/monokai-pro.nvim",
	config = function()
		require("monokai-pro").setup({
			filter = "spectrum",
		})
		vim.cmd([[colorscheme monokai-pro]])
	end,
}

local vscode = {
	"Mofiqul/vscode.nvim",
	priority = 1000,
	config = function()
		local c = require("vscode.colors").get_colors()
		require("vscode").setup({
			group_overrides = {
				-- this supports the same val table as vim.api.nvim_set_hl
				-- use colors from this colorscheme by requiring vscode.colors!
				["@comment"] = { fg = "#505050", bg = "NONE", italic = true },
				Comment = { fg = "#505050", bg = "NONE", italic = true },
				Directory = { fg = c.vscBlue, bg = "NONE" },
				["@punctuation.bracket"] = { fg = c.vscFront, bg = "None" },
			},
		})
		require("vscode").load()
		vim.cmd([[source ~/.config/nvim/theme.vim]])
	end,
}

local tundra = {
	"sam4llis/nvim-tundra",
  priority = 1000,
	config = function()
    require("nvim-tundra").setup({
      theme = "dark", -- or "light"
      styles = {
        comments = "italic",
        keywords = "bold",
        functions = "italic,bold",
      },
      plugins = {
        lsp = true,
        semantic_tokens = true,
        treesitter = true,
        telescope = true,
        cmp = true,
        context = true,
        dbui = true,
        gitsigns = true,
      },
    })
    vim.g.tundra_biome = 'jungle' -- 'arctic' or 'jungle'
    vim.opt.background = 'dark'
    vim.cmd('colorscheme tundra')
  end,
}

return vscode
