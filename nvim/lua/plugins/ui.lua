return {
	-- Colorscheme
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },

	-- Auto dark mode
	{
		"f-person/auto-dark-mode.nvim",
		opts = {
			set_dark_mode = function()
				vim.cmd("colorscheme catppuccin-mocha")
			end,
			set_light_mode = function()
				vim.cmd("colorscheme catppuccin-latte")
			end,
			update_interval = 1000,
		},
	},
}
