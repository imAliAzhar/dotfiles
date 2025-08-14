-- Use colors from Catpuccin plugin
local colors = {
	lavender = "#b4befe",
	flamingo = "#f2cdcd",
	mauve = "#cba6f7",
	maroon = "#eba0ac",
	peach = "#fab387",
	yellow = "#f9e2af",
	red = "#f38ba8",

	subtext1 = "#bac2de",
	subtext0 = "#a6adc8",
	overlay0 = "#6c7086",

	base = "#1e1e2e",
	mantle = "#181825",
	crust = "#11111b",
}

local function macro_recording_status()
	local recording_register = vim.fn.reg_recording()
	if recording_register ~= "" then
		return "recording @" .. recording_register
	end
	return ""
end

require("lualine").setup({
	options = {
		theme = {
			inactive = {
				a = { bg = colors.mantle, fg = colors.subtext0 },
				b = { bg = colors.mantle, fg = colors.overlay0 },
				c = { bg = colors.mantle, fg = colors.subtext0 },
			},

			normal = {
				a = { bg = colors.lavender, fg = colors.base, gui = "bold" },
				b = { bg = colors.crust, fg = colors.subtext1 },
				c = { bg = colors.mantle, fg = colors.subtext1 },
			},
			command = {
				a = { bg = colors.lavender, fg = colors.base, gui = "bold" },
			},
			insert = {
				a = { bg = colors.maroon, fg = colors.base, gui = "bold" },
			},
			visual = {
				a = { bg = colors.mauve, fg = colors.base, gui = "bold" },
			},
			replace = {
				a = { bg = colors.yellow, fg = colors.base, gui = "bold" },
			},
		},
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
		ignore_focus = {},
		always_divide_middle = true,
		always_show_tabline = true,
		globalstatus = false,
		refresh = {
			statusline = 100,
			tabline = 100,
			winbar = 100,
		},
	},
	sections = {
		lualine_a = {
			{
				"mode",
				padding = 2,
				fmt = function(str)
					local mode = str:sub(1, 3)
					-- Command line covers Normal mode, prevent glitch
					if mode == "COM" then
						return "NOR"
					end
					return mode
				end,
			},
		},
		lualine_b = {
			-- {
			-- 	"buffers",
			-- 	icons_enabled = false,
			-- 	symbols = {
			-- 		alternate_file = "✦",
			-- 	},
			-- },
		},
		lualine_c = {
			{
				"filename",
				file_status = true, -- Displays file status (readonly status, modified status)
				newfile_status = false, -- Display new file status (new file means no write after created)
				path = 1, -- 0: Just the filename
				-- 1: Relative path
				-- 2: Absolute path
				-- 3: Absolute path, with tilde as the home directory
				-- 4: Filename and parent dir, with tilde as the home directory

				shorting_target = 40, -- Shortens path to leave 40 spaces in the window
				-- for other components. (terrible name, any suggestions?)
				symbols = {
					modified = "●", -- Text to show when the file is modified.
					readonly = "[RO]", -- Text to show when the file is non-modifiable or readonly.
					unnamed = "[No Name]", -- Text to show for unnamed buffers.
					newfile = "[New]", -- Text to show for newly created file before first write
				},
			},
		},

		lualine_x = {
			macro_recording_status,
			"diff",
			{
				"diagnostics",
				symbols = { error = "E ", warn = "W ", info = "I ", hint = "H " },
			},
			"branch",
			"progress",
			"location",
		},
		lualine_y = {},
		lualine_z = {},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = {},
})
