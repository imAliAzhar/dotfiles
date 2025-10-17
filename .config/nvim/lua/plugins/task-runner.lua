return {
	"stevearc/overseer.nvim",
	opts = {
		dap = false,
		task_list = {
			default_detail = 2,
			direction = "right",
			bindings = {
				["?"] = "ShowHelp",
				["g?"] = "ShowHelp",
				["<CR>"] = "RunAction",
				["<C-e>"] = "Edit",
				["o"] = "Open",
				["<C-v>"] = "OpenVsplit",
				["<C-s>"] = "OpenSplit",
				["<C-f>"] = "OpenFloat",
				["<C-q>"] = "OpenQuickFix",
				["p"] = "TogglePreview",
				["<C-l>"] = "IncreaseDetail",
				["<C-h>"] = "DecreaseDetail",
				["L"] = "IncreaseAllDetail",
				["H"] = "DecreaseAllDetail",
				["["] = "DecreaseWidth",
				["]"] = "IncreaseWidth",
				["K"] = "PrevTask",
				["J"] = "NextTask",
				["<C-k>"] = "ScrollOutputUp",
				["<C-j>"] = "ScrollOutputDown",
				["q"] = "Close",
			},
		},
	},

	config = function(_, opts)
		local overseer = require("overseer")
		overseer.setup(opts)
		local map = vim.keymap.set

		map("n", "<leader>tt", function()
			overseer.toggle()
		end, { desc = "Task list", noremap = true, silent = true })

		map("n", "<leader>tq", function()
			overseer.close()
			vim.cmd("copen")
		end, { desc = "Task list", noremap = true, silent = true })

		map("n", "<leader>to", "<cmd>OverseerRun<cr>", { desc = "Run task", noremap = true, silent = true })
		-- map(
		-- 	"n",
		-- 	"<leader>tq",
		-- 	"<cmd>OverseerQuickAction<cr>",
		-- 	{ desc = "Action recent", noremap = true, silent = true }
		-- )
		map("n", "<leader>ti", "<cmd>OverseerInfo<cr>", { desc = "Overseer Info", noremap = true, silent = true })
		map("n", "<leader>tb", "<cmd>OverseerBuild<cr>", { desc = "Task builder", noremap = true, silent = true })
		-- map("n", "<leader>tt", "<cmd>OverseerTaskAction<cr>", { desc = "Task action", noremap = true, silent = true })
		map("n", "<leader>tc", "<cmd>OverseerClearCache<cr>", { desc = "Clear cache", noremap = true, silent = true })
	end,
}
