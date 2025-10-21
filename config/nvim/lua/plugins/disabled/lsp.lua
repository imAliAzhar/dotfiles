return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
	},
	opts = {
		servers = {
			pyright = {},
			eslint = {
				on_attach = function(_, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						command = "EslintFixAll",
					})
				end,
			},
		},
	},

	config = function(_, opts)
		require("mason").setup()
		require("mason-lspconfig").setup()

		local lsp = vim.lsp.config

		----------------------------------------------------------------------------
		-- Lua

		vim.lsp.config("lua_ls", {
			on_init = function(client)
				if client.workspace_folders then
					local path = client.workspace_folders[1].name
					if
						path ~= vim.fn.stdpath("config")
						and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
					then
						return
					end
				end

				client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
					runtime = {
						version = "LuaJIT",
						-- Tell the language server how to find Lua modules same way as Neovim
						path = {
							"lua/?.lua",
							"lua/?/init.lua",
							"~/.config/yazi/plugins/types.yazi/",
						},
					},
					-- Make the server aware of Neovim runtime files
					workspace = {
						checkThirdParty = false,
						library = {
							vim.env.VIMRUNTIME,
							"${3rd}/luv/library",
							"~/.config/hammerspoon/Spoons/EmmyLua.spoon/annotations",
						},
					},
				})
			end,
			settings = {
				Lua = {},
			},
		})

		----------------------------------------------------------------------------
		-- Go

		lsp.gopls.setup({})

		----------------------------------------------------------------------------
		-- Deno

		lsp.denols.setup({
			root_dir = lsp.util.root_pattern("deno.json", "deno.jsonc"),
		})

		----------------------------------------------------------------------------
		-- Typescript

		require("typescript-tools").setup({
			root_dir = function(fname)
				local deno_root = lsp.util.root_pattern("deno.json", "deno.jsonc")(fname)
				if deno_root then
					return nil
				end

				return lsp.util.root_pattern("package.json")(fname)
			end,
			single_file_support = false,
			settings = {
				separate_diagnostic_server = true,
			},
		})

		----------------------------------------------------------------------------
		-- Auto Completion

		for server, config in pairs(opts.servers) do
			config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
			lsp[server].setup(config)
		end

		----------------------------------------------------------------------------
		-- Keymap

		vim.api.nvim_create_autocmd("LspAttach", {
			desc = "LSP actions",
			callback = function(event)
				local options = { buffer = event.buf }
				local map = vim.keymap.set

				map("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", options)
				map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", options)
				map("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", options)
				map("n", "gS", "<cmd>lua vim.lsp.buf.signature_help()<cr>", options)
				map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", options)
				map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", options)
				map("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", options)
				map("n", "<Leader>8", "<cmd>lua vim.lsp.buf.rename()<cr>", options)
				map("n", "<Leader>i", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", options)
				map("n", "<Leader>.", "<cmd>lua vim.lsp.buf.code_action()<cr>", options)
				map("n", "<leader>gH", function()
					local enabled = not vim.lsp.inlay_hint.is_enabled({})
					vim.lsp.inlay_hint.enable(enabled)
					vim.notify("Inlay hints: " .. (enabled and " on" or "off"))
				end, { buffer = 0, desc = "Toggle inlay hints" })

				map("n", "<C-w>d", function()
					local _, winid = vim.diagnostic.open_float({ focusable = true })
					if winid ~= nil then
						vim.api.nvim_set_current_win(winid)
					end
					vim.cmd("normal! j2w") -- Move the cursor down to the actual diagnostic
				end, { desc = "Expand an Error into a float" })

				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client ~= nil then
					client.server_capabilities.semanticTokensProvider = nil
				end

				-- Create a custom namespace. This will aggregate signs from all other
				-- namespaces and only show the one with the highest severity on a
				-- given line
				local ns = vim.api.nvim_create_namespace("diagnostics")

				-- Get a reference to the original signs handler
				local orig_signs_handler = vim.diagnostic.handlers.signs

				vim.diagnostic.config({
					virtual_text = false,
					float = { source = "if_many", border = "single" },
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
		})
	end,
}
