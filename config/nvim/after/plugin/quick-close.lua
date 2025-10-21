vim.api.nvim_create_autocmd("FileType", {
	pattern = { "qf", "help", "checkhealth" },
	callback = function()
		vim.keymap.set("n", "q", "<cmd>bd<cr>", { silent = true, buffer = true })
	end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
	callback = function()
		if vim.bo.readonly or vim.bo.buftype == "terminal" then
			vim.keymap.set("n", "q", "<cmd>bd<cr>", { silent = true, buffer = true })
		end
	end,
})
