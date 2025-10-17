local function ansi_colorize()
	local buf = vim.api.nvim_get_current_buf()

	local original_number = vim.wo.number
	local original_relativenumber = vim.wo.relativenumber
	local original_statuscolumn = vim.wo.statuscolumn
	local original_signcolumn = vim.wo.signcolumn

	vim.api.nvim_create_autocmd("BufEnter", {
		buffer = buf,
		callback = function()
			vim.wo.number = false
			vim.wo.relativenumber = false
			vim.wo.statuscolumn = ""
			vim.wo.signcolumn = "no"
			vim.opt_local.listchars = { space = " " }
			vim.bo.modifiable = false
		end,
	})

	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = buf,
		callback = function()
			vim.wo.number = original_number
			vim.wo.relativenumber = original_relativenumber
			vim.wo.statuscolumn = original_statuscolumn
			vim.wo.signcolumn = original_signcolumn
		end,
	})

	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	while #lines > 0 and vim.trim(lines[#lines]) == "" do
		lines[#lines] = nil
	end
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

	local chan_id = vim.api.nvim_open_term(buf, {})
	vim.api.nvim_chan_send(chan_id, table.concat(lines, "\r\n"))

	-- Close buffer and switch to previous tmux window
	local function close_and_switch_tmux()
		vim.cmd("bd!")
		vim.fn.system("tmux select-window -l")
	end

	vim.keymap.set("n", "<esc>", close_and_switch_tmux, { silent = true, buffer = buf })
	vim.keymap.set("n", "<leader>w", "<cmd>bd!<cr>", { silent = true, buffer = buf })
end

-- Auto-run ansi_colorize for .ansi files
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	pattern = "*.ansi",
	callback = function()
		ansi_colorize()
	end,
})
