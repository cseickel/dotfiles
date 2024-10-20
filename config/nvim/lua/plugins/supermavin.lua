return {
	"supermaven-inc/supermaven-nvim",
	config = function()
		require("supermaven-nvim").setup({
			keymaps = {
				accept_suggestion = "<C-j>",
				clear_suggestion = "<C-k>",
				accept_word = "<C-l>",

			},
		})
	end,
}
