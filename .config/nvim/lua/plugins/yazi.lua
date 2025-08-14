return {
	"mikavilpas/yazi.nvim",
	event = "VeryLazy",

	config = function(_, opts)
		local yazi = require("yazi")
		yazi.setup(opts)

		vim.keymap.set("n", "<leader>e", function()
			yazi.yazi({
				hooks = {
					on_yazi_ready = function(_, _, process_api)
						process_api:emit_to_yazi({ "hidden", "show" })
					end,
				},
			})
		end)
	end,
}
