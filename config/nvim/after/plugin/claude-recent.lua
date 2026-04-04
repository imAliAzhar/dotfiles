--- Parse "filepath:line" into { path = "filepath", lnum = number|nil }
local function parse_entry(raw)
	local path, lnum = raw:match("^(.+):(%d+)$")
	if path then
		return { path = path, lnum = tonumber(lnum) }
	end
	return { path = raw, lnum = nil }
end

local function get_recent_files()
	local root = vim.fn.getcwd()
	local path = root .. "/.claude/recent-files"

	local file = io.open(path, "r")
	if not file then
		return nil
	end

	local entries = {}
	for line in file:lines() do
		line = vim.trim(line)
		if line ~= "" then
			table.insert(entries, parse_entry(line))
		end
	end
	file:close()

	if #entries == 0 then
		return nil
	end

	return entries
end

local function open_entry(entry)
	vim.cmd("edit " .. vim.fn.fnameescape(entry.path))
	if entry.lnum then
		pcall(vim.api.nvim_win_set_cursor, 0, { entry.lnum, 0 })
	end
end

-- Open the most recent file from .claude/recent-files
vim.keymap.set("n", "<leader>cc", function()
	local entries = get_recent_files()
	if not entries then
		vim.notify("No .claude/recent-files found or file is empty", vim.log.levels.WARN)
		return
	end
	open_entry(entries[#entries])
end, { desc = "Open last Claude recent file" })

-- Browse all Claude recent files in Telescope (reverse order, most recent first)
vim.keymap.set("n", "<leader>cC", function()
	local entries = get_recent_files()
	if not entries then
		vim.notify("No .claude/recent-files found or file is empty", vim.log.levels.WARN)
		return
	end

	-- Reverse so most recent is first
	local reversed = {}
	for i = #entries, 1, -1 do
		table.insert(reversed, entries[i])
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	pickers
		.new({}, {
			prompt_title = "Claude Recent Files",
			finder = finders.new_table({
				results = reversed,
				entry_maker = function(entry)
					local display = entry.path
					if entry.lnum then
						display = display .. ":" .. entry.lnum
					end
					return {
						value = entry,
						display = display,
						ordinal = entry.path,
						path = entry.path,
						lnum = entry.lnum or 1,
					}
				end,
			}),
			sorter = conf.file_sorter({}),
			previewer = conf.file_previewer({}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if selection then
						open_entry(selection.value)
					end
				end)
				return true
			end,
		})
		:find()
end, { desc = "Browse Claude recent files" })
