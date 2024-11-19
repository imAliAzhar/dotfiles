function copyFilePath()
  local filepath = vim.fn.expand('%')
  vim.fn.setreg('+', filepath) -- write to clippoard
end

function copyFileName()
  local filename = vim.fn.expand('%:t') -- Get the file name only
  vim.fn.setreg('+', filename) -- Write to clipboard
end

function openExplorer()
  local filepath = vim.fn.expand('%:p')
  local command = "editor-explorer " .. filepath 
  vim.fn.system(command)
end


vim.g.mapleader = " "

vim.keymap.set({ 'n', 'i', 'v', 'c' }, '<Leader>e', openExplorer, { desc = "Open explorer" })
vim.keymap.set('n', '<leader>gf', copyFileName, { desc = "Copy current file name", noremap = true, silent = true })
vim.keymap.set('n', '<leader>gF', copyFilePath, { desc = "Copy current file path", noremap = true, silent = true })

vim.keymap.set({ 'n', 'v' }, "H", "0", { desc = "Go to beginning of line" })
vim.keymap.set({ 'n', 'v' }, "L", "$", { desc = "Go to end of line" })

vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set({ 'n', 'v' }, '<Leader>p', '"+p', { desc = "Paste from system clipboard after cursor" })
vim.keymap.set({ 'n', 'v' }, '<Leader>P', '"+P', { desc = "Paste from system clipboard before cursor" })

vim.keymap.set('n', '<CR>', 'o<Esc>', { desc = "Add new line below (normal mode)" })



