local M = {
	win = nil,
}

local W = {
	win = nil,
	buf = nil,
	opts = {
		relative = "editor",
		width = 40,
		height = 10,
		col = math.floor((vim.o.columns - 40) / 2),
		row = math.floor((vim.o.lines - 10) / 2),
		style = "minimal",
	},
}

W.init = function(self)
	self.buf = vim.api.nvim_create_buf(false, true)
end

W.show = function(self)
	self.win = vim.api.nvim_open_win(self.buf, false, self.opts)
end

W.hide = function(self)
	vim.api.nvim_win_close(self.win, false)
end

M.init = function()
	M.win = W:init()
end

-- return M
