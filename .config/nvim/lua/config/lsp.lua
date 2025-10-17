vim.lsp.enable("ts_ls")
vim.lsp.enable("lua_ls")
-- vim.lsp.enable("denols")
-- vim.lsp.enable("fish_ls")

local function configure_diagnistics()
	vim.diagnostic.config({
		severity_sort = true,
		virtual_lines = false,
		virtual_text = false,

		signs = {
			-- To enable text, increase vim.opt.signcolumn in settings.lua
			text = {
				[vim.diagnostic.severity.ERROR] = " •",
				[vim.diagnostic.severity.WARN] = " •",
				[vim.diagnostic.severity.INFO] = " •",
				[vim.diagnostic.severity.HINT] = " •",
			},
			numhl = {
				[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
				[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
				[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
				[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
			},
		},
	})
end

local function improve_diagnostic_floating_window()
	vim.keymap.set("n", "<C-w>d", function()
		local _, winid = vim.diagnostic.open_float({ focusable = true })
		if winid ~= nil then
			vim.api.nvim_set_current_win(winid)
		end
		vim.cmd("normal! j2w") -- Move the cursor down to the actual diagnostic
	end, { desc = "Expand a diagnostic into a float" })
end

local function add_diagnostic_jumps()
	vim.keymap.set("n", "]e", function()
		vim.diagnostic.jump({ severity = vim.diagnostic.severity.ERROR, wrap = true, count = 1 })
	end, { desc = "Go to next error" })
	vim.keymap.set("n", "[e", function()
		vim.diagnostic.jump({ severity = vim.diagnostic.severity.ERROR, wrap = true, count = -1 })
	end, { desc = "Go to next error" })

	vim.keymap.set("n", "]w", function()
		vim.diagnostic.jump({ severity = vim.diagnostic.severity.WARN, wrap = true, count = 1 })
	end, { desc = "Go to next warning" })
	vim.keymap.set("n", "[w", function()
		vim.diagnostic.jump({ severity = vim.diagnostic.severity.WARN, wrap = true, count = -1 })
	end, { desc = "Go to next warning" })
end

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",

	callback = function(event)
		configure_diagnistics()
		improve_diagnostic_floating_window()
		add_diagnostic_jumps()
	end,
})
