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

	sh(([[~/.config/theme/scripts/set-theme.sh cattpuccin %s]]):format(theme))
end)

hs.loadSpoon("EmmyLua")
