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

					-- Find debug bundles from Mason installation
					local bundles = {}

					-- Java Debug Adapter
					local java_debug_path = home .. "/.local/share/nvim/mason/packages/java-debug-adapter"
					local debug_bundles =
						vim.split(vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"), "\n")
					for _, bundle in ipairs(debug_bundles) do
						if bundle ~= "" then
							table.insert(bundles, bundle)
						end
					end

					-- Java Test
					local java_test_path = home .. "/.local/share/nvim/mason/packages/java-test"
					local test_bundles = vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar"), "\n")
					for _, bundle in ipairs(test_bundles) do
						if bundle ~= "" then
							table.insert(bundles, bundle)
						end
					end

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
							bundles = bundles,
						},
					}
					require("jdtls").start_or_attach(config)
				end,
			})
		end,
	},
}
