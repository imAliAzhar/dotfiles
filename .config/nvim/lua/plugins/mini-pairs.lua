return {
	"echasnovski/mini.pairs",
	event = "InsertEnter",
	opts = {
		mappings = {
			-- do not auto create a pair when in front of word chars
			["("] = { action = "open", pair = "()", neigh_pattern = "[^\\][^%w]" },
			["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\][^%w]" },
			["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\][^%w]" },
			-- do not swallow closing brackets when after a space chars
			[")"] = { action = "close", pair = "()", neigh_pattern = "[^\\%s]." },
			["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\%s]." },
			["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\%s]." },
			-- we use the default close actions
			['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^\\][%s%)%]}]", register = { cr = false } },
			["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a\\][%s%)%]}]", register = { cr = false } },
			["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\][%s%)%]}]", register = { cr = false } },
		},
	},
}
