-- ===================================================================
-- Other Options
-- ===================================================================

-- Leader key setting
vim.g.mapleader = " "

-- Open vertical splits on the right
vim.opt.splitright = true

-- Line numbers: absolute on the current line (glanceable when screen sharing),
-- relative elsewhere so count-motions (5j, 12k) are obvious.
vim.opt.number = true

-- Set how tabs are displayed visually without changing their underlying character
vim.opt.tabstop = 4 -- Display tabs as 4 spaces wide instead of 8
vim.opt.shiftwidth = 4 -- Use 4 spaces for each level of indentation
vim.opt.softtabstop = 4 -- Number of spaces that a <Tab> counts for while editing
vim.opt.expandtab = true -- Use spaces instead of tabs for indentation
