local group = vim.api.nvim_create_augroup("autosave", {})

-- Autocommand for autoformatting before autosave
vim.api.nvim_create_autocmd("User", {
  pattern = "AutoSaveWritePre",
  group = group,
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})

-- Autocommand for printing the autosaved message
vim.api.nvim_create_autocmd("User", {
  pattern = "AutoSaveWritePost",
  group = group,
  callback = function(opts)
    if opts.data.saved_buffer ~= nil then
      print("AutoSaved")
    end
  end,
})

return {
  "okuuva/auto-save.nvim",
  enabled = true,
  cmd = "ASToggle",
  event = { "InsertLeave", "TextChanged" },
  opts = {
    enabled = true, -- start auto-save when the plugin is loaded (i.e. when your package manager loads it)
    trigger_events = { -- See :h events
      immediate_save = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend" }, -- vim events that trigger an immediate save
      defer_save = {},
    },

    -- function that takes the buffer handle and determines whether to save the current buffer or not
    -- return true: if buffer is ok to be saved
    -- return false: if it's not ok to be saved
    -- if set to `nil` then no specific condition is applied
    condition = function()
      -- Do not save when I'm in insert mode
      local mode = vim.fn.mode()
      if mode == "i" then
        return false
      end

      return true
    end,
    write_all_buffers = false, -- write all buffers when the current one meets `condition`
    -- Do not execute autocmds when saving
    -- If you set noautocmd = true, autosave won't trigger an auto format
    -- https://github.com/okuuva/auto-save.nvim/issues/55
    noautocmd = false,
    lockmarks = false, -- lock marks when saving, see `:h lockmarks` for more details
    -- delay after which a pending save is executed (default 1000)
    debounce_delay = 2000,
    -- log debug messages to 'auto-save.log' file in neovim cache directory, set to `true` to enable
    debug = false,
  },
}
