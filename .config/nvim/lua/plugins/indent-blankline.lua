return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	opts = function()
		return {
			indent = { char = "▏" },
			scope = {
				enabled = false,
				-- char = "▍",
				char = "▏",
				highlight = { "LineNr" },
				show_start = false,
				show_end = false,
			},
		}
	end,
}
