function SwitchToLastBuffer()
	-- Get the current alternate buffer from the '#' register
	local alternate_buf = vim.fn.bufnr("#")
	local current_buf = vim.api.nvim_get_current_buf()

	-- Check if the alternate buffer is valid
	if vim.api.nvim_buf_is_valid(alternate_buf) and vim.api.nvim_buf_get_option(alternate_buf, "buflisted") then
		-- Switch to the alternate buffer
		vim.api.nvim_set_current_buf(alternate_buf)
		return
	end

	-- If no valid alternate buffer, find another buffer
	local buffers = vim.api.nvim_list_bufs()
	for _, buf in ipairs(buffers) do
		if buf ~= current_buf and vim.api.nvim_buf_get_option(buf, "buflisted") then
			-- Mark this buffer as the new alternate
			vim.fn.setreg("#", buf)
			vim.api.nvim_set_current_buf(buf)
			return
		end
	end
end

vim.keymap.set({ "n", "v" }, "ga", SwitchToLastBuffer, { desc = "Jump to last buffer" })
