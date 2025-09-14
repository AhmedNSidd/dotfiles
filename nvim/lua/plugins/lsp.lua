local handlers = require("config.lsp_handlers")

return {
	-- Plugin for install and managing external tools (e.g. LSP servers)
	{
		"williamboman/mason.nvim",
		opts = {
			ensure_installed = {
				"java-debug-adapter",
				"java-test",
				"debugpy", -- debugger for Python
			},
		},
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
			-- Hook up LSP servers with cmp-nvim-lsp
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			-- Setup mason & mason-lspconfig
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = { "gopls", "jdtls", "lua_ls", "pyright", "texlab", "ts_ls" },
				automatic_enable = false,
			})
			-- Loop over servers and apply common settings
			local lspconfig = require("lspconfig")
			for _, server in ipairs({ "gopls", "lua_ls", "pyright", "ts_ls" }) do
				if server == "lua_ls" then
					lspconfig.lua_ls.setup({
						on_attach = handlers.on_attach,
						capabilities = capabilities,
						settings = {
							Lua = {
								diagnostics = {
									globals = { "vim" },
								},
								workspace = {
									-- Make the server aware of Neovim runtime files
									library = vim.api.nvim_get_runtime_file("", true),
									checkThirdParty = false, -- Avoid issues with third-party libraries in your Neovim config
								},
							},
						},
					})
				else
					lspconfig[server].setup({
						on_attach = handlers.on_attach,
						capabilities = capabilities,
						-- you can override per-server settings here:
						-- settings = server == "gopls" and { gopls = { gofumpt = true } } or nil,
					})
				end
			end
			-- Add texlab configuration
			lspconfig.texlab.setup({
				on_attach = handlers.on_attach,
				capabilities = capabilities,
				settings = {
					texlab = {
						build = {
							executable = "latexmk",
							args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "-outdir=out" },
							onSave = true,
						},
						forwardSearch = {
							executable = "skim", -- Change to "skim" on macOS
							args = { "--synctex-forward", "%l:1:%f", "%p" },
						},
						chktex = { onOpenAndSave = true },
					},
				},
			})
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
				ensure_installed = {
					"stylua",
					"buf",
					"golangci_lint",
					"golines",
					"checkstyle",
					"google_java_format",
					"scalafmt",
					"latexindent",
					"yamllint",
					"yamlfmt",
					"eslint_d",
					"prettierd",
				},
				automatic_installation = true,
				automatic_setup = false,
			})
		end,
	},

	-- Plugin used to handle linting & formatting
	{
		"nvimtools/none-ls.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvimtools/none-ls-extras.nvim",
		},
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					-- Lua
					null_ls.builtins.formatting.stylua.with({
						extra_args = { "--indent-width", "2" },
					}),

					-- YAML
					null_ls.builtins.formatting.yamlfmt,
					null_ls.builtins.diagnostics.yamllint,

					-- Protobuf
					null_ls.builtins.diagnostics.buf,
					null_ls.builtins.formatting.buf,

					-- Golang
					null_ls.builtins.diagnostics.golangci_lint,
					null_ls.builtins.formatting.golines.with({
						extra_args = { "--max-len", "120", "--shorten-comments" },
					}),

					-- Java
					null_ls.builtins.formatting.google_java_format,
					null_ls.builtins.diagnostics.checkstyle.with({
						extra_args = {
							"-c",
							vim.fn.expand("~/.config/checkstyle/google_checks.xml"),
						},
					}),

					-- Scala
					null_ls.builtins.formatting.scalafmt,

					-- LaTeX
					require("none-ls.formatting.latexindent"),
				},
				on_attach = function(client, bufnr)
					if client.supports_method("textDocument/formatting") then
						-- default on
						vim.api.nvim_buf_set_var(bufnr, "autoformat", true)

						-- command to toggle autoformat globally
						vim.api.nvim_buf_create_user_command(bufnr, "ToggleAutoFormat", function()
							vim.g.autoformat_enabled = not vim.g.autoformat_enabled
							print("global autoformat =", vim.g.autoformat_enabled)
						end, { desc = "Toggle LSP autoformat on save globally" })

						-- autoformat on save if both global and buffer flags are true
						vim.api.nvim_create_autocmd("BufWritePre", {
							buffer = bufnr,
							callback = function()
								if vim.g.autoformat_enabled and vim.b.autoformat then
									vim.lsp.buf.format({
										bufnr = bufnr,
										filter = function(c)
											return c.name == "null-ls"
										end,
									})
								end
							end,
						})
					end
				end,
			})
		end,
	},
}
