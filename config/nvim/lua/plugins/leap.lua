return {
	"https://codeberg.org/andyg/leap.nvim",
	config = function()
		vim.keymap.set("n", "s", "<Plug>(leap)")
		vim.keymap.set("n", "S", "<Plug>(leap-from-window)")
		vim.keymap.set({ "x", "o" }, "s", "<Plug>(leap-forward)")
		vim.keymap.set({ "x", "o" }, "S", "<Plug>(leap-backward)")

		vim.keymap.set({ "n", "o" }, "gs", function()
			require("leap.remote").action()
		end)

		require("leap").opts.safe_labels = {}
	end,
}
