-- Use Node 22 to avoid .nvmrc picking up older versions
local home = os.getenv("HOME")
local node22_base = home .. "/Library/Application Support/fnm/node-versions/v22.11.0/installation"
local node22 = node22_base .. "/bin/node"
local vtsls_js = node22_base .. "/lib/node_modules/@vtsls/language-server/bin/vtsls.js"

return {
	cmd = { node22, vtsls_js, "--stdio" },
	root_markers = { "tsconfig.json" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
	settings = {
		typescript = {
			tsserver = {
				nodePath = node22,
				maxTsServerMemory = 8192,
			},
		},
	},
}
