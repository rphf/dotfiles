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
      local lspconfig = require("lspconfig")
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      lspconfig.ruby_lsp.setup({
        capabilities = capabilities,
        settings = {},
      })

      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            telemetry = {
              enable = false, -- Disable telemetry
            },
          },
        },
      })

      lspconfig.eslint.setup({
        capabilities = capabilities,
        settings = {
          -- Helps eslint find the eslint config file when it's placed in a subfolder instead of the cwd root
          workingDirectories = { mode = "auto" },
          codeActionOnSave = {
            enable = true,
            mode = "all",
          },
        },
        on_attach = function(client, bufnr)
          -- Enable ESLint fix on save
          if client.name == "eslint" then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              command = "EslintFixAll", -- applies all eslint fixes on save
            })
          end
        end,
      })

      local function organize_imports()
        local params = {
          command = "typescript.organizeImports",
          arguments = { vim.api.nvim_buf_get_name(0) },
          title = "",
        }
        vim.lsp.buf.execute_command(params)
      end

      local function fix_all()
        local params = {
          command = "typescript.fixAll",
          arguments = { vim.api.nvim_buf_get_name(0) },
          title = "",
        }
        vim.lsp.buf.execute_command(params)
      end

      local function select_typescript_version()
        local params = {
          command = "typescript.selectTypeScriptVersion",
          arguments = { vim.api.nvim_buf_get_name(0) },
          title = "",
        }
        vim.lsp.buf.execute_command(params)
      end

      local function add_missing_imports()
        local params = {
          apply = true,
          context = { only = { "source.addMissingImports.ts" } },
        }
        vim.lsp.buf.code_action(params)
      end

      local function remove_unused_imports()
        local params = {
          apply = true,
          context = { only = { "source.removeUnused.ts" } },
        }
        vim.lsp.buf.code_action(params)
      end

      lspconfig.vtsls.setup({
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
        },
        commands = {
          OrganizeImports = {
            organize_imports,
            description = "Organize Imports",
          },
          FixAll = {
            fix_all,
            description = "Fix all",
          },
          SelectTypescriptVersion = {
            select_typescript_version,
            description = "Select Typescript version",
          },
          AddMissingImports = {
            add_missing_imports,
            description = "Add missing imports",
          },
          RemoveUnusedImports = {
            remove_unused_imports,
            description = "Remove unused imports",
          },
        },
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
    end,
  },
}
