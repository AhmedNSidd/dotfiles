return {
	-- 1) VimTeX for editing & building
	{
		"lervag/vimtex",
		ft = { "tex", "bib" },
		config = function()
			vim.g.vimtex_compiler_method = "latexmk"
			vim.g.vimtex_view_method = "skim" -- or skim, evince, etc.
			vim.g.vimtex_quickfix_mode = 0
		end,
	},

	-- Add cmp-vimtex for better LaTeX completions
	{
		"micangl/cmp-vimtex",
		ft = { "tex" },
		dependencies = { "hrsh7th/nvim-cmp", "lervag/vimtex" },
		config = function()
			require("cmp_vimtex").setup()
		end,
	},
}
