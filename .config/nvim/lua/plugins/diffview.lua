return {
	"sindrets/diffview.nvim",
	config = function()
		local actions = require("diffview.actions")
		local gitsigns = require("gitsigns")

		actions.x_select_entry = function()
			actions.select_next_entry()
			-- actions.toggle_files()
		end

		actions.x_quit = function()
			vim.cmd("DiffviewClose")
		end

		require("diffview").setup({
			use_icons = false,
			signs = {
				fold_closed = " ",
				fold_open = " ",
				done = "✓ ",
			},
			default = {
				winbar_info = true, -- See |diffview-config-view.x.winbar_info|
			},
			keymaps = {

				disable_defaults = false,

				view = {
					{ "n", "q", actions.x_quit, { desc = "Close diff view" } },

					{ "n", "<leader>hs", gitsigns.stage_hunk },
					{ "n", "<leader>hr", gitsigns.reset_hunk },
					{
						"v",
						"<leader>hs",
						function()
							gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
						end,
					},
					{
						"v",
						"<leader>hr",
						function()
							gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
						end,
					},
					{ "n", "<leader>hS", gitsigns.stage_buffer },
					{ "n", "<leader>hu", gitsigns.undo_stage_hunk },
					{ "n", "<leader>hp", gitsigns.preview_hunk },
				},
				file_panel = {
					{ "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
					{ "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },

					{ "n", "j", actions.select_next_entry, { desc = "Open the diff for the next file" } },
					{ "n", "k", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
					{ "n", "l", actions.x_select_entry, { desc = "Focus the diff and close file panel" } },

					{ "n", "<leader>e", actions.focus_files, { desc = "Bring focus to the file panel" } },
					{ "n", "<leader>b", actions.toggle_files, { desc = "Toggle the file panel." } },

					{ "n", "<space>", actions.toggle_stage_entry, { desc = "Stage / unstage the selected entry" } },
					{ "n", "a", actions.stage_all, { desc = "Stage all entries" } },
					{ "n", "u", actions.unstage_all, { desc = "Unstage all entries" } },
					{ "n", "r", actions.restore_entry, { desc = "Restore entry to the state on the left side" } },

					{ "n", "zo", actions.open_fold, { desc = "Expand fold" } },
					{ "n", "zc", actions.close_fold, { desc = "Collapse fold" } },
					{ "n", "za", actions.toggle_fold, { desc = "Toggle fold" } },
					{ "n", "Z", actions.open_all_folds, { desc = "Expand all folds" } },
					{ "n", "zz", actions.close_all_folds, { desc = "Collapse all folds" } },

					{ "n", "q", actions.x_quit, { desc = "Close diff view" } },
				},
			},

			file_panel = {
				listing_style = "list",
				win_config = function()
					local float = 0

					local editor_width = vim.o.columns
					local editor_height = vim.o.lines

					if float ~= 1 then
						return { position = "bottom", height = math.floor(editor_height * 0.3) }
					end

					local c = { type = "float" }
					c.width = math.min(100, editor_width)
					c.height = math.min(24, editor_height)
					c.col = math.floor(editor_width * 0.5 - c.width * 0.5)
					c.row = math.floor(editor_height * 0.5 - c.height * 0.5)
					return c
				end,
			},

			hooks = {
				view_opened = function()
					-- actions.toggle_files()
					actions.open_all_folds()
				end,
			},
		})
	end,
}
