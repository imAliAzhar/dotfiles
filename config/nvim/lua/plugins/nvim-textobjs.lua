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
		config = function()
			require("nvim-treesitter.configs").setup({
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["ac"] = "@comment.outer",
							["ic"] = "@comment.inner",
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["as"] = { query = "@local.scope", query_group = "locals" },
						},
					},
				},
			})
		end,
	},
}
