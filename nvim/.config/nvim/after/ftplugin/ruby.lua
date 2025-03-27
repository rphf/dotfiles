vim.keymap.set("n", "gd", function()
  -- Try to find definitions using LSP
  require("snacks").picker.lsp_definitions()
  -- Else use ctags
  -- TODO: implement navigating to with ctags if lsp_definitions doesn't work
  -- navigating with ctags currently works with built in <C-]>
  -- why not looking at https://github.com/ludovicchabant/vim-gutentags
end, { desc = "Go to definition (fallback to ctags if LSP fails)" })
