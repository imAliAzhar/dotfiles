return {
	{
		"chrisgrieser/nvim-various-textobjs",
		event = "VeryLazy",
		opts = {
			keymaps = {
				useDefaults = false,
			},
		},
		config = function(_, opts)
			local vto = require("various-textobjs")
			vto.setup(opts)

			local map = vim.keymap.set

			map({ "o", "x" }, "iq", function()
				vto.anyQuote("inner")
			end)
			map({ "o", "x" }, "aq", function()
				vto.anyQuote("outer")
			end)
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = "VeryLazy",
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
				},
			})

			local ts_select = require("nvim-treesitter-textobjects.select")
			local map = vim.keymap.set

			map({ "o", "x" }, "af", function()
				ts_select.select_textobject("@function.outer", "textobjects")
			end)
			map({ "o", "x" }, "if", function()
				ts_select.select_textobject("@function.inner", "textobjects")
			end)
			map({ "o", "x" }, "ac", function()
				ts_select.select_textobject("@comment.outer", "textobjects")
			end)
			map({ "o", "x" }, "ic", function()
				ts_select.select_textobject("@comment.inner", "textobjects")
			end)
			map({ "o", "x" }, "as", function()
				ts_select.select_textobject("@local.scope", "locals")
			end)
		end,
	},
}
