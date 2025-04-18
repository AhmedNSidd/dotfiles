-- Plugin management with lazy.nvim
return require("lazy").setup({
  -- Colorscheme (Neovim-specific version)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- Load before other plugins
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha") -- Set the dark theme by default
    end,
  },

  -- Auto light/dark theme switching
  {
    "f-person/auto-dark-mode.nvim",
    opts = { -- Use opts for simpler config
      update_interval = 1000,
      set_dark_mode = function() vim.cmd("colorscheme catppuccin-mocha") end,
      set_light_mode = function() vim.cmd("colorscheme catppuccin-latte") end,
    },
  },

  -- Oil File Explorer (replacement for netrw)
  {
    "stevearc/oil.nvim",
    opts = {
      default_file_explorer = true,
      view_options = { show_hidden = true },
      delete_to_trash = true,
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Workspaces
  {
    "natecraddock/workspaces.nvim",
    dependencies = { "stevearc/oil.nvim", "nvim-telescope/telescope.nvim" },
    config = function()
      require("workspaces").setup({
        hooks = {
          open = {
            function(name, path)
              require('oil').open(path)
            end
          },
        },
        sort = true,
        mru_sort = true,
        cd_type = "global",
      })
      require("telescope").load_extension("workspaces")
    end,
  },

  -- ===================================================================
  -- LSP, Linting, Formatting Section (Integrated Configuration)
  -- ===================================================================
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
  },

  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")

      null_ls.setup({
        sources = {
          -- Go formatting
          null_ls.builtins.formatting.goimports,
          null_ls.builtins.formatting.golines.with({
            extra_args = {"--shorten-comments", "--max-len=120"}
          }),
          null_ls.builtins.diagnostics.golangci_lint,

          -- Protocol Buffers
          null_ls.builtins.formatting.buf,
          null_ls.builtins.diagnostics.buf,

          -- Scala
          null_ls.builtins.formatting.scalafmt,
        },
        -- Configure format on save using null-ls's capabilities
        -- The recommended way is often to hook into the main LSP format command
        -- which null-ls can participate in.
        on_attach = function(client, bufnr)
             if client.supports_method("textDocument/formatting") then
                 -- Ensure the autocmd group is defined and cleared properly
                 local augroup = vim.api.nvim_create_augroup("NullLsFormatOnSave", { clear = true })
                 vim.api.nvim_create_autocmd("BufWritePre", {
                     group = augroup,
                     buffer = bufnr,
                     callback = function()
                         -- Triggering LSP format should include null-ls sources if available
                         vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 2000 })
                     end,
                 })
             end
         end,
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      -- Ensure vim-go is listed if those keymaps depend on it
      "fatih/vim-go",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local cmp_lsp = require("cmp_nvim_lsp")
      local capabilities = cmp_lsp.default_capabilities() -- Get capabilities from nvim-cmp

      -- Define the COMMON on_attach function (used by multiple servers)
      local common_on_attach = function(client, bufnr)
      -- Enable completion
      vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

      -- Common LSP keybindings
      local opts = { buffer = bufnr, noremap = true, silent = true }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
      vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)

      -- Highlight symbol under cursor (optional but helpful)
      if client.server_capabilities.documentHighlightProvider then
	local highlight_augroup = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
	vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
	  buffer = bufnr,
	  group = highlight_augroup,
	  callback = vim.lsp.buf.document_highlight,
	})
	vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
	  buffer = bufnr,
	  group = highlight_augroup,
	  callback = vim.lsp.buf.clear_references,
	})
      end
    end

    -- Define a SPECIFIC on_attach for Go (calls common and adds more)
    local gopls_on_attach = function(client, bufnr)
      -- Run the common setup first
      common_on_attach(client, bufnr)

      -- Go-specific keybindings (Ensure vim-go is installed for these commands)
      local opts = { buffer = bufnr, noremap = true, silent = true }
      -- NOTE: These map to Vim commands provided by fatih/vim-go, not LSP actions.
      vim.keymap.set("n", "<leader>gt", ":GoTest<CR>", opts)
      vim.keymap.set("n", "<leader>gtf", ":GoTestFunc<CR>", opts)
      -- You could add LSP-based test running if gopls supports it via code actions,
      -- but using vim-go's commands is fine too.
    end

    -- List of servers managed by mason-lspconfig
    local servers = { "lua_ls" } -- We'll handle gopls separately below

    require("mason-lspconfig").setup({
      ensure_installed = { "gopls", "lua_ls" }, -- Ensure gopls is installed
    })

    -- Setup non-Go servers using the common on_attach
    for _, server_name in ipairs(servers) do
      lspconfig[server_name].setup({
        on_attach = common_on_attach,
        capabilities = capabilities,
      })
    end

    -- === Specific setup for Go (gopls) ===
    lspconfig.gopls.setup({
      on_attach = gopls_on_attach, -- Use the specific Go on_attach
      capabilities = capabilities,
      settings = {
        gopls = {
	  -- Your previous settings:
	  analyses = {
	    unusedparams = true,
	    shadow = true,
	  },
	  staticcheck = true,
	  gofumpt = true, -- Ensure gofumpt is installed if true

	  -- Recommended: Improve completion behavior with placeholders
	  usePlaceholders = true,
        },
      },
    })
    end,
  }, -- End of nvim-lspconfig entry

  -- Autocomplete plugin (ensure dependencies are listed if not already)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- Already listed as dep for lspconfig, but safe to list again
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip", -- Ensure LuaSnip is loaded
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      cmp.setup.cmdline(":", {
        mapping = {
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item() else fallback() end
          end, { 'c' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item() else fallback() end
          end, { 'c' }),
          ['<Up>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item() else fallback() end
          end, { 'c' }),
          ['<Down>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item() else fallback() end
          end, { 'c' }),
        },
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })
    end, -- End of nvim-cmp config
  }, -- End of nvim-cmp entry

  -- CodeCompanion AI Integration
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter", -- Ensure treesitter is included if not elsewhere
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codecompanion").setup({
         -- Your CodeCompanion config here
         config = {
            adapters = {
              copilot = { },
              anthropic = {
                api_key = vim.env.ANTHROPIC_API_KEY,
                model = "claude-3-7-sonnet-20250219", -- Note: Model might be outdated, check Anthropic docs
              },
            },
            strategies = {
              chat = { adapter = "anthropic" },
              inline = { adapter = "copilot" },
              agent = { adapter = "anthropic" },
            },
            display = { chat = { window = { border = "rounded", width = 80, height = 20 } } },
         },
         completion = { enable = true, source = "nvim-cmp" },
      })
    end,
  },

  -- LineDiff
  { "AndrewRadev/linediff.vim" },

  -- Git integration
  { "tpope/vim-fugitive" },
  { "lewis6991/gitsigns.nvim", config = true }, -- config = true is shorthand for require("gitsigns").setup()

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    build = function() vim.fn["mkdp#util#install"]() end,
    ft = { "markdown" },
  },

  -- Go support (vim-go) - Consider if still needed alongside gopls + null-ls
  {
    "fatih/vim-go",
    build = ":GoUpdateBinaries",
    event = "FileType go", -- Load only for Go files
    config = function()
      vim.g.go_fmt_autosave = 0 -- Disable auto-formatting (handled by LSP/null-ls)
      vim.g.go_metalinter_enabled = {} -- Disable linting (handled by LSP/null-ls)
      vim.g.go_test_timeout = '30s'
      -- Add any other vim-go specific settings you rely on
    end,
  },

  -- OSC Yank for remote copy
  { "ojroques/vim-oscyank" },

  -- Terminal management
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 9,
        open_mapping = [[<C-\>]],
        direction = "horizontal",
        on_open = function(term)
          vim.opt_local.wrap = false
          vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<C-\\><C-n>", {noremap = true})
        end,
      })
    end,
  },

  -- Treesitter (Dependency for CodeCompanion, good to have anyway)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        require('nvim-treesitter.configs').setup {
            ensure_installed = { "lua", "go", "python", "rust", "c", "cpp", "javascript", "typescript", "html", "css", "markdown", "bash" }, -- Add languages you use
            sync_install = false,
            auto_install = true,
            highlight = { enable = true },
            indent = { enable = true },
        }
    end,
  },

}) -- End of lazy.setup
