local wezterm = require("wezterm")
local utils = require("utils")

local M = {}

M.create_workspaces = function()
	local home = wezterm.home_dir

	local workspaces = {
		Home = home,
		Dotfiles = home .. "/.config",
	}

	for _, path in ipairs(wezterm.read_dir(home .. "/Projects")) do
		local basename = path:match("([^/]+)$")
		workspaces[basename] = path
	end

	wezterm.GLOBAL.WorkspacesAll = workspaces
	wezterm.GLOBAL.WorkspacesActive = { "Home" }
	wezterm.GLOBAL.WorkspacesOrder = { Home = 1 }
end

M.get_all_workspaces = function()
	local active_workspaces = wezterm.mux.get_workspace_names()

	local workspaces = {}

	for _, ws_name in ipairs(active_workspaces) do
		local ws_path = wezterm.GLOBAL.WorkspacesAll[ws_name]
		local id = "o|" .. ws_name .. "|" .. ws_path
		table.insert(workspaces, id)
	end

	for ws_name, _ in pairs(wezterm.GLOBAL.WorkspacesAll) do
		local ws_path = wezterm.GLOBAL.WorkspacesAll[ws_name]

		if utils.contains(active_workspaces, ws_name) ~= true then
			local id = "x|" .. ws_name .. "|" .. ws_path
			table.insert(workspaces, id)
		end
	end

	return workspaces
end

M.select_workspace = function(ws_name, ws_path)
	-- wezterm converts ordered global to sparse
	local workspaces = utils.ordered(wezterm.GLOBAL.WorkspacesActive)

	if utils.contains(workspaces, ws_name) ~= true then
		table.insert(workspaces, ws_name)
	end

	wezterm.GLOBAL.WorkspacesActive = workspaces

	local env = {}

	if ws_name == "Dotfiles" then
		wezterm.log_info("Switching to Dotfiles workspace")
		local home = os.getenv("HOME")

		env["GIT_WORK_TREE"] = home
		env["GIT_DIR"] = home .. "/.dotfiles"
	end

	return wezterm.action.SwitchToWorkspace({
		name = ws_name,
		spawn = {
			args = { "zsh", "-l", "-c", "nvim" },
			cwd = ws_path,
			set_environment_variables = env,
		},
	})
end

M.get_current_workspace_label = function(window)
	local workspaces = wezterm.mux.get_workspace_names()

	local idx = "?"
	local active_ws = window:active_workspace()

	for i, ws in ipairs(workspaces) do
		if ws == active_ws then
			idx = tostring(i)
			break
		end
	end

	local label = "[" .. active_ws .. " " .. idx .. "/" .. #workspaces .. "] "

	return label
end

return M
