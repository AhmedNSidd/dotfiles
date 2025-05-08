-- ===================================================================
-- Keymaps
-- ===================================================================

-- File explorer
vim.keymap.set("n", "<leader>ee", ":Oil<CR>", { desc = "Open file explorer" })

-- Clear search highlights
vim.keymap.set("n", "<leader>/", ":nohlsearch<CR>", { desc = "Clear search highlight" })

-- Switch projects
vim.keymap.set("n", "<leader>wp", function()
	require("telescope").extensions.workspaces.workspaces()
end, { desc = "Switch project" })

-- Toggle CodeCompanion chat window
vim.keymap.set("n", "<leader>cc", ":CodeCompanionChat Toggle<CR>", { desc = "Toggle CodeCompanion chat" })

-- Copy selected text
vim.keymap.set("v", "<leader>c", "<Plug>OSCYankVisual", { noremap = false, desc = "Copy selection to clipboard" })
