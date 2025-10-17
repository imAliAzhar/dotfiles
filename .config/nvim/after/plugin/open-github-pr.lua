local function open_github_pr_from_blame()
	local file = vim.api.nvim_buf_get_name(0)
	local line = vim.api.nvim_win_get_cursor(0)[1]

	-- Run git blame on the current line
	local handle = io.popen(string.format("git blame -L %d,+1 --porcelain -- %s", line, file))
	if not handle then
		vim.notify("Failed to run git blame", vim.log.levels.ERROR)
		return
	end

	local output = handle:read("*a")
	handle:close()

	-- Extract summary line from commit message
	local summary = output:match("summary%s+(.+)")
	if not summary then
		vim.notify("Could not extract summary from git blame", vim.log.levels.WARN)
		return
	end

	-- Extract PR number from summary (e.g. #9196)
	local pr_number = summary:match("#(%d+)")
	if not pr_number then
		vim.notify("No PR number found in commit message", vim.log.levels.WARN)
		return
	end

	-- Get git remote URL
	local remote_handle = io.popen("git remote get-url origin")
	if not remote_handle then
		vim.notify("Failed to get git remote URL", vim.log.levels.ERROR)
		return
	end
	local remote_url = remote_handle:read("*a")
	remote_handle:close()
	remote_url = remote_url:gsub("%s+", "") -- trim whitespace

	-- Normalize remote URL (handle SSH and HTTPS)
	local repo_path = remote_url
		:gsub("^git@github.com:", "https://github.com/") -- SSH -> HTTPS
		:gsub("%.git$", "") -- strip .git

	-- Construct PR URL
	local url = repo_path .. "/pull/" .. pr_number
	vim.fn.jobstart({ "open", url }, { detach = true })
end

-- Create a keybinding to call it
vim.keymap.set("n", "<leader><leader>gb", open_github_pr_from_blame, { desc = "Open GitHub PR from blame" })
