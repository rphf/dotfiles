return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate", -- Runs registry update when plugin is installed/updated
    opts_extend = { "ensure_installed" }, -- Allows merging with user's ensure_installed list
    opts = {
      ensure_installed = {
        "stylua",
      },
    },

    config = function(_, opts)
      -- Set up Mason core with merged options
      require("mason").setup(opts)

      -- Access Mason registry for package management
      local mr = require("mason-registry")

      -- Hook to trigger after successful package installation
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          -- Refresh filetype detection to potentially load new LSP servers
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)

      -- Refresh registry and install missing packages
      mr.refresh(function()
        -- Loop through requested tools
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          -- Install if not already present
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" }, -- Ensure mason.nvim is loaded first
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "rust_analyzer", -- Needed for rustaceanvim
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason-lspconfig.nvim" }, -- Ensure mason-lspconfig.nvim is loaded first
    config = function()
      -- Set up LSP servers via lspconfig
      local lspconfig = require("lspconfig")

      lspconfig.lua_ls.setup({
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" }, -- Ignore "vim" global warnings
            },
          },
        },
      })
    end,
  },
}
