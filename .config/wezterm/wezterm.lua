local wezterm = require("wezterm")
local workspaces = require("workspaces")

local config = wezterm.config_builder()

-- Sync 'TERM_EMULATION' ~/.config/zsh/tmux.zsh
-- Sync ~.local/bin/nvr
local emulate_tmux = false

local keymap = require("keymap")
keymap.setup_keymap(config, emulate_tmux)

config.font = wezterm.font("Victor Mono", { weight = "Medium" })
config.font_size = 16
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- TODO: use from catppuccin package
-- catppuccin-macchiato | https://catppuccin.com/palette
local catpuccin_mocha = {
	crust = "#181926",
	lavender = "#b7bdf8",
	maroon = "#ee99a0",
	text = "#cad3f5",
	subtext0 = "#a5adcb",
	subtext1 = "#b8c0e0",
}

local catpuccin_latte = {
	crust = "#dce0e8",
	lavender = "#7287fd",
	maroon = "#e64553",
	text = "#4c4f69",
	subtext0 = "#6c6f85",
	subtext1 = "#5c5f77",
}

local function get_system_theme()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

local system_theme = get_system_theme()
local is_light_theme = system_theme == "Light"

local palette = is_light_theme and catpuccin_latte or catpuccin_mocha

config.color_scheme = is_light_theme and "catppuccin-latte" or "catppuccin-macchiato"
config.colors = {
	cursor_fg = palette.crust,
	cursor_bg = palette.peach,
	tab_bar = {
		background = palette.crust,
		active_tab = {
			bg_color = palette.crust,
			fg_color = palette.text,
			intensity = "Bold", -- "Half", "Normal", "Bold"
			underline = "None", -- "None", "Single", "Double"
			italic = false,
			strikethrough = false,
		},
		inactive_tab = {
			bg_color = palette.crust,
			fg_color = palette.subtext0,
		},
	},
}

config.use_resize_increments = true
config.adjust_window_size_when_changing_font_size = true

-- config.force_reverse_video_cursor = true
config.pane_focus_follows_mouse = true
config.scrollback_lines = 5000

config.enable_tab_bar = emulate_tmux
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false

config.window_background_opacity = is_light_theme and 0.90 or 0.85
config.macos_window_background_blur = 20
config.window_close_confirmation = "NeverPrompt"
config.native_macos_fullscreen_mode = true
config.window_decorations = "RESIZE"
config.debug_key_events = false
config.max_fps = 120

if emulate_tmux then
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
			table.insert(segments, { Foreground = { Color = palette.crust } })
			table.insert(segments, { Background = { Color = palette.maroon } })
			table.insert(segments, { Attribute = { Intensity = "Bold" } })
			table.insert(segments, { Text = " LEADER " })
			table.insert(segments, "ResetAttributes")
			table.insert(segments, { Text = " " })
		end

		-- workspace text
		table.insert(segments, { Foreground = { Color = palette.subtext1 } })
		table.insert(segments, { Text = workspace })

		window:set_right_status(wezterm.format(segments))
	end)
	config.unix_domains = { { name = "unix" } }

	config.default_workspace = "Home"
end

return config
