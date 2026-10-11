return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  lazy = false,
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- https://github.com/folke/todo-comments.nvim?tab=readme-ov-file#%EF%B8%8F-configuration
  },
  keys = {
    {
      "<leader>st",
      function()
        require("snacks").picker.todo_comments({ hidden = true })
      end,
      desc = "Todo",
    },
  },
}
