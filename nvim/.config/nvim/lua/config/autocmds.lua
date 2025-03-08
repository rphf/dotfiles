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

-- TODO: Double check this setup
-- Autosave on focus lost
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "VimLeavePre" }, {
  group = vim.api.nvim_create_augroup("auto-save", { clear = true }),
  callback = function(event)
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(event.buf) then
        local buf_name = vim.api.nvim_buf_get_name(event.buf)
        if vim.bo[event.buf].modified and buf_name ~= "" then
          vim.api.nvim_buf_call(event.buf, function()
            vim.cmd("silent! write")
          end)
        end
      end
    end)
  end,
})
