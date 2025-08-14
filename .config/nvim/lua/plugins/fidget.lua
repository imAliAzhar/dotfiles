return {
	"j-hui/fidget.nvim",
	config = function()
		local fidget = require("fidget")

		fidget.setup({
			notification = {
				override_vim_notify = true,
				configs = {
					default = {
						ttl = 1,
						annote_style = "Question",
						debug_annote = "DEBUG",
						debug_style = "Comment",
						error_annote = "ERROR",
						error_style = "ErrorMsg",
						group_style = "Title",
						icon = "",
						icon_style = "Special",
						info_annote = "INFO",
						info_style = "Question",
						name = "",
						warn_annote = "WARN",
						warn_style = "WarningMsg",
						window = {
							normal_hl = "MsgArea",
						},
					},
				},
			},
			logger = {
				level = vim.log.levels.DEBUG,
			},
			progress = {
				display = {
					done_ttl = 1,
				},
			},
		})

		vim.keymap.set({ "n", "v" }, "<Leader>nc", fidget.notification.clear, { desc = "Clear current notification" })
		vim.keymap.set(
			{ "n", "v" },
			"<Leader>nh",
			fidget.notification.show_history,
			{ desc = "Show notification history" }
		)
	end,
}
