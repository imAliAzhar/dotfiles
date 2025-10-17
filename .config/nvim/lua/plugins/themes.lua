return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,

		config = function()
			require("catppuccin").setup({
				no_italic = true,
				transparent_background = true,
				integrations = {
					cmp = true,
					gitsigns = true,
					treesitter = true,
					which_key = true,
				},
			})
		end,
	},
	{
		-- dir = "~/Projects/rose-pine-nvim",
		"rose-pine/neovim",
		name = "rose-pine",
		opts = {
			styles = {
				italic = false,
				transparency = true,
			},
		},
	},
}
