-- ~/.hammerspoon/init.lua
hs.alert.show("Hammerspoon config reloaded", 1)

-- Iinstall the Hammerspoon CLI
require("hs.ipc")
local result = hs.ipc.cliInstall("/Users/aliazhar.khan/.local/bin", true)
hs.alert.show("Hammerspoon CLI installed: " .. tostring(result), 1)

local function sh(cmd)
	hs.task.new("/bin/zsh", nil, { "-lc", cmd }):start()
end

local system_theme_watcher = require("system_theme_watcher")
system_theme_watcher:setup()

system_theme_watcher:add_listener(function(theme)
	hs.alert.show("Theme changed to " .. theme, 1)

	sh(([[~/.config/theme/scripts/set-theme.sh rose-pine %s]]):format(theme))
end)

local external_display_watcher = require("external_display_watcher")
external_display_watcher:setup()

external_display_watcher:add_listener(function(count)
	-- Reload sketchybar to update display settings
	sh("sketchybar --bar display=" .. count)
	if count > 1 then
		sh("bottom_bar --bar hidden=false")
	else
		sh("bottom_bar --bar hidden=true")
	end
end)

-- hs.loadSpoon("EmmyLua")
