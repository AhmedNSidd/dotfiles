-- Scala language specific LSP settings

local lspconfig = require('lspconfig')

lspconfig.metals.setup({
  on_attach = function(client, bufnr)
    -- Load common on_attach settings
    require("lsp").on_attach(client, bufnr)
    
    -- Scala-specific keybindings
    local opts = {buffer = bufnr}
    vim.keymap.set("n", "<leader>sm", ":MetalsImportBuild<CR>", opts)
  end,
  settings = {
    metals = {
      showImplicitArguments = true,
      showInferredType = true,
    },
  },
})

