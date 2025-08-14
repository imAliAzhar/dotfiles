return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	opts = function()
		return {
			indent = { char = "▏" },
			scope = { char = "▍", highlight = { "IblIndent" } },
		}
	end,
}
