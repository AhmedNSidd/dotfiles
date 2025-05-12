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

local dapui_reset_augroup = vim.api.nvim_create_augroup("DapuiReset", { clear = true })

-- Check if any dapui windows are currently visible using regex matching
local function is_dapui_open()
	for _, win in pairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.bo[buf].filetype
		-- Match any filetype starting with "dap" followed by "-" or "_"
		if ft:match("^dap[_-]") then
			return true
		end
	end
	return false
end

-- Helper function for resetting dapui safely only if it's already open
local function reset_dapui_if_open()
	vim.defer_fn(function()
		if is_dapui_open() then
			pcall(function()
				require("dapui").open({ reset = true })
			end)
		end
	end, 100)
end

-- Reset when toggleterm opens/closes
vim.api.nvim_create_autocmd("BufWinLeave", {
	group = dapui_reset_augroup,
	callback = function(args)
		if vim.bo[args.buf].filetype == "toggleterm" then
			reset_dapui_if_open()
		end
	end,
})

-- Reset when codecompanion buffer is shown/hidden
vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
	group = dapui_reset_augroup,
	callback = function(args)
		if vim.bo[args.buf].filetype == "codecompanion" then
			reset_dapui_if_open()
		end
	end,
})
