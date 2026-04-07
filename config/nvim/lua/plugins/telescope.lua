local function configure_theme()
	local colors = require("catppuccin.palettes").get_palette()

	local TelescopeColor = {
		TelescopeMatching = { fg = colors.flamingo },
		TelescopeSelection = { fg = colors.text, bg = colors.surface0, bold = true },

		TelescopePromptPrefix = { bg = colors.surface0 },
		TelescopePromptNormal = { bg = colors.surface0 },
		TelescopeResultsNormal = { bg = colors.mantle },
		TelescopePreviewNormal = { bg = colors.mantle },
		TelescopePromptBorder = { bg = colors.surface0, fg = colors.surface0 },
		TelescopeResultsBorder = { bg = colors.mantle, fg = colors.mantle },
		TelescopePreviewBorder = { bg = colors.mantle, fg = colors.mantle },
		TelescopePromptTitle = { bg = colors.surface0, fg = colors.surface0 },
		TelescopeResultsTitle = { fg = colors.mantle },
		TelescopePreviewTitle = { bg = colors.mantle, fg = colors.mantle },
	}

	for hl, col in pairs(TelescopeColor) do
		vim.api.nvim_set_hl(0, hl, col)
	end
end

local function focus_preview(prompt_bufnr)
	local action_state = require("telescope.actions.state")
	local picker = action_state.get_current_picker(prompt_bufnr)
	local prompt_win = picker.prompt_win
	local previewer = picker.previewer
	local bufnr = previewer.state.bufnr or previewer.state.termopen_bufnr
	local winid = previewer.state.winid or vim.fn.win_findbuf(bufnr)[1]
	vim.keymap.set("n", "<Tab>", function()
		vim.cmd(string.format("noautocmd lua vim.api.nvim_set_current_win(%s)", prompt_win))
	end, { buffer = bufnr })
	vim.cmd(string.format("noautocmd lua vim.api.nvim_set_current_win(%s)", winid))
end

return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",

	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"danielfalk/smart-open.nvim",
			branch = "0.2.x",
		},
		"debugloop/telescope-undo.nvim",
		{
			"axkirillov/hbac.nvim",
			config = {
				threshold = 7,
			},
		},
		"kkharji/sqlite.lua",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},

	config = function()
		local telescope = require("telescope")

		local actions = require("telescope.actions")

		local themes = require("telescope.themes")

		telescope.setup({
			extensions = {
				smart_open = {
					mappings = {
						n = {
							["x"] = require("smart-open.actions").delete_buffer,
						},
					},
				},
			},
			defaults = themes.get_ivy({
				initial_mode = "insert",
				disable_devicons = true,
				mappings = {
					i = {
						[" <c-f>"] = "close",
						-- ["<esc>"] = "close",
						["<Tab>"] = focus_preview,
						-- ["<C-f>"] = layout_actions.toggle_preview,
					},
					n = {
						[" <c-f>"] = "close",
						["<esc>"] = "close",
						[";"] = "select_default",
						["l"] = "select_default",
						["q"] = "close",
						["<Tab>"] = focus_preview,
						-- ["<C-f>"] = layout_actions.toggle_preview,
						-- ["<C-f>"] = "select_default",
					},
				},
				-- layout_strategy = "vertical",
				-- sorting_strategy = "ascending",
				-- layout_config = {
				-- 	vertical = {
				-- 		preview_cutoff = 0,
				-- 	},
				-- 	height = vim.o.lines,
				-- 	width = vim.o.columns,
				-- 	prompt_position = "top",
				-- 	-- preview_height = 0.6,
				-- },
			}),
			pickers = {
				live_grep = {
					mappings = {
						i = {
							["<c-o>"] = actions.send_to_qflist + actions.open_qflist,
						},
					},
				},
				quickfixhistory = {
					attach_mappings = function(prompt_bufnr, map)
						local action_state = require("telescope.actions.state")
						actions.select_default:replace(function()
							local selection = action_state.get_selected_entry()
							actions.close(prompt_bufnr)
							if selection then
								vim.cmd("silent " .. selection.nr .. "chistory")
								vim.cmd("copen")
							end
						end)
						return true
					end,
				},
			},
		})

		telescope.load_extension("smart_open")
		telescope.load_extension("undo")
		telescope.load_extension("hbac")

		local builtin = require("telescope.builtin")
		local extensions = telescope.extensions

		vim.keymap.set("n", "<leader><leader>f", function()
			extensions.smart_open.smart_open({ disable_devicons = true, initial_mode = "insert", cwd_only = true })
		end)
		vim.keymap.set("n", "<leader>f", builtin.live_grep)
		vim.keymap.set("n", "<leader>bb", builtin.buffers)
		vim.keymap.set("n", "<leader>bo", builtin.oldfiles)
		vim.keymap.set("n", "<leader>fh", builtin.help_tags)
		vim.keymap.set("n", "<leader>gl", builtin.git_status)
		vim.keymap.set("n", "<leader>gb", builtin.git_branches)
		vim.keymap.set("n", "<leader>gr", builtin.grep_string)
		vim.keymap.set("n", "<leader>u", extensions.undo.undo)

		local get_selection = function()
			return vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { mode = vim.fn.mode() })
		end

		vim.keymap.set("v", "<leader>f", function()
			require("telescope.builtin").live_grep({
				default_text = table.concat(get_selection()),
			})
		end)

		-- local recent_picker = function()
		-- 	extensions.smart_open.smart_open({
		-- 		cwd_only = true,
		-- 		initial_mode = "normal",
		-- 		disable_devicons = true,
		-- 		previewer = false,
		-- 		layout_config = {
		-- 			height = 0.5,
		-- 			anchor = "SE",
		-- 			prompt_position = "bottom",
		-- 			width = 0.3,
		-- 		},
		-- 	})
		-- end

		local make_entry = require("telescope.make_entry")
		local Path = require("plenary.path")
		local utils = require("telescope.utils")
		local action_state = require("telescope.actions.state")

		local recent_picker = function()
			builtin.buffers({
				cwd_only = true,
				sort_lastused = true,
				ignore_current_buffer = false,
				initial_mode = "normal",
				disable_devicons = true,
				previewer = false,
				path_display = { filename_first = { reverse_directories = false } },
				attach_mappings = function(prompt_bufnr, map)
					local delete_buf = function()
						local current_picker = action_state.get_current_picker(prompt_bufnr)
						current_picker:delete_selection(function(selection)
							vim.api.nvim_buf_delete(selection.bufnr, { force = true })
						end)
					end

					map("n", "<c-d>", delete_buf)
					map("i", "<c-d>", delete_buf)

					return true
				end,

				entry_maker = function(entry)
					local filename = entry.info.name ~= "" and entry.info.name or nil
					local bufname = filename and Path:new(filename):normalize(cwd) or "[No Name]"

					-- Check if buffer has unsaved changes
					local is_modified = vim.api.nvim_buf_get_option(entry.bufnr, "modified")
					local modified_indicator = is_modified and "• " or "  "
					local padding = is_modified and "4" or "2"

					return make_entry.set_default_entry_mt({
						value = bufname,
						ordinal = entry.bufnr .. " : " .. bufname,
						display = function()
							local tail = utils.path_tail(bufname)
							local display_text = string.format("%s%s  %s", modified_indicator, tail, bufname)

							-- Highlight groups: modified indicator + filename
							local highlights = {}

							table.insert(highlights, { { 0, #tail + padding }, "Constant" }) -- Filename

							return display_text, highlights
						end,
						bufnr = entry.bufnr,
						path = filename,
						filename = bufname,
					})
				end,

				layout_config = {
					height = 0.5,
					anchor = "N",
					prompt_position = "top",
					-- width = 0.4,
				},
			})
		end

		-- vim.keymap.set("n", ";", recent_picker)

		configure_theme()
	end,
}
