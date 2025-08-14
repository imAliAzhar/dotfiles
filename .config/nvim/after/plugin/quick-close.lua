vim.api.nvim_create_autocmd("FileType", {
	pattern = { "qf", "help", "checkhealth" },
	callback = function()
		vim.keymap.set("n", "q", "<cmd>bd<cr>", { silent = true, buffer = true })
	end,
})
