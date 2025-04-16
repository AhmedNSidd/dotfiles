-- Go language specific LSP settings

local lspconfig = require('lspconfig')

lspconfig.gopls.setup({
  on_attach = function(client, bufnr)
    -- Load common on_attach settings
    require("lsp").on_attach(client, bufnr)
    
    -- Go-specific keybindings
    local opts = {buffer = bufnr}
    vim.keymap.set("n", "<leader>gt", ":GoTest<CR>", opts)
    vim.keymap.set("n", "<leader>gtf", ":GoTestFunc<CR>", opts)
  end,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        shadow = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
})

