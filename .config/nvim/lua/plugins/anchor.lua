return {
	{
		dir = "~/Projects/anchor.nvim",
		config = function()
			require("anchor").setup(_, {
				-- keymaps = {
				-- activate = "<tab>",
				-- hide = "q",
				-- focus_next = "j",
				-- focus_previous = "k",
				-- confirm = "<esc>",
				-- },
			})
		end,
	},
}
