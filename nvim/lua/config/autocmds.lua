-- ===================================================================
-- Autocommands
-- ===================================================================

-- Create a personal CodeCompanion autocommand grouping that clears the
-- <C-c> mapping for the CodeCompanionChat window, preventing <C-c> from
-- closing the window.
vim.api.nvim_create_augroup("UserCodeCompanionSettings", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = "UserCodeCompanionSettings",
	pattern = "codecompanion",
	desc = "Disable CodeCompanion's <C-c> close mapping",
	callback = function(args)
		-- schedule on the next tick to let the plugin apply its mappings first
		vim.schedule(function()
			local buf = args.buf
			-- Delete <C-c> plugin mapping in normal & insert mode
			pcall(vim.api.nvim_buf_del_keymap, buf, "n", "<C-c>")
			pcall(vim.api.nvim_buf_del_keymap, buf, "i", "<C-c>")

			-- Remap <C-c> in insert mode to go back to normal mode
			vim.keymap.set("i", "<C-c>", "<Esc>", {
				buffer = buf,
				noremap = true,
				silent = true,
				desc = "User override: exit insert",
			})
		end)
	end,
})
