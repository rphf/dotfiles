return {
  "stevearc/conform.nvim",
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        rust = { "rustfmt" },
        ruby = { "rubyfmt" },
      },
      formatters = {
        -- Custom configuration for stylua
        stylua = {
          prepend_args = {
            "--column-width",
            "80",
            "--indent-type",
            "Spaces",
            "--indent-width",
            "2",
            "--line-endings",
            "Unix",
            "--quote-style",
            "AutoPreferDouble",
          },
        },
      },
      format_on_save = {
        timeout_ms = 500, -- Timeout for formatting
        lsp_fallback = true, -- Fallback to LSP if formatter fails
      },
    })
  end,
}
