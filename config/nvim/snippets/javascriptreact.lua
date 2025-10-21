local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
	s(
		"ue",
		fmt(
			[[
useEffect(() => {{
  {}
}}, [{}]);
]],
			{
				i(1, "// effect"),
				i(2, ""),
			}
		)
	),

	s(
		"uec",
		fmt(
			[[
useEffect(() => {{
  {}
  return () => {{
    {}
  }};
}}, [{}]);
]],
			{
				i(1, "// effect"),
				i(2, "// cleanup"),
				i(3, ""),
			}
		)
	),
}
