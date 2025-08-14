function ColorScheme(color)
	color = color or "catppuccin"
	vim.cmd.colorscheme(color)

	-- https://github.com/neovim/neovim/issues/31675
	vim.hl = vim.highlight

	-- vim.cmd.highlight("Normal guibg=none")

	vim.cmd.highlight("DiagnosticUnderlineError gui=undercurl")
	vim.cmd.highlight("DiagnosticUnderlineWarn gui=undercurl")
	vim.cmd.highlight("DiagnosticUnderlineHint gui=undercurl")
	vim.cmd.highlight("DiagnosticUnderlineInfo gui=undercurl")
	vim.api.nvim_set_hl(0, "@custom.imports", { fg = "#ffffff" })

	local mocha = require("catppuccin.palettes").get_palette("mocha")

	-- TS/JS color overrides
	vim.api.nvim_set_hl(0, "@custom.imports", { fg = mocha.text })
	vim.api.nvim_set_hl(0, "@custom.type", { fg = mocha.mauve })
	-- TODO: Clean these up
	-- vim.api.nvim_set_hl(0, "@custom.jsx_subcomponent", { fg = mocha.pink })
	-- vim.api.nvim_set_hl(0, "@custom.jsx_prop", { fg = mocha.yellow })
	-- vim.api.nvim_set_hl(0, "@custom.jsx_component", { fg = mocha.pink })
	vim.api.nvim_set_hl(0, "@keyword.export", { fg = mocha.lavendar })
end

ColorScheme()
