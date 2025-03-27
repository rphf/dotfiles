-- Create an autocommand to run commands before saving TypeScript/TSX files
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = { "*.ts", "*.tsx" }, -- Only for TypeScript and TypeScript React files
--   callback = function()
--     -- Execute the commands in sequence
--
--     -- vim.cmd("AddMissingImports")
--     vim.cmd("RemoveUnusedImports")
--     vim.cmd("OrganizeImports")
--   end,
-- })

return {
  "stevearc/conform.nvim",
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        rust = { "rustfmt" },
        ruby = { "rubyfmt" },
        javascript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
      },
      format_on_save = {
        timeout_ms = 500, -- Timeout for formatting
        lsp_fallback = false, -- Fallback to LSP if formatter fails
      },
    })
  end,
}
