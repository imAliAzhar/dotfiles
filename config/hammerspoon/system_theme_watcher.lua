--- Returns the current system theme
---@return "dark" | "light" The current system theme
local function current_theme()
	return (hs.host.interfaceStyle() == "Dark") and "dark" or "light"
end

---@class SystemThemeWatcher
---@field last_theme "dark" | "light" The last known theme
---@field listeners fun(theme: "dark" | "light")[] Array of callback functions
---@field themeWatcher hs.distributednotifications? The notification watcher object
local M = {}

--- Sets up the theme watcher to monitor system theme changes
---@return nil
function M:setup()
	self.last_theme = current_theme()
	self.listeners = {}
	self.themeWatcher = hs.distributednotifications.new(function()
		local theme = current_theme()
		if theme ~= M.last_theme then
			for _, listener in ipairs(M.listeners) do
				listener(theme)
			end
			M.last_theme = theme
		end
	end, "AppleInterfaceThemeChangedNotification")

	---@diagnostic disable-next-line: undefined-field
	self.themeWatcher:start()
end

--- Adds a callback function to be called when theme changes
---@param callback fun(theme: "dark" | "light") Function to call on theme change
---@return nil
function M:add_listener(callback)
	if type(callback) == "function" then
		table.insert(self.listeners, callback)
	end
end

return M
