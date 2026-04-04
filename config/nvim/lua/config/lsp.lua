vim.lsp.enable("vtsls")
-- vim.lsp.enable("tsserver")
vim.lsp.enable("lua_ls")
-- vim.lsp.enable("denols")
-- vim.lsp.enable("fish_ls")
vim.lsp.enable("bashls")

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

	callback = function(ev)
		configure_diagnistics()
		improve_diagnostic_floating_window()
		add_diagnostic_jumps()

		local client = vim.lsp.get_client_by_id(ev.data.client_id)

		-- Navigation (not in defaults)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to Definition" })
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Go to Declaration" })

		-- Override grr to include symbol name in quickfix title
		vim.keymap.set("n", "grr", function()
			local word = vim.fn.expand("<cword>")
			vim.lsp.buf.references(nil, {
				on_list = function(options)
					options.title = "References: " .. word
					vim.fn.setqflist({}, " ", options)
					vim.cmd.copen()
				end,
			})
		end, { buffer = ev.buf, desc = "References" })

		-- Call Hierarchy
		vim.keymap.set("n", "grc", vim.lsp.buf.incoming_calls, { buffer = ev.buf, desc = "Incoming Calls" })
		vim.keymap.set("n", "grC", vim.lsp.buf.outgoing_calls, { buffer = ev.buf, desc = "Outgoing Calls" })

		-- Format
		vim.keymap.set({ "n", "v" }, "grf", function()
			vim.lsp.buf.format({ async = true })
		end, { buffer = ev.buf, desc = "Format" })

		-- Workspace Symbols
		vim.keymap.set("n", "grw", vim.lsp.buf.workspace_symbol, { buffer = ev.buf, desc = "Workspace Symbols" })

		-- vtsls-specific
		if client.name == "vtsls" then
			vim.keymap.set("n", "grs", function()
				local params = vim.lsp.util.make_position_params(0, "utf-16")
				client:request("workspace/executeCommand", {
					command = "typescript.goToSourceDefinition",
					arguments = { params.textDocument.uri, params.position },
				}, function(_, result)
					if result and #result > 0 then
						vim.lsp.util.show_document(result[1], "utf-16", { focus = true })
					else
						vim.notify("No source definition found", vim.log.levels.INFO)
					end
				end, ev.buf)
			end, { buffer = ev.buf, desc = "Go to Source Definition" })
		end
	end,
})
