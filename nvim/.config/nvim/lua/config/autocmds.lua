-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "Callbacks for LSP clients",
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    if client.name == "eslint" then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = args.buf,
        command = "LspEslintFixAll",
      })
    end

    if client.name == "vtsls" then
      vim.api.nvim_buf_create_user_command(args.buf, "OrganizeImports", function()
        vim.lsp.buf.code_action({
          context = { only = { "source.organizeImports" }, diagnostics = {} },
          apply = true,
        })
      end, { desc = "Organize imports using vtsls" })
    end
  end,
})
