return {
  "dmmulroy/tsc.nvim",
  event = "VeryLazy",
  -- PERF: look how to load this plugin only for typescript and typescriptreact filetypes.
  config = function()
    local utils = require("tsc.utils")

    local function find_tsc_bin()
      local cwd = vim.fn.getcwd()
      local dir = cwd

      -- Traverse upwards until we find a node_modules/.bin/tsc
      while dir ~= "" do
        local tsc_path = dir .. "/node_modules/.bin/tsc"
        if vim.fn.filereadable(tsc_path) == 1 then
          return tsc_path
        end

        -- Check subdirectories for node_modules/.bin/tsc
        local subdirs = vim.fn.globpath(dir, "*/node_modules/.bin/tsc", false, true)
        if #subdirs > 0 then
          return subdirs[1]
        end

        -- Move up to the parent directory
        local parent = vim.fn.fnamemodify(dir, ":h")
        if parent == dir then
          break -- Reached the root directory
        end
        dir = parent
      end

      -- Fallback to global tsc if not found
      return "tsc"
    end

    local function find_nearest_tsconfig()
      local cwd = vim.fn.getcwd()
      local dir = cwd

      -- Traverse upwards until we find a tsconfig.json
      while dir ~= "" do
        local tsconfig_path = dir .. "/tsconfig.json"
        if vim.fn.filereadable(tsconfig_path) == 1 then
          return { tsconfig_path }
        end

        -- Check subdirectories for tsconfig.json
        local subdirs = vim.fn.globpath(dir, "*/tsconfig.json", false, true)
        if #subdirs > 0 then
          return { subdirs[1] }
        end

        -- Move up to the parent directory
        local parent = vim.fn.fnamemodify(dir, ":h")
        if parent == dir then
          break -- Reached the root directory
        end
        dir = parent
      end

      -- Return empty table if none found
      return {}
    end

    require("tsc").setup({
      auto_open_qflist = true,
      auto_close_qflist = true,
      auto_focus_qflist = false,
      auto_start_watch_mode = false,
      use_trouble_qflist = true,
      use_diagnostics = true,
      bin_path = find_tsc_bin(),
      run_as_monorepo = false,
      enable_progress_notifications = true,
      enable_error_notifications = true,
      flags = {
        noEmit = true,
        project = find_nearest_tsconfig(),
        watch = false,
      },
      hide_progress_notifications_from_history = true,
      spinner = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" },
      pretty_errors = true,
    })
  end,
}
