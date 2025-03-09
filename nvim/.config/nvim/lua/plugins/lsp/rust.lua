return {
  "mrcjkb/rustaceanvim",
  version = "^5",
  lazy = false, -- This plugin is already lazy
  config = function()
    -- Configure rustaceanvim
    vim.g.rustaceanvim = {
      server = {
        on_attach = function(client)
          -- Disable formatting capabilities of rust-analyzer, I prefer using conform for that
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
      },
    }
  end,
}
