return {
	{
		"mfussenegger/nvim-dap-python",
		ft = { "python" },
		dependencies = { "mfussenegger/nvim-dap" },
		config = function()
			local dap = require("dap")
			local dap_python = require("dap-python")
			local project_py = vim.fn.getcwd() .. "/.venv/bin/python" -- adjust to your venv path

			-- 1) point to Mason-installed debugpy
			require("dap-python").setup(project_py)
			dap_python.test_runner = "pytest"

			-- 2) your existing test keymaps
			vim.keymap.set("n", "<leader>df", dap_python.test_class, { desc = "Debug Class" })

			-- 3) (re)define the python adapter if you want full control
			dap.adapters.python = {
				type = "executable",
				-- use the same python that has debugpy installed
				command = project_py,
				args = { "-m", "debugpy.adapter" },
			}

			-- 4) append a Django launch config
			dap.configurations.python = dap.configurations.python or {}
			table.insert(dap.configurations.python, {
				name = "Django: Runserver",
				type = "python",
				request = "launch",
				program = "${workspaceFolder}/manage.py",
				args = { "runserver", "0.0.0.0:8000" },
				django = true,
			})
		end,
	},
}
