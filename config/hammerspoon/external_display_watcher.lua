--- Returns the current display count
---@return number The number of connected displays
local function display_count()
	return #hs.screen.allScreens()
end

---@class ExternalDisplayWatcher
---@field last_count number The last known display count
---@field listeners fun(count: number)[] Array of callback functions
---@field screenWatcher hs.screen.watcher? The screen watcher object
local M = {}

--- Sets up the display watcher to monitor external display connections
---@return nil
function M:setup()
	self.last_count = display_count()
	self.listeners = {}
	self.screenWatcher = hs.screen.watcher.new(function()
		local count = display_count()
		if count ~= M.last_count then
			for _, listener in ipairs(M.listeners) do
				listener(count)
			end
			M.last_count = count
		end
	end)

	---@diagnostic disable-next-line: undefined-field
	self.screenWatcher:start()
end

--- Adds a callback function to be called when display count changes
---@param callback fun(count: number) Function to call on display change
---@return nil
function M:add_listener(callback)
	if type(callback) == "function" then
		table.insert(self.listeners, callback)
	end
end

return M