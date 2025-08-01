return {
	-- Plugin for Golang
	{
		"fatih/vim-go",
		ft = { "go", "gomod" },
		init = function()
			-- Disable vim-go's formatting features in favor of LSP
			vim.g.go_fmt_autosave = 1
			vim.g.go_fmt_command = "golines"
			vim.g.go_fmt_options = "--shorten-comments"
			vim.g.go_gopls_enabled = 1 -- Disable gopls in vim-go as we're using lspconfig
			vim.g.go_imports_autosave = 0 -- Disable auto imports
			vim.g.go_mod_fmt_autosave = 0 -- Disable go.mod formatting
			vim.g.go_doc_keywordprg_enabled = 0 -- Disable K for GoDoc

			-- Set terminal testing options
			vim.g.go_term_enabled = 1 -- Run the tests in a separate terminal window
			vim.g.go_term_reuse = 1 -- Reuse the same terminal window for any new tests that run
			--vim.g.go_term_mode = "split" -- Open the terminal window in a horizontal split
			vim.g.go_term_width = 80 -- Resize terminal width

			-- Set testing options
			vim.g.go_test_show_name = 1

			-- Disable default mappings to avoid conflicts
			vim.g.go_def_mapping_enabled = 0

			-- Coverage keybinding
			vim.keymap.set("n", "<leader>gc", "<cmd>GoCoverage<CR>", { silent = true, desc = "Show Go test coverage" })
			vim.keymap.set("n", "<leader>gct", "<cmd>GoCoverageToggle<CR>", { silent = true, desc = "Show Go test coverage" })
		end,
	},
}
