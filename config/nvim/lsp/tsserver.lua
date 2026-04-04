return {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "typescript" },
	root_dir = vim.fs.root(0, { "package.json", ".git" }),
}
