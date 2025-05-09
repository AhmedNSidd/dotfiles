local M = {}

-- Define a common `on_attach` function for keymaps & formatting
M.on_attach = function(client, bufnr)
	local bufmap = function(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
	end

	bufmap("n", "gd", vim.lsp.buf.definition, "Go to Definition")
	bufmap("n", "K", vim.lsp.buf.hover, "Hover Documentation")
	bufmap("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
	bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
	bufmap("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
	bufmap("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
	bufmap("n", "<leader>x", vim.diagnostic.open_float, "Show diagnostics")

	local diag_enabled = true
	function _G.toggle_diagnostic_signs()
		diag_enabled = not diag_enabled
		vim.diagnostic.config({ signs = diag_enabled })
	end
	vim.keymap.set("n", "<leader>td", _G.toggle_diagnostic_signs, { desc = "Toggle LSP diagnostic signs" })
end

return M
