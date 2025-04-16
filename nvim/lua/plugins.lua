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
    config = function()
      require("auto-dark-mode").setup({
        update_interval = 1000,
        set_dark_mode = function() vim.cmd("colorscheme catppuccin-mocha") end,
        set_light_mode = function() vim.cmd("colorscheme catppuccin-latte") end,
      })
    end,
  },

  -- Oil File Explorer (replacement for netrw)
  {
    "stevearc/oil.nvim",
    opts = {
      default_file_explorer = true,
      view_options = { show_hidden = true },
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
    dependencies = { "stevearc/oil.nvim", "nvim-telescope/telescope.nvim" }, -- Optional: for fuzzy project switching
    config = function()
      require("workspaces").setup({
        -- Optional: open Telescope file finder after switching projects
        hooks = {
          open = {
	    function(name, path)
              require('oil').open(path)
            end
          },
        },
        -- Optional: sort by most recently used
        sort = true,
        mru_sort = true,
        -- Optional: change directory globally (default is "global")
        cd_type = "global",
      })
      -- Load the Telescope extension if you use Telescope
      require("telescope").load_extension("workspaces")
    end,
  },
  
  -- LSP, linting and formatting with built-in LSP
  {
    "neovim/nvim-lspconfig", -- Official LSP support
    dependencies = {
      -- LSP manager (installs servers automatically)
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      -- For linting/formatting like ALE did
      "nvimtools/none-ls.nvim",
    },
  },
  
  -- LineDiff
  { "AndrewRadev/linediff.vim" },
  
  -- Git integration
  { "tpope/vim-fugitive" },
  { 
    "lewis6991/gitsigns.nvim",
    config = true,
  },
  
  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    build = function() vim.fn["mkdp#util#install"]() end,
    ft = { "markdown" },
  },
  
  -- Go support
  {
    "fatih/vim-go",
    build = ":GoUpdateBinaries",
    config = function()
      vim.g.go_fmt_autosave = 0 -- Disable auto-formatting (handled by LSP)
      vim.g.go_metalinter_enabled = {} -- Disable linting (handled by LSP)
      vim.g.go_test_timeout = '30s'
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
          -- Match your current terminal settings
          vim.opt_local.wrap = false
          vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<C-\\><C-n>", {noremap = true})
        end,
      })
    end,
  },
})

