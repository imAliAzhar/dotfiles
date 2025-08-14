local check_project_config = function()
	local cwd = vim.fn.getcwd()
	local project_config = cwd .. "/.nvim/init.lua"
	local file_exists = vim.loop.fs_stat(project_config)

	if file_exists then
		vim.cmd("source " .. project_config)
	end
end

check_project_config()
