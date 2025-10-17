return {
	"stevearc/conform.nvim",
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				fish = { "fish_indent" },
				lua = { "stylua" },
				python = { "python" },
				rust = { "rustfmt", lsp_format = "fallback" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				json = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				xml = { "xmlformatter" },
				sql = { "sleek" },
			},
			format_on_save = {
				-- These options will be passed to conform.format()
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		})

		vim.keymap.set("n", "<leader>F", function()
			conform.format({ async = true, lsp_fallback = true })
		end)
	end,
}
