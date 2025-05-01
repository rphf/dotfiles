return {
  "YounesElhjouji/nvim-copy",
  lazy = false,
  config = function()
    require("nvim_copy").setup({
      ignore = {
        "*node_modules/*",
        "*__pycache__/*",
        "*.git/*",
        "*dist/*",
        "*build/*",
        "*.log",
      },
    })

    -- Optional key mappings:
    vim.api.nvim_set_keymap(
      "n",
      "<leader>cb",
      ":CopyCurrentBufferToClipboard<CR>",
      { noremap = true, silent = true, desc = "Copy current buffer" }
    )
    vim.api.nvim_set_keymap(
      "n",
      "<leader>cB",
      ":CopyBuffersToClipboard<CR>",
      { noremap = true, silent = true, desc = "Copy current open buffers" }
    )
  end,
}
