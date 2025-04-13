return {
  "tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
  "eandrju/cellular-automaton.nvim", -- Cool animations
  { "echasnovski/mini.pairs", version = "*" },
  { "echasnovski/mini.surround", version = "*" },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
  },
  { -- Scroll after the end of file
    "Aasim-A/scrollEOF.nvim",
    event = { "CursorMoved", "WinScrolled" },
    opts = {},
    config = function()
      require("scrollEOF").setup({
        -- Whether or not scrollEOF should be enabled in floating windows
        floating = false,
      })
    end,
  },
  {
    "andrewferrier/debugprint.nvim",
    -- dependencies = {
    --   "echasnovski/mini.nvim", -- Needed for :ToggleCommentDebugPrints(NeoVim 0.9 only)
    --   -- and line highlighting (optional)
    -- },
    opts = {
      keymaps = {
        visual = {
          variable_below = "<leader>l",
        },
      },
    },
    version = "*", -- Remove if you DON'T want to use the stable version
    -- lazy = false, -- Required to make line highlighting work before debugprint is first used
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {},
    config = function()
      vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "None" })
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },
}
