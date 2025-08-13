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
vim.keymap.set("n", "<C-`>", ":AvanteToggle<CR>", { desc = "Toggle Avante chat" })

-- Copy selected text
vim.keymap.set("v", "<leader>c", "<Plug>OSCYankVisual", { noremap = false, desc = "Copy selection to clipboard" })

-- Terminal-mode mapping: press <C-[> in terminal to enter Terminal-Normal mode
vim.api.nvim_set_keymap("t", "<C-[>", "<C-\\><C-n>", { noremap = true })

-- Global diagnostic keymaps (work for both LSP and none-ls diagnostics)
vim.keymap.set("n", "<leader>x", vim.diagnostic.open_float, { desc = "Show diagnostics" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
