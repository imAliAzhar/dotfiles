return {
	"chrisgrieser/nvim-spider",
	lazy = false,
	config = function()
		require("spider").setup({
			consistentOperatorPending = true,
		})

		vim.keymap.set({ "n", "o" }, "gw", "<cmd>lua require('spider').motion('w')<CR>", { desc = "Spider-w" })
		vim.keymap.set({ "n", "o" }, "ge", "<cmd>lua require('spider').motion('e')<CR>", { desc = "Spider-e" })
		vim.keymap.set({ "n", "o" }, "gb", "<cmd>lua require('spider').motion('b')<CR>", { desc = "Spider-b" })

		-- Visual mode mapping
		vim.keymap.set("x", "i<leader>w", function()
			vim.cmd("normal! l") -- move into word
			require("spider").motion("b")
			vim.cmd("normal! o") -- anchor start
			require("spider").motion("e")
		end, {
			desc = "Visual inner CamelCase word",
			silent = true,
		})

		-- Operator-pending mode mapping (used in `d`, `c`, `y`, etc.)
		vim.keymap.set("o", "i<leader>w", function()
			vim.cmd("normal! v")
			vim.cmd("normal! l")
			require("spider").motion("b")
			vim.cmd("normal! v")
			require("spider").motion("e")
		end, {
			desc = "inner Spider CamelCase word (operator)",
			silent = true,
		})
	end,
}
