return {
	"gbprod/substitute.nvim",

	config = function()
		local substitute = require("substitute")

		substitute.setup({
			yank_substituted_text = true,
			highlight_substituted_text = {
				enabled = true,
				timer = 100,
			},
			preserve_cursor_position = true,
			range = {
				complete_word = false,
				group_substituted_text = true,
			},
		})

		vim.keymap.set("n", "x", require("substitute").operator, {
			noremap = true,
			desc = "Substitute with motion",
		})
		vim.keymap.set("n", "xx", require("substitute").line, {
			noremap = true,
			desc = "Substitute current line",
		})
		vim.keymap.set("n", "X", require("substitute").eol, {
			noremap = true,
			desc = "Substitute to end of line",
		})
		vim.keymap.set("x", "x", require("substitute").visual, {
			noremap = true,
			desc = "Substitute visual selection",
		})

		vim.keymap.set("x", "<leader>x", require("substitute.range").visual, {
			noremap = true,
			desc = "Substitute visual + motion",
		})

		-- Replace word under cursor in all file
		vim.keymap.set("n", "<leader><leader>X", function()
			require("substitute.range").word({ range = "%" })
		end, {
			noremap = true,
			desc = "Replace word under cursor (entire file)",
		})

		-- Replace word under cursor in selected range
		vim.keymap.set("n", "<leader>X", require("substitute.range").word, {
			noremap = true,
			desc = "Replace word under cursor (range motion)",
		})

		-- Replace with motions in entire file
		vim.keymap.set("n", "<leader><leader>x", function()
			require("substitute.range").operator({ range = "%" })
		end, {
			noremap = true,
			desc = "Substitute motion (entire file)",
		})

		-- Replace with motions in motion-defined range
		vim.keymap.set("n", "<leader>x", require("substitute.range").operator, {
			noremap = true,
			desc = "Substitute motion (range motion)",
		})

		-- Exchange (swap) motions
		vim.keymap.set("n", "xs", require("substitute.exchange").operator, {
			noremap = true,
			desc = "Exchange with motion",
		})
		vim.keymap.set("n", "xss", require("substitute.exchange").line, {
			noremap = true,
			desc = "Exchange current line",
		})
		vim.keymap.set("x", "X", require("substitute.exchange").visual, {
			noremap = true,
			desc = "Exchange visual selection",
		})
	end,
}
