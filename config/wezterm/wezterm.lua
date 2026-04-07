local wezterm = require("wezterm")
local workspaces = require("workspaces")
local theme = require("theme")

local config = wezterm.config_builder()

-- Sync 'TERM_EMULATION' ~/.config/zsh/tmux.zsh
-- Sync ~.local/bin/nvr
local emulate_tmux = false

local keymap = require("keymap")
keymap.setup_keymap(config, emulate_tmux)

-- config.font = wezterm.font("Iosevka", { weight = "Regular" })
-- config.font = wezterm.font("Monolisa", { weight = "Regular" })
-- config.font = wezterm.font("Dank Mono", { weight = "Regular" })
config.font = wezterm.font("Victor Mono", { weight = "Medium" })

config.font_size = 17
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.color_scheme = theme.color_scheme

config.colors = {
	cursor_fg = theme.cursor_fg,
	cursor_bg = theme.cursor_bg,
	tab_bar = {
		background = theme.tab_bar_background,
		active_tab = {
			bg_color = theme.tab_bar_active_tab_bg_color,
			fg_color = theme.tab_bar_active_tab_fg_color,
			intensity = "Bold", -- "Half", "Normal", "Bold"
			underline = "None", -- "None", "Single", "Double"
			italic = false,
			strikethrough = false,
		},
		inactive_tab = {
			bg_color = theme.tab_bar_inactive_tab_bg_color,
			fg_color = theme.tab_bar_inactive_tab_fg_color,
		},
	},
}

config.use_resize_increments = false
config.adjust_window_size_when_changing_font_size = false

-- config.force_reverse_video_cursor = true
config.pane_focus_follows_mouse = true
config.scrollback_lines = 5000

config.enable_tab_bar = emulate_tmux
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false

config.window_background_opacity = 0.90
config.macos_window_background_blur = 10
config.window_close_confirmation = "NeverPrompt"
config.native_macos_fullscreen_mode = true
config.window_decorations = "RESIZE"
config.debug_key_events = false
config.max_fps = 120

config.set_environment_variables = { MUX = "tmux" }

if emulate_tmux then
	config.set_environment_variables.MUX = "wezterm"

	workspaces.create_workspaces(config)

	-- -- custom fullscreen breaks window manager
	-- wezterm.on("gui-startup", function()
	-- local _, _, window = wezterm.mux.spawn_window({})
	-- window:gui_window():toggle_fullscreen()
	-- end)

	wezterm.on("update-right-status", function(window)
		local workspace = workspaces.get_current_workspace_label(window)

		local segments = {}

		if window:leader_is_active() then
			table.insert(segments, { Foreground = { Color = theme.status_line_fg } })
			table.insert(segments, { Background = { Color = theme.status_line_bg } })
			table.insert(segments, { Attribute = { Intensity = "Bold" } })
			table.insert(segments, { Text = " LEADER " })
			table.insert(segments, "ResetAttributes")
			table.insert(segments, { Text = " " })
		end

		-- workspace text
		table.insert(segments, { Foreground = { Color = theme.status_line_active } })
		table.insert(segments, { Text = workspace })

		window:set_right_status(wezterm.format(segments))
	end)
	config.unix_domains = { { name = "unix" } }

	config.default_workspace = "Home"
end

return config
