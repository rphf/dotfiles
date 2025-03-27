return {
  "williamboman/mason.nvim",
  build = ":MasonUpdate", -- Runs registry update when plugin is installed/updated
  opts_extend = { "ensure_installed" }, -- Allows merging with user's ensure_installed list
  opts = {
    ensure_installed = {
      "stylua",
      "rubyfmt",
      "prettierd",
      "eslint_d",
    },
  },
  keys = {
    { "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason" } },
  },
  config = function(_, opts)
    -- Set up Mason core with merged options
    require("mason").setup(opts)

    -- Access Mason registry for package management
    local mr = require("mason-registry")

    -- Hook to trigger after successful package installation
    mr:on("package:install:success", function()
      vim.defer_fn(function()
        -- Refresh filetype detection to potentially load new LSP servers
        require("lazy.core.handler.event").trigger({
          event = "FileType",
          buf = vim.api.nvim_get_current_buf(),
        })
      end, 100)
    end)

    -- Refresh registry and install missing packages
    mr.refresh(function()
      -- Loop through requested tools
      for _, tool in ipairs(opts.ensure_installed) do
        local p = mr.get_package(tool)
        -- Install if not already present
        if not p:is_installed() then
          p:install()
        end
      end
    end)
  end,
}
