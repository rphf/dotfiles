vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    local buf = args.buf
    local ft = vim.bo[buf].filetype

    -- Synchronous LSP import organization for TS/TSX
    if ft == "typescript" or ft == "typescriptreact" then
      vim.lsp.buf.code_action({
        context = { only = { "source.organizeImports" }, diagnostics = {} },
        apply = true,
      })
      vim.wait(50) -- Wait for the LSP to finish organizing imports
    end

    -- Format with conform
    require("conform").format({ bufnr = buf })
  end,
})
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
      -- format_on_save = {
      --   timeout_ms = 500, -- Timeout for formatting
      --   lsp_fallback = false, -- Fallback to LSP if formatter fails
      -- },
    })
  end,
}
