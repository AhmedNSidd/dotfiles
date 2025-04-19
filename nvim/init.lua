-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key to space
vim.g.mapleader = " "

-- ===================================================================
-- Keymaps
-- ===================================================================

-- File explorer
vim.keymap.set("n", "<leader>ee", ":Oil<CR>", { desc = "Open file explorer" })

-- Clear search highlights
vim.keymap.set("n", "<leader>/", ":nohlsearch<CR>", { desc = "Clear search highlight" })

-- Switch projects
vim.keymap.set("n", "<leader>wp", function()
	require("telescope").extensions.workspaces.workspaces()
end, { desc = "Switch project" })

-- Toggle CodeCompanion chat window
vim.keymap.set("n", "<leader>cc", ":CodeCompanionChat Toggle<CR>", { desc = "Toggle CodeCompanion chat" })

-- Copy selected text
vim.keymap.set("v", "<leader>c", "<Plug>OSCYankVisual", { noremap = false, desc = "Copy selection to clipboard" })

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

-- ===================================================================
-- Other Options
-- ===================================================================

-- Open vertical splits on the right
vim.opt.splitright = true

-- ===================================================================
-- Plugins
-- ===================================================================

require("lazy").setup({
	spec = {
		-- Colorscheme
		{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },

		-- Plugin for automatically changing colorschemes for dark mode
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

		-- Oil File Explorer (replacement for netrw)
		{
			"stevearc/oil.nvim",
			dependencies = { "echasnovski/mini.icons" },
			opts = {
				default_file_explorer = true,
				view_options = { show_hidden = true },
				delete_to_trash = true,
			},
			lazy = false,
		},

		-- Fuzzy finder
		{
			"nvim-telescope/telescope.nvim",
			branch = "0.1.x",
			dependencies = { "nvim-lua/plenary.nvim" },
			config = function()
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

		-- Plugin for install and managing external tools (e.g. LSP servers)
		{
			"williamboman/mason.nvim",
			opts = {},
			cmd = "Mason",
		},

		-- Plugin to bridge tools installed via Mason with nvim-lspconfig
		{
			"williamboman/mason-lspconfig.nvim",
			dependencies = { "mason.nvim", "nvim-lspconfig" },
			opts = {},
		},

		-- Neovim's built-in LSP client
		-- Used to handle diagnostics, go-to-definitions, hover, etc, but not formatting
		{
			"neovim/nvim-lspconfig",
			event = { "BufReadPre", "BufNewFile" },
			dependencies = { "mason.nvim", "mason-lspconfig.nvim", "hrsh7th/cmp-nvim-lsp" },
			config = function()
				-- Define a common `on_attach` function for keymaps & formatting
				local on_attach = function(client, bufnr)
					local bufmap = function(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
					end

					-- Common keymaps
					bufmap("n", "gd", vim.lsp.buf.definition, "Go to Definition")
					bufmap("n", "K", vim.lsp.buf.hover, "Hover Documentation")
					bufmap("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
					bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
					bufmap("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
					bufmap("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
					bufmap("n", "<leader>x", vim.diagnostic.open_float, "Show diagnostics")
				end

				-- Hook up LSP servers with cmp-nvim-lsp
				local capabilities = vim.lsp.protocol.make_client_capabilities()
				capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

				-- Setup mason & mason-lspconfig
				require("mason").setup()
				require("mason-lspconfig").setup({ ensure_installed = { "gopls" } })

				-- Loop over servers and apply common settings
				local lspconfig = require("lspconfig")
				for _, server in ipairs({ "gopls" }) do
					lspconfig[server].setup({
						on_attach = on_attach,
						capabilities = capabilities,
						-- you can override per-server settings here:
						-- settings = server == "gopls" and { gopls = { gofumpt = true } } or nil,
					})
				end
			end,
		},

		-- A source that completion engines (e.g. nvim-cmp) can pull LSP suggestions from
		{
			"hrsh7th/cmp-nvim-lsp",
			dependencies = { "nvim-cmp" },
			event = { "BufReadPre", "BufNewFile" },
		},

		-- Autocompletion engine
		{
			"hrsh7th/nvim-cmp",
			event = "InsertEnter",
			dependencies = {
				"hrsh7th/cmp-nvim-lsp", -- pull completions from your LSP servers
				"hrsh7th/cmp-buffer", -- pull words from open buffers
				"hrsh7th/cmp-path", -- complete filesystem paths
				"hrsh7th/cmp-cmdline", -- complete in the command‑line (/:, :)
				"L3MON4D3/LuaSnip", -- snippet engine
				"saadparwaiz1/cmp_luasnip", -- allow cmp to expand LuaSnip snippets
			},
			config = function()
				local cmp = require("cmp")
				local luasnip = require("luasnip")

				cmp.setup({
					-- Hook cmp into LuaSnip for instructions on how to expand a snippet when it encounters one
					snippet = {
						expand = function(args)
							luasnip.lsp_expand(args.body)
						end,
					},

					-- Key mappings
					mapping = cmp.mapping.preset.insert({
						["<C-Space>"] = cmp.mapping.complete(),
						["<CR>"] = cmp.mapping.confirm({ select = true }),

						["<Tab>"] = cmp.mapping(function(fallback)
							if cmp.visible() then
								cmp.select_next_item()
							elseif luasnip.expand_or_locally_jumpable() then
								luasnip.expand_or_jump()
							else
								fallback()
							end
						end, { "i", "s" }),
						["<S-Tab>"] = cmp.mapping(function(fallback)
							if cmp.visible() then
								cmp.select_prev_item()
							elseif luasnip.locally_jumpable(-1) then
								luasnip.jump(-1)
							else
								fallback()
							end
						end, { "i", "s" }),
					}),

					-- Define sources and their priority
					sources = cmp.config.sources({
						{ name = "codecompanion", group_index = 1 },
						{ name = "nvim_lsp", group_index = 2 }, -- LSP suggestions
						{ name = "luasnip", group_index = 3 }, -- snippets
					}, {
						{ name = "buffer" }, -- words in open buffers
						{ name = "path" }, -- filesystem paths
					}),

					-- UI
					window = {
						completion = cmp.config.window.bordered(),
						documentation = cmp.config.window.bordered(),
					},
				})

				-- Instead of using the default cmdline mappings, override
				-- it to retain functionality of <C-p> and <C-n>
				local cmdline_mapping = {
					-- confirm with <CR>
					["<CR>"] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace }),
					-- navigate suggestions with Tab / S‑Tab only
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						else
							fallback()
						end
					end, { "c" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end, { "c" }),
				}

				-- Setup command line auto completions
				cmp.setup.cmdline(":", {
					mapping = cmdline_mapping,
					sources = {
						{ name = "path" },
						{ name = "cmdline" },
					},
				})
				cmp.setup.cmdline("/", {
					mapping = cmdline_mapping,
					sources = {
						{ name = "buffer" },
					},
				})
			end,
		},

		-- Plugin to link Mason with none-ls
		{
			"jay-babu/mason-null-ls.nvim",
			dependencies = {
				"williamboman/mason.nvim",
				"nvimtools/none-ls.nvim",
			},
			config = function()
				require("mason").setup()
				require("mason-null-ls").setup({
					ensure_installed = { "buf", "golangci_lint", "golines", "stylua" },
					automatic_installation = true,
					automatic_setup = false,
				})
			end,
		},

		-- Plugin used to handle linting & formatting
		{
			"nvimtools/none-ls.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			config = function()
				local null_ls = require("null-ls")
				null_ls.setup({
					sources = {
						-- Protobuf
						null_ls.builtins.diagnostics.buf,
						null_ls.builtins.formatting.buf,

						-- Golang
						null_ls.builtins.diagnostics.golangci_lint,
						null_ls.builtins.formatting.golines.with({
							extra_args = { "--max-len", "120", "--shorten-comments" },
						}),

						-- Lua
						null_ls.builtins.formatting.stylua.with({
							extra_args = { "--indent-width", "2" },
						}),
					},
					on_attach = function(client, bufnr)
						if client.supports_method("textDocument/formatting") then
							vim.api.nvim_create_autocmd("BufWritePre", {
								buffer = bufnr,
								callback = function()
									vim.lsp.buf.format({
										bufnr = bufnr,
										filter = function(c)
											return c.name == "null-ls"
										end,
									})
								end,
							})
						end
					end,
				})
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
					display = { chat = { window = { layout = "float" } } },
				})
			end,
		},

		-- Plugin for toggling a terminal window
		{
			"akinsho/toggleterm.nvim",
			version = "*",
			config = function()
				require("toggleterm").setup({
					open_mapping = [[<C-\>]],
					direction = "float",
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

		-- GitHub in Neovim plugin
		{
			"pwntester/octo.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-telescope/telescope.nvim",
				"nvim-tree/nvim-web-devicons",
			},
			config = function()
				require("octo").setup({
					use_local_fs = true,
				})
			end,
		},

		-- Plugin for Golang
		{
			"ray-x/go.nvim",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"nvim-lua/plenary.nvim",
				"neovim/nvim-lspconfig",
			},
			config = function()
				require("go").setup({
					-- Don't reconfigure gopls as it is already configured in lspconfig
					lsp_cfg = false,

					-- use gopls under the hood for imports & struct filling
					goimports = "golines",
					fillstruct = "gopls",

					-- run tests in a floating window
					run_in_floaterm = true,
				})
			end,
		},
	},
})
