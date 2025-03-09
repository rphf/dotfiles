local mini_files_git = require("plugins.modules.mini-files-git")

return {
  "echasnovski/mini.files",
  version = "*",
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  init = function()
    require("mini.files").setup({
      -- Customization of shown content
      content = {
        -- Predicate for which file system entries to show
        filter = nil,
        -- What prefix to show to the left of file system entry
        prefix = nil,
        -- In which order to show file system entries
        sort = nil,
      },

      -- Module mappings created only inside explorer.
      -- Use `''` (empty string) to not create one.
      mappings = {
        close = "q",
        go_in = "l",
        go_in_plus = "<CR>",
        go_out = "h",
        go_out_plus = "H",
        mark_goto = "'",
        mark_set = "m",
        reset = "<BS>",
        reveal_cwd = "@",
        show_help = "g?",
        synchronize = "s",
        trim_left = "<",
        trim_right = ">",
      },

      -- General options
      options = {
        -- Whether to delete permanently or move into module-specific trash
        permanent_delete = true,
        -- Whether to use for editing directories
        use_as_default_explorer = true,
      },

      -- Customization of explorer windows
      windows = {
        -- Maximum number of windows to show side by side
        max_number = math.huge,
        -- Whether to show preview of file/directory under cursor
        preview = true,
        -- Width of focused window
        width_focus = 50,
        -- Width of non-focused window
        width_nofocus = 15,
        -- Width of preview window
        width_preview = 100,
      },
    })

    -- Load Git integration
    mini_files_git.setup()

    vim.keymap.set("n", "<leader>e", function()
      if require("mini.files").close() then
        return
      end

      local buf_name = vim.api.nvim_buf_get_name(0)
      local dir_name = vim.fn.fnamemodify(buf_name, ":p:h")
      if vim.fn.filereadable(buf_name) == 1 then
        -- Pass the full file path to highlight the file
        require("mini.files").open(buf_name, true)
      elseif vim.fn.isdirectory(dir_name) == 1 then
        -- If the directory exists but the file doesn't, open the directory
        require("mini.files").open(dir_name, true)
      else
        -- If neither exists, fallback to the current working directory
        require("mini.files").open(vim.uv.cwd(), true)
      end
    end, { desc = "Mini file explorer" })
  end,
}
