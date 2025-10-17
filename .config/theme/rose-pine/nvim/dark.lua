vim.cmd("colorscheme rose-pine-moon")

local palette = require("rose-pine.palette")

vim.api.nvim_set_hl(0, "@custom.imports", { fg = palette.text })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = palette.rose })
local cursorline = "#1f1d2e"
local is_transparent = true
