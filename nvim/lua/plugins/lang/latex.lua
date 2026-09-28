return {
	-- 1) VimTeX for editing & building
	{
		"lervag/vimtex",
		ft = { "tex", "bib" },
		init = function()
			-- Set globals BEFORE the plugin/ftplugin loads.
			vim.g.vimtex_compiler_method = "latexmk"
			vim.g.vimtex_view_method = "skim" -- or skim, evince, etc.
			vim.g.vimtex_quickfix_mode = 0
			-- VimTeX HEAD requires nvim 0.12.4+; we're on 0.11.6 and its
			-- compile/view path works fine, so skip the version gate.
			-- Remove this once Neovim is upgraded to >= 0.12.4.
			vim.g.vimtex_version_check = 0
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
