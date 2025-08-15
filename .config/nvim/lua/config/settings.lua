vim.opt.ignorecase = true -- Case-insensitive by default
vim.opt.smartcase = true -- But case-sensitive if uppercase in search
vim.opt.expandtab = true --                                     Converts tabs to spaces
vim.opt.tabstop = 2 --                                          Set tab size
vim.opt.shiftwidth = 2 --                                       Set indent size on new line
vim.opt.number = true --                                        Hybrid line number
vim.opt.relativenumber = true --                                Relative line numbers
-- vim.opt.fcs=eob:\                           --               Hide tilde on blank lines
vim.opt.hidden = true --                                        Allow switching between unsaved buffers
-- vim.opt.guicursor+=n:hor100                 --               Use underline as curser
-- vim.opt.mouse=                              --               Disable mouse
--
vim.opt.hlsearch = false
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes:1" --                                 Prevent layout shift for plugins that use signcolumn (gitsign), "yes" for single :2 for two columns
vim.opt.cursorline = true --                                    Highlight the current line
vim.opt.cmdheight = 0 --                                        Hide the command line
-- vim.opt.clipboard = "unnamedplus"
vim.opt.wrap = true

local undo_dir = "/tmp/.vim-undo-dir"
if vim.fn.isdirectory(undo_dir) ~= 1 then
	vim.fn.mkdir(undo_dir, "p")
end
vim.opt.undodir = undo_dir
vim.opt.undofile = true

vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = false

vim.cmd("packadd cfilter")

-- Open help files in the current window as a normal buffer
vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "*",
	callback = function(event)
		if vim.bo[event.buf].filetype == "help" then
			vim.bo[event.buf].buflisted = true
			vim.cmd.only()
		end
	end,
})
