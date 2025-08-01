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
	--{
	--	"akinsho/toggleterm.nvim",
	--	version = "*",
	--	config = function()
	--		require("toggleterm").setup({
	--			open_mapping = [[<C-\>]],
	--			direction = "horizontal",
	--			on_open = function(term)
	--				vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<C-\\><C-n>", { noremap = true })
	--			end,
	--		})
	--	end,
	--},

	--{
	--	"nvzone/floaterm",
	--	dependencies = "nvzone/volt",
	--	opts = {},
	--	cmd = "FloatermToggle",
	--	config = function() end,
	--},
	{
		"CRAG666/betterTerm.nvim",
		keys = {
			{
				mode = { "n", "t" },
				"<C-\\>",
				function()
					require("betterTerm").open()
				end,
				desc = "Open BetterTerm 0",
			},
			{
				"<leader>tt",
				function()
					require("betterTerm").select()
				end,
				desc = "Select terminal",
			},
		},
		opts = {
			position = "bot",
			size = 15,
			index_base = 1,
			--jump_tab_mapping = "<A-$tab>",
		},
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

	--{
	--	"ravitemer/mcphub.nvim",
	--	dependencies = {
	--		"nvim-lua/plenary.nvim",
	--	},
	--	build = "npm install -g mcp-hub@latest",
	--	config = function()
	--		require("mcphub").setup({
	--			config = vim.fn.expand("~/.config/mcphub/servers.json"), -- Absolute path to MCP Servers config file (will create if not exists)
	--			port = 37373, -- The port `mcp-hub` server listens to
	--		})
	--	end,
	--},

	-- AI Assistant
	--{
	--	"olimorris/codecompanion.nvim",
	--	dependencies = {
	--		"nvim-lua/plenary.nvim",
	--		"nvim-treesitter/nvim-treesitter",
	--		"hrsh7th/nvim-cmp",
	--		"github/copilot.vim", -- for copilot integration
	--		"ravitemer/codecompanion-history.nvim",
	--		--"ravitemer/mcphub.nvim",
	--	},
	--	config = function()
	--		-- Disable Copilot autocompletion while keeping API available
	--		vim.g.copilot_enabled = 0

	--		require("codecompanion").setup({
	--			strategies = {
	--				chat = {
	--					roles = {
	--						llm = function(adapter)
	--							return adapter.model.name
	--						end,
	--						user = "Ahmed",
	--					},
	--				},
	--			},

	--			cmp = {
	--				enabled = true,
	--			},
	--			display = {
	--				chat = {
	--					window = {
	--						layout = "vertical",
	--						width = 0.25,
	--					},
	--					auto_scroll = false,
	--					intro_message = "What are your commands?",
	--				},
	--			},
	--			adapters = {
	--				copilot = function()
	--					return require("codecompanion.adapters").extend("copilot", {
	--						schema = {
	--							model = {
	--								default = "claude-3.7-sonnet-thought",
	--							},
	--						},
	--					})
	--				end,
	--			},
	--			extensions = {
	--				history = {
	--					enabled = true,
	--					opts = {
	--						continue_last_chat = false,
	--						delete_on_clearing_chat = false,
	--						-- Add this callback to reset cmp after opening historical chat
	--						on_open_history = function()
	--							vim.schedule(function()
	--								require("cmp").reset()
	--							end)
	--						end,
	--					},
	--				},
	--				--mcphub = {
	--				--	callback = "mcphub.extensions.codecompanion",
	--				--	opts = {
	--				--		-- MCP Tools
	--				--		make_tools = true, -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
	--				--		show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
	--				--		add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
	--				--		show_result_in_chat = true, -- Show tool results directly in chat buffer
	--				--		format_tool = nil, -- function(tool_name:string, tool: CodeCompanion.Agent.Tool) : string Function to format tool names to show in the chat buffer
	--				--		-- MCP Resources
	--				--		make_vars = true, -- Convert MCP resources to #variables for prompts
	--				--		-- MCP Prompts
	--				--		make_slash_commands = true, -- Add MCP prompts as /slash commands
	--				--	},
	--				--},
	--			},
	--		})
	--	end,
	--},
	{
		"yetone/avante.nvim",
		build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
			or "make",
		event = "VeryLazy",
		version = false,
		opts = {
			provider = "copilot",
			selector = {
				provider = "telescope",
				-- Exclude Oil from auto-selection
				exclude_auto_select = { "oil" },
			},
			windows = {
				edit = {
					start_insert = false,
				},
				ask = {
					start_insert = false,
				},
				input = {
					height = 13,
				},
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
			"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
			"zbirenbaum/copilot.lua", -- for providers='copilot'
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
	},

	-- Debugging
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			-- Basic nvim-dap setup
			local dap = require("dap")
			local dapui = require("dapui")

			-- only close on _successful_ termination, not errors
			--dap.listeners.after.event_terminated["dapui_config"] = function()
			--		dapui.close()
			--	end

			-- don’t auto‐close on errors
			-- dap.listeners.before.event_exited["dapui_config"] = nil

			-- Initialize dap-ui
			dapui.setup()

			-- Automatically open and close dapui when debugging starts and ends
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			--dap.listeners.before.event_terminated["dapui_config"] = function()
			--	dapui.close()
			--end
			--dap.listeners.before.event_exited["dapui_config"] = function()
			--	dapui.close()
			--end

			-- Set up keymappings for debugging
			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
			vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Start/Continue Debuging" })
			vim.keymap.set("n", "<C-l>", dap.step_over, { desc = "Step Over" })
			vim.keymap.set("n", "<C-j>", dap.step_into, { desc = "Step Into" })
			vim.keymap.set("n", "<C-k>", dap.step_out, { desc = "Step Out" })
			vim.keymap.set("n", "<leader>dr", function()
				dap.repl.open()
			end, { desc = "Open REPL" })

			-- Add UI toggle
			vim.keymap.set("n", "<leader>du", function()
				dapui.toggle({ reset = true })
			end, { desc = "Toggle Debug UI" })

			-- Terminate debugging
			vim.keymap.set("n", "<leader>dT", function()
				dap.terminate()
				dapui.close()
			end, { desc = "Terminate Debugging" })
		end,
	},

	-- Plugin for giving me hints for my neovim keybindings
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			delay = 2000,
			-- your configuration comes here
			-- or leave it empty to use the default settings
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
	},

	-- GitHub in Neovim plugin
	{
		"pwntester/octo.nvim",
		--dir = "/Users/ahsiddiqui/Desktop/workspace/projects/personal/octo.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("octo").setup({
				--use_local_fs = true,
			})
			-- Create keymap to view PR file in a new tab
			vim.keymap.set("n", "<localleader>pe", function()
				-- capture both side and path
				local ok, side, path = pcall(require("octo.utils").get_split_and_path, vim.api.nvim_get_current_buf())
				if not ok or not path then
					vim.notify("Octo: no PR file under cursor", vim.log.levels.ERROR)
					return
				end

				-- open the reviewed file in a new tab
				vim.cmd("tabedit " .. path)

				-- now that we're in the file buffer, allow edits
				-- (unset readonly if present, and turn modifiable on)
				vim.api.nvim_buf_set_option(0, "readonly", false)
				vim.api.nvim_buf_set_option(0, "modifiable", true)
			end, {
				desc = "Octo: open reviewed file in new tab (and allow edits)",
				silent = true,
			})
		end,
	},

	-- Debug Lua plugins with DAP
	-- TODO: maybe move this to a separate lang/lua.lua file?
	{
		"jbyuki/one-small-step-for-vimkind",
		dependencies = { "mfussenegger/nvim-dap" },
		config = function()
			local dap = require("dap")
			-- Define the adapter
			dap.adapters.nlua = function(callback, config)
				callback({
					type = "server",
					host = config.host or "127.0.0.1",
					port = config.port or 8086,
				})
			end

			-- Define how to attach/launch Lua debug sessions
			dap.configurations.lua = {
				{
					-- To debug a standalone Lua file:
					name = "Launch file",
					type = "nlua",
					request = "launch",
					program = "${file}",
				},
				{
					-- To attach to a running Neovim instance
					name = "Attach to Neovim",
					type = "nlua",
					request = "attach",
					host = "127.0.0.1",
					port = 8086,
				},
			}

			-- helper command to start the debug server
			vim.api.nvim_create_user_command("LuaDebugStart", function()
				require("osv").launch({ port = 8086 })
			end, { desc = "Start Lua DAP server on port 8086" })

			-- helper command to stop the debug server
			vim.api.nvim_create_user_command("LuaDebugStop", function()
				require("osv").stop()
			end, { desc = "Start Lua DAP server on port 8086" })
		end,
	},
}
