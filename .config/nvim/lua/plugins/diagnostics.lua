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
	config = function(_, opts)
		require("diagflow").setup(opts)

		-- Create a custom namespace. This will aggregate signs from all other
		-- namespaces and only show the one with the highest severity on a
		-- given line
		local ns = vim.api.nvim_create_namespace("diagnostics")

		-- Get a reference to the original signs handler
		local orig_signs_handler = vim.diagnostic.handlers.signs

		vim.diagnostic.config({
			severity_sort = true,
			-- virtual_lines = { current_line = false },

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

		vim.diagnostic.handlers.signs = {
			show = function(_, bufnr, _, opts)
				-- Get all diagnostics from the whole buffer rather than just the
				-- diagnostics passed to the handler
				local diagnostics = vim.diagnostic.get(bufnr)

				-- Find the "worst" diagnostic per line
				local max_severity_per_line = {}
				for _, d in pairs(diagnostics) do
					local m = max_severity_per_line[d.lnum]
					if not m or d.severity < m.severity then
						max_severity_per_line[d.lnum] = d
					end
				end

				-- Pass the filtered diagnostics (with our custom namespace) to
				-- the original handler
				local filtered_diagnostics = vim.tbl_values(max_severity_per_line)
				orig_signs_handler.show(ns, bufnr, filtered_diagnostics, opts)
			end,

			hide = function(_, bufnr)
				orig_signs_handler.hide(ns, bufnr)
			end,
		}

		local map = vim.keymap.set
		map("n", "]e", function()
			vim.diagnostic.jump({ severity = vim.diagnostic.severity.ERROR, wrap = true, count = 1 })
		end, { desc = "Go to next error" })
		map("n", "[e", function()
			vim.diagnostic.jump({ severity = vim.diagnostic.severity.ERROR, wrap = true, count = 1 })
		end, { desc = "Go to next error" })

		map("n", "]w", function()
			vim.diagnostic.jump({ severity = vim.diagnostic.severity.WARN, wrap = true, count = 1 })
		end, { desc = "Go to next warning" })
		map("n", "[w", function()
			vim.diagnostic.jump({ severity = vim.diagnostic.severity.WARN, wrap = true, count = 1 })
		end, { desc = "Go to next warning" })
	end,
}
