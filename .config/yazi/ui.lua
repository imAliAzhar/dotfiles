-- https://github.com/sxyazi/yazi/issues/297#issuecomment-1774081158

---@diagnostic disable: undefined-global

function Folder:icon(file)
	return ui.Span(" " .. file:icon() .. "        ")
end
