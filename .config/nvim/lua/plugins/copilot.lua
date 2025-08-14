return {
	"github/copilot.vim",
	config = function()
		vim.keymap.set("i", "<C-l>", 'copilot#Accept("")', {
			expr = true,
			replace_keycodes = false,
		})
		vim.g.copilot_no_tab_map = true

		vim.keymap.set("i", "<C-e>", "<Plug>(copilot-accept-word)")

		vim.keymap.set("n", "<leader>ae", function()
			vim.g.copilot_enabled = true
		end, { desc = "Enable Copilot" })

		vim.keymap.set("n", "<leader>ad", function()
			vim.g.copilot_enabled = false
		end, { desc = "Disable Copilot" })
	end,
}
