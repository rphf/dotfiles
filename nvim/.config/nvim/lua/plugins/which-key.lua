return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "helix",
    spec = {
      { "<leader>a", group = "AI: Code Companion" },
      { "<leader>c", group = "Code & Config" },
      { "<leader>g", group = "Git" },
      { "<leader>h", group = "Git hunks" },
      { "<leader>m", group = "Misc" },
      { "<leader>s", group = "Search" },
      { "<leader>u", group = "UI" },
      { "<leader>x", group = "Trouble" },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
