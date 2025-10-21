return {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	settings = {
		Lua = {
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
		},
	},
}
