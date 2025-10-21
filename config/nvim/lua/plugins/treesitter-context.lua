return {
	"nvim-treesitter/nvim-treesitter-context",
	config = function()
		require("treesitter-context").setup({
			enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
			multiwindow = false, -- Enable multiwindow support.
			max_lines = 3, -- How many lines the window should span. Values <= 0 mean no limit.
			min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
			line_numbers = false,
			multiline_threshold = 20, -- Maximum number of lines to show for a single context
			trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
			mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
			-- Separator between context and content. Should be a single character string, like '-'.
			-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
			separator = nil,
			zindex = 20, -- The Z-index of the context window
			on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
		})

		-- vim.cmd.highlight("TreesitterContextSeparator gui=underline guisp=Black")

		-- vim.cmd.highlight("TreesitterContextBottom gui=underline guisp=Red")
		-- vim.cmd.highlight("TreesitterContextLineNumberBottom gui=underline guisp=Red")

		-- vim.api.nvim_set_hl(0, "TreesitterContextBottom", { link = "Normal" })
		-- vim.api.nvim_set_hl(0, "TreesitterContext", { link = "Normal" })
		-- vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { link = "LineNr" })
		-- vim.cmd.highlight("TreesitterContextSeparator gui=underline guisp=Black")
		-- vim.api.nvim_set_hl(0, "TreesitterContext", {
		-- 	bg = "#2a2a2a", -- dark gray background
		-- 	fg = "NONE", -- keep the current foreground
		-- })
		-- vim.api.nvim_set_hl(0, "TreesitterContextBottom", {
		-- 	underline = true,
		-- 	sp = "Red", -- guisp = special color (used for underline/undercurl)
		-- })
		--
		-- vim.api.nvim_set_hl(0, "TreesitterContextLineNumberBottom", {
		-- 	underline = true,
		-- 	sp = "Red",
		-- })
	end,
}
