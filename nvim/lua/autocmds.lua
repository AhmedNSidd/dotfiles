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

