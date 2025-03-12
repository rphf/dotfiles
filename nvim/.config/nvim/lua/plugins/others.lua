return {
  "tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
  "eandrju/cellular-automaton.nvim", -- Cool animations
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
}
