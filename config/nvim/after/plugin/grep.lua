local function grep_selection_single_line()
	local get_selection = function()
		return vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { mode = vim.fn.mode() })
	end

	local function trim(s)
		return s:match("^%s*(.-)%s*$")
	end

	local lines = get_selection()
	if not lines or #lines == 0 then
		vim.notify("No selection.", vim.log.levels.WARN)
		return
	end

	local selection = trim(lines[1])
	if selection == "" then
		vim.notify("Selection is empty.", vim.log.levels.WARN)
		return
	end

	local escaped = vim.fn.shellescape(selection)

	vim.cmd("silent grep " .. escaped)

	vim.fn.setqflist({}, "a", { title = "Grep: " .. selection })
	vim.cmd("copen")
end

vim.keymap.set("x", "<leader>f", function()
	if vim.fn.mode() == "V" then
		-- If in Visual Line mode, move to the end of the line before grepping
		-- This ensures the entire line is included in the selection
		-- Fixes issues getregion using "."
		vim.cmd("normal! $")
	end
	grep_selection_single_line()
end, { desc = "Grep selection (single line)" })
