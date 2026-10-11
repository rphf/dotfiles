return {
  {
    "folke/lazydev.nvim",
    dependencies = {
      { "Bilal2453/luvit-meta" },
      { "justinsgithub/wezterm-types" },
    },
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = "vim%.uv" },
        { path = "wezterm-types", mods = { "wezterm" } },
      },
    },
    config = function()
      require("lazydev").setup()
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      -- Set up LSP servers via lspconfig
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            telemetry = {
              enable = false,
            },
          },
        },
      })

      vim.lsp.config("eslint", {
        settings = {
          -- Helps eslint find the eslint config file when it's placed in a subfolder instead of the cwd root
          workingDirectories = { mode = "auto" },
          codeActionOnSave = {
            enable = true,
            mode = "all",
          },
        },
      })

      vim.lsp.config("vtsls", {
        settings = {
          complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = {
              completeFunctionCalls = true,
            },
            preferences = {
              organiseImports = true,
            },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
        },
      })

      vim.lsp.enable({ "lua_ls", "ruby_lsp", "eslint", "vtsls", "tailwindcss", "gopls", "rust_analyzer" })
    end,
  },
}
