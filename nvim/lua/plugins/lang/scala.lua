return {
	-- Plugin for Scala (LSP included)
	{
		"scalameta/nvim-metals",
		ft = { "scala", "sbt" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"hrsh7th/nvim-cmp",
		},
		config = function()
			local metals = require("metals")
			local nvim_metals_config = metals.bare_config()
			nvim_metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()
			nvim_metals_config.on_attach = function(client, bufnr)
				local bufmap = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
				end

				-- common LSP keymaps
				bufmap("n", "gd", vim.lsp.buf.definition, "Go to Definition")
				bufmap("n", "K", vim.lsp.buf.hover, "Hover Documentation")
				bufmap("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
				bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
				bufmap("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
				bufmap("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
				bufmap("n", "<leader>x", vim.diagnostic.open_float, "Show diagnostics")

				-- Metals‐specific commands (requires telescope extension)
				vim.keymap.set("n", "<leader>ws", function()
					require("telescope").extensions.metals.commands()
				end, { buffer = bufnr, desc = "Metals commands" })
			end

			-- enable some handy Metals settings
			--nvim_metals_config.settings = {
			--	showImplicitArguments = true,
			--	showInferredType = true,
			--	excludedPackages = { "akka.actor.typed.javadsl", "com.github" },
			--}

			-- finally launch or attach to your build server
			metals.initialize_or_attach(nvim_metals_config)
		end,
	},
}
