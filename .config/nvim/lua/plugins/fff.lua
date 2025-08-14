return {
	"dmtrKovalenko/fff.nvim",
	build = "cargo build --release",
	opts = {
		preview = {
			enabled = false,
		},
	},
	keys = {
		{
			"<leader><c-f>", -- try it if you didn't it is a banger keybinding for a picker
			function()
				require("fff").find_files({
					preview = {
						enabled = false,
					},
				})
			end,
			desc = "Toggle FFF",
		},
	},
}
