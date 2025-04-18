-- Autocommands

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Diff formatting
local diff_format = augroup("DiffFormatting", {clear = true})
autocmd("VimEnter", {
  group = diff_format,
  callback = function()
    if vim.o.diff then
      vim.cmd('windo set wrap')
    end
  end,
})

autocmd("OptionSet", {
  group = diff_format,
  pattern = "diff",
  callback = function()
    if vim.o.diff then
      vim.opt_local.wrap = true
    end
  end,
})

-- Create or clear the autocommand group
vim.api.nvim_create_augroup("UserCodeCompanionSettings", { clear = true })

-- Define the autocommand for the 'codecompanion' filetype
vim.api.nvim_create_autocmd("FileType", {
  group = "UserCodeCompanionSettings",
  pattern = "codecompanion", -- Match the chat window filetype
  desc = "Override C-c behavior in CodeCompanion chat",
  callback = function(args)
    local buf = args.buf
    -- Delay slightly to ensure plugin maps are potentially set first
    vim.defer_fn(function()
      -- Check buffer validity *inside* the deferred function
      if not vim.api.nvim_buf_is_valid(buf) then
        -- print("User CC Autocmd: Buffer " .. buf .. " no longer valid.") --> Debug print
        return
      end
      -- print("User CC Autocmd: Applying keymaps to buffer " .. buf) --> Debug print

      -- Map <C-c> in Insert mode to <Esc> for this buffer only
      local i_opts = { noremap = true, silent = true, buffer = buf, desc = "User CC: Esc Insert" }
      vim.keymap.set("i", "<C-c>", "<Esc>", i_opts)

      -- Map <C-c> in Normal mode to <Nop> (No Operation) for this buffer only
      local n_opts = { noremap = true, silent = true, buffer = buf, desc = "User CC: Nop Normal" }
      vim.keymap.set("n", "<C-c>", "<Nop>", n_opts)

      -- vim.notify("User CC: Applied <C-c> maps to buffer " .. buf, vim.log.levels.INFO) --> Optional confirmation
    end, 50) -- 50ms delay (can be adjusted, 10-100ms is usually fine)
  end,
})

