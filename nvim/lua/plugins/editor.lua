return {
	-- Oil File Explorer (replacement for netrw)
	{
		"stevearc/oil.nvim",
		dependencies = { "echasnovski/mini.icons" },
		config = function()
			require("oil").setup({
				default_file_explorer = true,
				view_options = { show_hidden = true },
				delete_to_trash = true,
			})

			-- Add keymapping to synchronize tab working directory to current Oil directory
			vim.keymap.set("n", "<leader>cd", function()
				-- ask Oil for the directory it’s currently showing
				local dir = require("oil").get_current_dir(0)
				if not dir or dir == "" then
					vim.notify("⚠️  Not in an Oil buffer", vim.log.levels.WARN)
					return
				end
				-- change Neovim's cwd to that path
				vim.cmd("tcd " .. vim.fn.fnameescape(dir))
				vim.notify("✓ Synced tab to current directory: " .. dir, vim.log.levels.INFO)
			end, { desc = "Oil.nvim: sync current tab working directory to current Oil directory" })
		end,
		lazy = false,
	},

	-- Fuzzy finder
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").setup({
				pickers = {
					find_files = {
						find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
					},
				},
			})
			-- Load the builtin pickers
			local builtin = require("telescope.builtin")

			-- Set keybindings
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files (Telescope)" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep (Telescope)" })
		end,
	},

	-- Workspaces
	{
		"natecraddock/workspaces.nvim",
		dependencies = { "stevearc/oil.nvim", "nvim-telescope/telescope.nvim" },
		config = function()
			require("workspaces").setup({
				hooks = {
					open = {
						function(name, path)
							require("oil").open(path)
						end,
					},
				},
				sort = true,
				mru_sort = true,
				cd_type = "tab",
			})
			require("telescope").load_extension("workspaces")
		end,
	},

	-- Plugin for automatically detecting what indents should be used in the current buffer
	{
		"tpope/vim-sleuth",
	},

	-- Plugin for toggling a terminal window
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				open_mapping = [[<C-\>]],
				direction = "float",
				on_open = function(term)
					vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<C-\\><C-n>", { noremap = true })
				end,
			})
		end,
	},

	-- Plugin for comparing diffs for two parts of the same file
	{ "AndrewRadev/linediff.vim" },

	-- Plugin for copying from remote servers
	{ "ojroques/vim-oscyank" },

	-- Plugin for in-line git diff indicators
	{
		"lewis6991/gitsigns.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("gitsigns").setup({
				-- keymaps: navigate hunks, stage/reset, preview, blame, etc.
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns
					local function map(mode, l, r, opts)
						opts = opts or { buffer = bufnr }
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map("n", "]h", gs.next_hunk, { desc = "Next Git hunk" })
					map("n", "[h", gs.prev_hunk, { desc = "Prev Git hunk" })
					-- Actions
					--map("n", "<leader>ghs", gs.stage_hunk, { desc = "Stage hunk" })
					--map("n", "<leader>ghr", gs.reset_hunk, { desc = "Reset hunk" })
					--map("v", "<leader>ghs", function()
					--	gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					--end)
					--map("v", "<leader>ghr", function()
					--	gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					--end)
					---- Preview & blame
					--map("n", "<leader>ghp", gs.preview_hunk, { desc = "Preview hunk" })
					--map("n", "<leader>ghb", function()
					--	gs.blame_line({ full = true })
					--end, { desc = "Blame line" })
					--map("n", "<leader>ghd", gs.diffthis, { desc = "Diff against index" })
				end,
			})
		end,
	},

	-- Plugin for Git integration
	{
		"tpope/vim-fugitive",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			-- Optional: Add keymaps for common git operations
			--vim.keymap.set("n", "<leader>gs", ":Git<CR>", { desc = "Git status" })
			--vim.keymap.set("n", "<leader>gb", ":Git blame<CR>", { desc = "Git blame" })
			--vim.keymap.set("n", "<leader>gd", ":Git diff<CR>", { desc = "Git diff" })
			--vim.keymap.set("n", "<leader>gl", ":Git log<CR>", { desc = "Git log" })
		end,
	},

	-- AI Assistant
	{
		"olimorris/codecompanion.nvim",
		opts = {},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"hrsh7th/nvim-cmp",
		},
		config = function()
			require("codecompanion").setup({
				cmp = {
					enabled = true,
				},
				display = {
					chat = {
						window = {
							layout = "float",
							width = 0.85,
						},
					},
				},
				adapters = {
					copilot = function()
						return require("codecompanion.adapters").extend("copilot", {
							schema = {
								model = {
									default = "o4-mini",
								},
							},
						})
					end,
				},
			})
		end,
	},
}
