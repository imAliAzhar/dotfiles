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

		local lsp = require("lspconfig")

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
			end,
		})
	end,
}
