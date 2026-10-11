vim.keymap.set("n", "gd", function()
  require("snacks").picker.lsp_definitions()
end, { desc = "Go to definition" })
