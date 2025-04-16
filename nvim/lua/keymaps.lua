-- Key mappings

local function map(mode, lhs, rhs, opts)
  local options = {noremap = true, silent = true}
  if opts then options = vim.tbl_extend("force", options, opts) end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Map <leader>/ to clear search highlights
vim.keymap.set("n", "<leader>/", ":nohlsearch<CR>", { desc = "Clear search highlight" })

-- Clipboard operations with OSCYank
map("v", "<leader>c", "<Plug>OSCYankVisual", {noremap = false, desc = "Copy selection to clipboard"})

-- File explorer
map("n", "<leader>ee", ":Oil<CR>", {desc = "Open file explorer"})

-- Quickfix navigation
map("n", "<M-n>", ":cnext<CR>", {desc = "Next quickfix item"})
map("n", "<M-p>", ":cprevious<CR>", {desc = "Previous quickfix item"})

-- LSP navigation
map("n", "gr", function() vim.lsp.buf.references() end, {desc = "Find references"})
map("n", "gd", function() vim.lsp.buf.definition() end, {desc = "Go to definition"})
map("n", "K", function() vim.lsp.buf.hover() end, {desc = "Show hover information"})

-- Fuzzy finding
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files (Telescope)' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep (Telescope)' })

-- Workspaces
vim.keymap.set("n", "<leader>wp", function()
  require("telescope").extensions.workspaces.workspaces()
end, { desc = "Switch Project" })
