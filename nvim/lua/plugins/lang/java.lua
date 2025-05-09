return {
	{
		"mfussenegger/nvim-jdtls",
		dependencies = { "mfussenegger/nvim-dap" },
		ft = { "java" },
		config = function()
			-- Create an autocommand that runs for each Java file
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "java",
				callback = function()
					local home = os.getenv("HOME")
					local workspace_path = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
					local handlers = require("config.lsp_handlers")
					local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
					-- Path to lombok jar
					local lombok_path = home .. "/.local/share/java/lombok.jar"

					local config = {
						cmd = {
							vim.fn.expand("$HOME") .. "/.local/share/nvim/mason/bin/jdtls",
							"--jvm-arg=-javaagent:" .. lombok_path, -- Corrected format
							"--jvm-arg=-Xmx1G",
							"--data=" .. workspace_path,
						},
						root_dir = vim.fs.dirname(vim.fs.find({ "gradlew", ".git", "mvnw", "pom.xml" }, { upward = true })[1]),
						on_attach = handlers.on_attach,
						capabilities = capabilities,
						init_options = {
							bundles = {
								vim.fn.glob(
									home
										.. "/.local/share/nvim/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar",
									1
								),
							},
						},
					}
					require("jdtls").start_or_attach(config)
				end,
			})
		end,
	},
}
