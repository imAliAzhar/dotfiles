--- @diagnostic disable: undefined-global

-- Show the link target of the hovered item in the status line
Status:children_add(function(self)
	local h = self._current.hovered
	if h and h.link_to then
		return " -> " .. tostring(h.link_to)
	else
		return ""
	end
end, 3300, Status.LEFT)

require("folder-rules"):setup()
require("hidden-files"):setup()
