return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "j-hui/fidget.nvim",
  },
  keys = {
    { "<localleader>a", "<cmd>CodeCompanionChat Add<cr>", desc = "Add code to a chat buffer", mode = { "n", "v" } },
    { "<leader>ac", "<cmd>CodeCompanionChat toggle<cr>", desc = "Toggle a chat buffer", mode = { "n", "v" } },
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "Open the action palette", mode = { "n", "v" } },
  },

  opts = {
    strategies = {
      chat = {
        adapter = "deepseek",
      },
    },
  },
}
