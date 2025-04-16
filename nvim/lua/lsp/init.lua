-- LSP configuration

-- Setup Mason for installing LSP servers
require("mason").setup()
require("mason-lspconfig").setup({
  -- Ensure these LSP servers are installed
  ensure_installed = { "gopls", "lua_ls", "metals" },
})

-- Setup none-ls for linting/formatting
local null_ls = require("none-ls")
null_ls.setup({
  sources = {
    -- Go formatting
    null_ls.builtins.formatting.goimports,
    null_ls.builtins.formatting.golines.with({
      extra_args = {"--shorten-comments", "--max-len=120"}
    }),
    
    -- Protocol Buffers
    null_ls.builtins.formatting.buf,
    null_ls.builtins.diagnostics.buf,
    
    -- Scala
    null_ls.builtins.formatting.scalafmt,
  },
})

-- Common LSP configuration
local on_attach = function(client, bufnr)
  -- Enable completion
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
  
  -- LSP keybindings for the current buffer
  local opts = {buffer = bufnr}
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
end

-- Configure LSP servers
local lspconfig = require('lspconfig')

-- Go LSP
lspconfig.gopls.setup({
  on_attach = on_attach,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
})

-- Scala LSP (Metals)
lspconfig.metals.setup({
  on_attach = on_attach,
  -- Replicate your ALE settings
  root_dir = lspconfig.util.root_pattern("build.sbt", "build.sc"),
})

-- Auto-format on save (equivalent to ALE's fix_on_save)
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    vim.lsp.buf.format({async = false})
  end,
})

