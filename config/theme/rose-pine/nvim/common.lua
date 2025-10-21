local palette = require("rose-pine.palette")

vim.cmd.highlight("CursorLine guibg=" .. cursorline)

local LspInlayHint = vim.api.nvim_get_hl(0, { name = "LspInlayHint" })
vim.api.nvim_set_hl(0, "LspInlayHint", { fg = LspInlayHint.fg, bg = "NONE" })

-- TS/JS color overrides
vim.api.nvim_set_hl(0, "@custom.type", { fg = palette.pine })
vim.api.nvim_set_hl(0, "@custom.accessibility_modifier", { fg = palette.pine })
vim.api.nvim_set_hl(0, "@custom.interface_declaration", { fg = palette.pine })
