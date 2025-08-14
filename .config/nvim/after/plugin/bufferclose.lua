local function close_buffer(force)
	local buf = vim.api.nvim_get_current_buf() -- Get the current buffer
	pcall(function()
		vim.api.nvim_buf_delete(buf, { force = force or false })
	end)
end

vim.api.nvim_create_user_command("Bd", function()
	local bufname = vim.api.nvim_buf_get_name(0) -- Get the current buffer name
	if bufname ~= "" then
		_G.last_closed_file = bufname -- Save the buffer name in a global variable
	end

	if vim.bo.modified then
		local choice = vim.fn.confirm("Buffer has unsaved changes. Close anyway?", "&Yes\n&No", 2)
		if choice == 1 then
			close_buffer(true)
		end
	else
		close_buffer(false)
	end
end, { nargs = 0 })

-- Command to open the last closed file
vim.keymap.set("n", "<Leader>T", function()
	if _G.last_closed_file then
		vim.cmd("edit " .. _G.last_closed_file) -- Open the last closed file
	else
		print("No recently closed file found!")
	end
end, { desc = "Open last closed buffer" })
