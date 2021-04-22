require'nvim-treesitter.configs'.setup {
	ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
	highlight = {
		enable = true,              -- false will disable the whole extension
		disable = { "java", "yaml" },  -- list of language that will be disabled
	},
	indent = {
		enable = true
	}
}
