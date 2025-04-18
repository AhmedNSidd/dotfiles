-- Entry point for Neovim configuration
-- This file loads all the individual configuration modules

-- Install lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key before loading plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load configuration modules
require("plugins")   -- Load and configure plugins (this will now handle LSP setup)
require("options")   -- General Neovim options
require("keymaps")   -- Key mappings
require("autocmds")  -- Autocommand groups (keep general autocmds here)
