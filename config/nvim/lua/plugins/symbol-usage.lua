return {
	"Wansmer/symbol-usage.nvim",
	event = "BufReadPre", -- need run before LspAttach if you use nvim 0.9. On 0.10 use 'LspAttach'
	config = function()
		require("symbol-usage").setup({
			vt_position = "above",
			text_format = function(symbol)
				local fragments = {}

				if symbol.references then
					local usage = symbol.references <= 1 and "usage" or "usages"
					local num = symbol.references == 0 and "no" or symbol.references
					table.insert(fragments, (" %s %s"):format(num, usage))
				end

				if symbol.definition then
					table.insert(fragments, symbol.definition .. " defs")
				end

				if symbol.implementation then
					table.insert(fragments, symbol.implementation .. " impls")
				end

				return table.concat(fragments, ", ")
			end,
		})
	end,
}
