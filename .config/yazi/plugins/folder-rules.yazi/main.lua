local function setup()
	ps.sub("cd", function()
		local cwd = cx.active.current.cwd

		-- Sort files in Downloads
		if cwd:ends_with("Downloads") then
			ya.emit("sort", { "mtime", reverse = true, dir_first = false })
		end

		-- -- Hide hidden files when in home directory
		-- --- @diagnostic disable-next-line: param-type-mismatch -- $HOME will never be nil
		-- if cwd:ends_with(os.getenv("HOME")) then
		-- 	ya.emit("hidden", { "hide" })
		-- else
		-- 	ya.emit("hidden", { "show" })
		-- end
	end)
end

return { setup = setup }
