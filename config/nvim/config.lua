require'nvim-treesitter.configs'.setup {
	ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
	highlight = {
		enable = true,              -- false will disable the whole extension
		--disable = { "c_sharp" },  -- list of language that will be disabled
	},
	indent = {
		enable = true
	}
}

require("revj").setup{
    brackets = {first = '([{<', last = ')]}>'}, -- brackets to consider surrounding arguments
    new_line_before_last_bracket = true, -- add new line between last argument and last bracket
    enable_default_keymaps = false, -- enables default keymaps without having to set them below
    keymaps = {
        operator = '<Leader>J', -- for operator (+motion)
        line = '<Leader>j', -- for formatting current line
        visual = '<Leader>j', -- for formatting visual selection
    },
}
