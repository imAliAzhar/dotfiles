return {
	"saghen/blink.cmp",
	version = "*",
	opts = {
		completion = {
			documentation = { auto_show = true, auto_show_delay_ms = 500 },
			list = { selection = { preselect = false } },
		},
		keymap = {
			-- preset = "none",
			["<Tab>"] = { "select_next" },
			["<S-Tab>"] = { "select_prev" },
			["<C-space>"] = { "show", "fallback" },
			["<up>"] = { "select_prev" },
			["<down>"] = { "select_next" },
			["<C-d>"] = { "scroll_documentation_down", "fallback" },
			["<C-u>"] = { "scroll_documentation_up", "fallback" },
		},

		cmdline = {
			preset = "enter",
			["<Tab>"] = { "select_next" },
			["<S-Tab>"] = { "select_prev" },
			["<C-e>"] = { "select_and_accept", "fallback" },
			["<C-space>"] = { "show" },
		},

		appearance = {
			use_nvim_cmp_as_default = true,
			nerd_font_variant = "mono",
		},

		-- Default list of enabled providers defined so that you can extend it
		-- elsewhere in your config, without redefining it, due to `opts_extend`
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},
	},
	opts_extend = { "sources.default" },
}
