return {
  {
    "echasnovski/mini.diff", -- Inline and better diff over the default
    config = function()
      local diff = require("mini.diff")
      diff.setup({
        -- Disabled by default
        source = diff.gen_source.none(),
      })
    end,
  },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "j-hui/fidget.nvim",
      "echasnovski/mini.diff",
    },
    keys = {
      { "<localleader>a", "<cmd>CodeCompanionChat Add<cr>", desc = "Add code to a chat buffer", mode = { "n", "v" } },
      { "<leader>ac", "<cmd>CodeCompanionChat toggle<cr>", desc = "Toggle a chat buffer", mode = { "n", "v" } },
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "Open the action palette", mode = { "n", "v" } },
    },
    opts = {
      log_level = "DEBUG",
      strategies = {
        chat = {
          adapter = "deepseek",
        },
      },
      adapters = {
        deepseek = function()
          return require("codecompanion.adapters").extend("deepseek", {
            schema = {
              model = {
                default = "deepseek-chat",
              },
            },
          })
        end,
      },
      display = {
        chat = {
          show_settings = false, -- Show LLM settings at the top of the chat buffer?
        },
        diff = {
          enabled = true,
          close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
          layout = "vertical", -- vertical|horizontal split for default provider
          opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
          provider = "mini_diff", -- default|mini_diff
        },
      },
    },
  },
}
