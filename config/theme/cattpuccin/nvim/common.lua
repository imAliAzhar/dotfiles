vim.cmd.colorscheme("catppuccin-" .. colorscheme)

-- https://github.com/neovim/neovim/issues/31675
vim.hl = vim.highlight

vim.cmd.highlight("DiagnosticUnderlineError gui=undercurl")
vim.cmd.highlight("DiagnosticUnderlineWarn gui=undercurl")
vim.cmd.highlight("DiagnosticUnderlineHint gui=undercurl")
vim.cmd.highlight("DiagnosticUnderlineInfo gui=undercurl")
vim.cmd.highlight("CursorLine guibg=" .. cursorline)

-- TS/JS color overrides
vim.api.nvim_set_hl(0, "@custom.imports", { fg = palette.text })
vim.api.nvim_set_hl(0, "@custom.type", { fg = palette.mauve })
vim.api.nvim_set_hl(0, "@keyword.export", { fg = palette.lavendar })

local is_transparent = true
