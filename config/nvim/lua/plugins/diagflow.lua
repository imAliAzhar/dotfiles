return {
	"dgagn/diagflow.nvim",
	event = "LspAttach",
	opts = {
		scope = "line",
		format = function(diagnostic)
			local str = ""
			if diagnostic.code then
				str = str .. diagnostic.code .. ": "
			end
			return str .. diagnostic.message
		end,
	},
}
