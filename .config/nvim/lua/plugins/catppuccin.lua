return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,

	config = function()
		local is_light_theme = os.getenv("LIGHT_THEME") == "true"

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

		local colorscheme = is_light_theme and "catppuccin-latte" or "catppuccin-mocha"
		vim.cmd.colorscheme(colorscheme)

		-- https://github.com/neovim/neovim/issues/31675
		vim.hl = vim.highlight

		vim.cmd.highlight("DiagnosticUnderlineError gui=undercurl")
		vim.cmd.highlight("DiagnosticUnderlineWarn gui=undercurl")
		vim.cmd.highlight("DiagnosticUnderlineHint gui=undercurl")
		vim.cmd.highlight("DiagnosticUnderlineInfo gui=undercurl")
		vim.api.nvim_set_hl(0, "@custom.imports", { fg = "#ffffff" })

		local palette_name = is_light_theme and "latte" or "mocha"
		local palette = require("catppuccin.palettes").get_palette(palette_name)

		-- TS/JS color overrides
		vim.api.nvim_set_hl(0, "@custom.imports", { fg = palette.text })
		vim.api.nvim_set_hl(0, "@custom.type", { fg = palette.mauve })
		-- TODO: Clean these up
		-- vim.api.nvim_set_hl(0, "@custom.jsx_subcomponent", { fg = mocha.pink })
		-- vim.api.nvim_set_hl(0, "@custom.jsx_prop", { fg = mocha.yellow })
		-- vim.api.nvim_set_hl(0, "@custom.jsx_component", { fg = mocha.pink })
		vim.api.nvim_set_hl(0, "@keyword.export", { fg = palette.lavendar })
	end,
}
