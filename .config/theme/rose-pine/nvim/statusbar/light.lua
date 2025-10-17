local p = require("rose-pine.palette")

local theme = {
	normal = {
		a = { bg = p.rose, fg = p.base, gui = "bold" },
		b = { bg = p.overlay, fg = p.rose },
		c = { bg = p.surface, fg = p.text },
	},
	insert = {
		a = { bg = p.foam, fg = p.base, gui = "bold" },
		b = { bg = p.overlay, fg = p.foam },
		c = { bg = p.surface, fg = p.text },
	},
	visual = {
		a = { bg = p.iris, fg = p.base, gui = "bold" },
		b = { bg = p.overlay, fg = p.iris },
		c = { bg = p.surface, fg = p.text },
	},
	replace = {
		a = { bg = p.pine, fg = p.base, gui = "bold" },
		b = { bg = p.overlay, fg = p.pine },
		c = { bg = p.surface, fg = p.text },
	},
	command = {
		a = { bg = p.love, fg = p.base, gui = "bold" },
		b = { bg = p.overlay, fg = p.love },
		c = { bg = p.surface, fg = p.text },
	},
	inactive = {
		a = { bg = p.surface, fg = p.muted, gui = "bold" },
		b = { bg = p.surface, fg = p.muted },
		c = { bg = p.surface, fg = p.muted },
	},
}
