-- General Neovim settings

local opt = vim.opt

-- Split behavior
opt.splitright = true    -- Open vertical splits on the right
opt.autowrite = true     -- Auto-save before commands like :next

-- UI options
opt.termguicolors = true -- Enable true color support

-- Diff options
opt.diffopt = "internal,filler,closeoff,algorithm:histogram"

