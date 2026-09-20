-- Treesitter — accurate syntax highlighting, indentation, and text objects
-- based on a real parse tree instead of the legacy regex engine.
return {
	{
		"nvim-treesitter/nvim-treesitter",
		-- Pin the stable classic branch. Upstream's default is now the `main`
		-- rewrite, which drops this declarative setup API (ensure_installed /
		-- highlight / indent) and needs manual per-filetype wiring. `master` is
		-- fully supported and "just works" with the config below.
		branch = "master",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		-- lazy.nvim calls require("nvim-treesitter.configs").setup(opts)
		main = "nvim-treesitter.configs",
		opts = {
			-- Parsers for the languages this config already supports.
			ensure_installed = {
				"lua",
				"vim",
				"vimdoc",
				"bash",
				"python",
				"go",
				"gomod",
				"gowork",
				"java",
				"scala",
				"javascript",
				"typescript",
				"tsx",
				-- NOTE: latex/bibtex parsers are intentionally omitted — they require
				-- the external tree-sitter CLI to build, and VimTeX already provides
				-- .tex highlighting. Add them only if you install `tree-sitter-cli`.
				"json",
				"yaml",
				"markdown",
				"markdown_inline",
				"gitcommit",
				"diff",
			},
			auto_install = true,
			highlight = {
				enable = true,
				-- Neovim ships a column-aware regex syntax for CSV/TSV
				-- (runtime/syntax/csv.vim) that rainbow-colors each column.
				-- The tree-sitter-csv grammar is far more minimal (string/
				-- number/delimiter only) and, since a TS highlighter suppresses
				-- the regex :syntax engine, enabling it here makes CSV look
				-- worse. Skip these filetypes so the built-in syntax wins.
				disable = { "csv", "tsv" },
			},
			indent = { enable = true },
		},
	},
}
