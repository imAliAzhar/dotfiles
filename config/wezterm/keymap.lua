local wezterm = require("wezterm")
local workspaces = require("workspaces")
local utils = require("utils")
local action = wezterm.action

local keymap = {
	-- Terminal

	{
		key = "q",
		mods = "CMD",
		action = wezterm.action.QuitApplication,
	},

	{
		key = "c",
		mods = "SUPER",
		action = action.CopyTo("Clipboard"),
	},

	{
		key = "v",
		mods = "SUPER",
		action = action.PasteFrom("Clipboard"),
	},

	{
		key = "_",
		mods = "SUPER",
		action = action.DecreaseFontSize,
	},

	{
		key = "+",
		mods = "SUPER",
		action = action.IncreaseFontSize,
	},

	{
		key = "=",
		mods = "SUPER",
		action = action.ResetFontSize,
	},

	{
		key = "f",
		mods = "SUPER|CTRL",
		action = action.ToggleFullScreen,
	},

	{
		mods = "SUPER",
		key = "-",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "-" }),
		}),
	},
	{
		mods = "SUPER",
		key = "\\",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "\\" }),
		}),
	},

	-- Editor

	-- {
	-- 	key = "w",
	-- 	mods = "SUPER",
	-- 	action = action.Multiple({
	-- 		action.SendKey({ key = " " }),
	-- 		action.SendKey({ key = "w" }),
	-- 	}),
	-- },

	{
		key = "g",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "g" }),
		}),
	},

	{
		key = "/",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = " " }),
			action.SendKey({ key = "/" }),
		}),
	},

	-- {
	-- 	key = "s",
	-- 	mods = "SUPER",
	-- 	action = action.Multiple({
	-- 		action.SendKey({ key = " " }),
	-- 		action.SendKey({ key = "s" }),
	-- 	}),
	-- },
	{
		key = "s",
		mods = "SUPER|SHIFT",
		action = action.Multiple({
			action.SendKey({ key = " " }),
			action.SendKey({ key = "S" }),
		}),
	},

	{
		key = "p",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = " " }),
			action.SendKey({ key = "f", mods = "CTRL" }),
		}),
	},

	{
		key = "f",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = " " }),
			action.SendKey({ key = "f" }),
		}),
	},

	{
		key = "e",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = " " }),
			action.SendKey({ key = "e" }),
		}),
	},

	{ key = "l", mods = "CTRL|SUPER", action = wezterm.action.ShowDebugOverlay },
}

local tmux = {
	-- Open Session Selector (defined in ~/.config/tmux/tmux.conf)
	{
		key = "r",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "r" }),
		}),
	},

	-- Create new window (defined in ~/.config/tmux/tmux.conf)
	{
		key = "t",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "t" }),
		}),
	},

	{
		key = "T",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "T" }),
		}),
	},

	{
		key = "j",
		mods = "SUPER|SHIFT",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = ")" }),
		}),
	},

	{
		key = "k",
		mods = "SUPER|SHIFT",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "(" }),
		}),
	},

	{
		key = "l",
		mods = "SUPER|SHIFT",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "n" }),
		}),
	},

	{
		key = "h",
		mods = "SUPER|SHIFT",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "p" }),
		}),
	},

	{
		key = "l",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "n" }),
		}),
	},

	{
		key = "h",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "p" }),
		}),
	},

	{
		key = "z",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "z" }),
		}),
	},

	{
		key = "o",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "o" }),
		}),
	},

	{
		key = "j",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "o" }),
		}),
	},

	{
		key = "k",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "o" }),
		}),
	},
}

local tmux_emulated = {
	{
		key = "g",
		mods = "CTRL",
		action = wezterm.action.DisableDefaultAssignment,
	},
	{
		key = "[",
		mods = "SUPER",
		action = wezterm.action.ActivateCopyMode,
	},

	{
		key = "f",
		mods = "SUPER",
		action = action.TogglePaneZoomState,
	},

	{
		key = "t",
		mods = "SUPER",
		action = action.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "l",
		mods = "SUPER",
		action = action.ActivateTabRelative(1),
	},
	{
		key = "h",
		mods = "SUPER",
		action = action.ActivateTabRelative(-1),
	},

	{
		key = "l",
		mods = "SUPER|SHIFT",
		action = action.ActivateTabRelative(1),
	},
	{
		key = "h",
		mods = "SUPER|SHIFT",
		action = action.ActivateTabRelative(-1),
	},

	{
		key = "g",
		mods = "SUPER",
		action = action.SpawnCommandInNewTab({
			args = { "zsh", "-l", "-c", "lazygit" },
		}),
	},

	-- {
	-- 	key = "g",
	-- 	mods = "SUPER",
	-- 	action = action.Multiple({
	-- 		action.SendKey({ key = " " }),
	-- 		action.SendKey({ key = "l" }),
	-- 		action.SendKey({ key = "g" }),
	-- 	}),
	-- },
	--
	{
		key = "i",
		mods = "SUPER",
		action = action.ActivatePaneDirection("Prev"),
	},
	{
		key = "o",
		mods = "SUPER",
		action = action.ActivatePaneDirection("Next"),
	},

	{
		key = ",",
		mods = "SUPER",
		action = action.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	-- {
	-- 	key = "w",
	-- 	mods = "SUPER",
	-- 	action = action.ShowTabNavigator,
	-- },

	{
		key = "x",
		mods = "SUPER",
		action = action.CloseCurrentTab({ confirm = false }),
	},

	{
		key = "-",
		mods = "SUPER",
		action = wezterm.action.SplitPane({
			direction = "Down",
			size = { Percent = 30 },
		}),
	},
	{
		key = "\\",
		mods = "SUPER",
		action = wezterm.action.SplitPane({
			direction = "Right",
			size = { Percent = 30 },
		}),
	},
	{
		-- |
		key = "{",
		mods = "SUPER|SHIFT",
		action = action.PaneSelect({ mode = "SwapWithActiveKeepFocus" }),
	},

	-- Attach to muxer
	{
		key = "a",
		mods = "LEADER",
		action = action.AttachDomain("unix"),
	},

	-- Detach from muxer
	{
		key = "d",
		mods = "LEADER",
		action = action.DetachDomain({ DomainName = "unix" }),
	},

	{
		key = "$",
		mods = "LEADER|SHIFT",
		action = action.PromptInputLine({
			description = "Enter new name for session",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					wezterm.mux.rename_workspace(window:mux_window():get_workspace(), line)
				end
			end),
		}),
	},

	-- {
	-- 	key = "j",
	-- 	mods = "SHIFT|SUPER",
	-- 	action = wezterm.action_callback(function(window, pane)
	-- 		local active_workspace = wezterm.mux.get_active_workspace()
	-- 		wezterm.mux.increment_workspace_order(active_workspace)
	-- 		local status = workspaces.get_current_workspace_label(window)
	-- 		window:set_right_status(status)
	-- 	end),
	-- },
	--
	-- {
	-- 	key = "k",
	-- 	mods = "SHIFT|SUPER",
	-- 	action = wezterm.action_callback(function(window, pane)
	-- 		local active_workspace = wezterm.mux.get_active_workspace()
	-- 		wezterm.mux.decrement_workspace_order(active_workspace)
	-- 		local status = workspaces.get_current_workspace_label(window)
	-- 		window:set_right_status(status)
	-- 	end),
	-- },

	{ key = "k", mods = "SHIFT|SUPER", action = action.SwitchWorkspaceRelative(1) },
	{ key = "j", mods = "SHIFT|SUPER", action = action.SwitchWorkspaceRelative(-1) },

	{
		key = "r",
		mods = "SUPER",
		action = wezterm.action_callback(function(window, pane)
			local workspace_list = workspaces.get_all_workspaces()

			local choices = {}

			for _, ws in ipairs(workspace_list) do
				local data = utils.split(ws, "|")
				local marker, name = data[1], data[2]
				local is_active = marker == "o"

				if is_active then
					name = wezterm.format({
						{ Foreground = { AnsiColor = "Fuchsia" } },
						{ Text = name },
					})
				end

				table.insert(choices, { label = name, id = ws })
			end

			window:perform_action(
				action.InputSelector({
					action = wezterm.action_callback(function(inner_window, inner_pane, id)
						if not id then
							wezterm.log_info("cancelled")
						else
							wezterm.log_info("id = " .. id)

							local data = utils.split(id, "|")
							local name, path = data[2], data[3]

							inner_window:perform_action(workspaces.select_workspace(name, path), inner_pane)
						end
					end),
					title = "Workspace",
					choices = choices,
					fuzzy = true,
					fuzzy_description = "Select: ",
				}),
				pane
			)
		end),
	},
	{
		key = "r",
		mods = "LEADER|CTRL|SUPER",
		action = action.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, _, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
}

for i = 1, 8 do
	-- CTRL+ALT + number to move to that position
	table.insert(tmux_emulated, {
		key = tostring(i),
		mods = "LEADER|CTRL|SUPER",
		action = wezterm.action.MoveTab(i - 1),
	})
end

local module = {}

function module.setup_keymap(config, emulate_tmux)
	if emulate_tmux then
		for _, v in ipairs(tmux_emulated) do
			table.insert(keymap, v)
		end
	else
		for _, v in ipairs(tmux) do
			table.insert(keymap, v)
		end
	end

	if emulate_tmux then
		config.leader = { key = "`", mods = "NONE", timeout_milliseconds = 1000 }
	end

	config.disable_default_key_bindings = true
	config.keys = keymap
end

return module
