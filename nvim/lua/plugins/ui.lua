return {
	-- Colorscheme
	{ 
		"catppuccin/nvim", 
		name = "catppuccin", 
		priority = 1000,
		config = function()
			-- Set default colorscheme when running as root
			if vim.fn.getenv("USER") == "root" then
				vim.cmd("colorscheme catppuccin-mocha")  -- or catppuccin-latte
			end
		end,
	},
	-- Auto dark mode (only when not running as root)
	{
		"f-person/auto-dark-mode.nvim",
		cond = function()
			return vim.fn.getenv("USER") ~= "root"
		end,
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
