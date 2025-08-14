local M = {}

M.split = function(str, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(str, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

M.contains = function(array, value)
	for _, v in ipairs(array) do
		if v == value then
			return true
		end
	end
	return false
end

M.ordered = function(sparse)
	local ordered = {}
	for _, value in pairs(sparse) do
		table.insert(ordered, value)
	end
	return ordered
end

return M
