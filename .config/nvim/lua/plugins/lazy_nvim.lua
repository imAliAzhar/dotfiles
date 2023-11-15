print("loaded lazy.nvim")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	"folke/which-key.nvim",
	{
		'nvim-telescope/telescope.nvim', tag = '0.1.4',
		dependencies = { 'nvim-lua/plenary.nvim' }
	},
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	{"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
	{
		{
			'VonHeikemen/lsp-zero.nvim',
			branch = 'v3.x',
			lazy = true,
			config = false,
			init = function()
				-- Disable automatic setup, we are doing it manually
				vim.g.lsp_zero_extend_cmp = 0
				vim.g.lsp_zero_extend_lspconfig = 0
			end,
		},
		{
			'williamboman/mason.nvim',
			lazy = false,
			config = true,
		},

		-- Autocompletion
		{
			'hrsh7th/nvim-cmp',
			event = 'InsertEnter',
			dependencies = {
				{'L3MON4D3/LuaSnip'},
			},
			config = function()
				-- Here is where you configure the autocompletion settings.
				local lsp_zero = require('lsp-zero')
				lsp_zero.extend_cmp()

				-- And you can configure cmp even more, if you want to.
				local cmp = require('cmp')
				local cmp_action = lsp_zero.cmp_action()

				cmp.setup({
					formatting = lsp_zero.cmp_format(),
					mapping = cmp.mapping.preset.insert({
						['<C-Space>'] = cmp.mapping.complete(),
						['<C-u>'] = cmp.mapping.scroll_docs(-4),
						['<C-d>'] = cmp.mapping.scroll_docs(4),
						['<C-f>'] = cmp_action.luasnip_jump_forward(),
						['<C-b>'] = cmp_action.luasnip_jump_backward(),
					})
				})
			end
		},

		-- LSP
		{
			'neovim/nvim-lspconfig',
			cmd = {'LspInfo', 'LspInstall', 'LspStart'},
			event = {'BufReadPre', 'BufNewFile'},
			dependencies = {
				{'hrsh7th/cmp-nvim-lsp'},
				{'williamboman/mason-lspconfig.nvim'},
			},
			config = function()
				-- This is where all the LSP shenanigans will live
				local lsp_zero = require('lsp-zero')
				lsp_zero.extend_lspconfig()

				lsp_zero.on_attach(function(client, bufnr)
					-- see :help lsp-zero-keybindings
					-- to learn the available actions
					lsp_zero.default_keymaps({buffer = bufnr})
				end)

      require('mason-lspconfig').setup({
					ensure_installed = {},
					handlers = {
						lsp_zero.default_setup,
						lua_ls = function()
							-- (Optional) Configure lua language server for neovim
							local lua_opts = lsp_zero.nvim_lua_ls()
							require('lspconfig').lua_ls.setup(lua_opts)
						end,
					}
				})
			end
		}
	}
})

