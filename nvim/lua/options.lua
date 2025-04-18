-- General Neovim settings

local opt = vim.opt

-- Split behavior
opt.splitright = true    -- Open vertical splits on the right
opt.autowrite = true     -- Auto-save before commands like :next

-- UI options
opt.termguicolors = true -- Enable true color support

-- Diff options
opt.diffopt = "internal,filler,closeoff,algorithm:histogram"

vim.diagnostic.config({
  virtual_text = false, -- Enable virtual text
  signs = true, -- Keep signs in the gutter (like the 'E')
  underline = true, -- Underline the problematic code
  update_in_insert = false, -- Don't update while typing (can be distracting)
  severity_sort = true, -- Show errors before warnings, etc.
})
