return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  dependencies = { "echasnovski/mini.icons" },
  opts = {
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    explorer = { enabled = true, replace_netwr = false },
    picker = {
      enabled = true,
      formatters = {
        file = {
          truncate = 100,
        },
      },
      matcher = {
        -- Search within folder name with the same weight thanfile name
        -- It helps searching file in codebase with a lot of identical filename such as `index.ts`
        filename_bonus = false,
      },
      sources = {
        explorer = {
          auto_close = false,
          ignored = true,
          layout = {
            layout = {
              width = 0.35,
              position = "right",
            },
          },
        },
      },
      toggles = {
        regex = { icon = "R", value = true },
      },
    },
    indent = {
      animate = { duration = { step = 20, total = 200 } },
    },
    input = { enabled = true },

    styles = {
      lazygit = {
        width = 0.99,
        height = 0.99,
      },
    },

    -- statuscolumn = { enabled = true },
    -- git = { enabled = true },
    -- bigfile = { enabled = true },
    -- quickfile = { enabled = true },
    -- scope = { enabled = true },
    -- scroll = { enabled = true },
    -- words = { enabled = true },
  },


  -- stylua: ignore
  -- TODO: Refactor this table to only keep what I actually use
  keys = {
    -- Top Pickers & Explorer
    -- { "<leader>f", function() require("snacks").picker.files( { hidden = true }) end, desc = "find files" },
    { "<leader>f", function() require("snacks").picker.smart( { filter = { cwd = true }, hidden = true, layout = { fullscreen = true } } ) end, desc = "Smart Find Files" },
    { "<leader>/", function() require("snacks").picker.grep( { hidden = true, layout = { fullscreen = true }, regex = false } ) end, desc = "Grep fixed string" },
    { "<leader>ss", function() require("snacks").picker.grep( { hidden = true, layout = { fullscreen = true }, regex = true } ) end, desc = "Grep regex" },
    { "<leader>:", function() require("snacks").picker.command_history() end, desc = "Command History" },
    { "<leader>n", function() require("snacks").picker.notifications() end, desc = "Notification History" },
    { "<leader>e", function() require("snacks").explorer( { hidden = true } ) end, desc = "File Explorer" },
    { "<leader>E", function() require("snacks").explorer( { hidden = true, layout = { fullscreen = true, preset = "ivy", preview = true } } ) end, desc = "File Explorer Fullscreen" },
    { "<leader>b", function() require("snacks").picker.buffers(
      {
        -- Open directly in normal mode
        -- on_show = function()
        --   vim.cmd.stopinsert()
        -- end,
        win = {
          input = {
            keys = {
              ["d"] = "bufdelete",
            },
          },
          list = { keys = { ["d"] = "bufdelete" } },
        },
      }
      ) end, desc = "Buffers" },
    { "<leader>p", function() vim.cmd("SessionSearch") end, desc = "Projects" },
    -- git
    { "<leader>gb", function() require("snacks").picker.git_branches() end, desc = "Git Branches" },
    { "<leader>gl", function() require("snacks").picker.git_log() end, desc = "Git Log" },
    { "<leader>gL", function() require("snacks").picker.git_log_line() end, desc = "Git Log Line" },
    { "<leader>gs", function() require("snacks").picker.git_status() end, desc = "Git Status" },
    { "<leader>gS", function() require("snacks").picker.git_stash() end, desc = "Git Stash" },
    { "<leader>gf", function() require("snacks").picker.git_log_file() end, desc = "Git Log File" },
    { "<leader>gB", function() require("snacks").gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
    { "<leader>gd", function() require("snacks").lazygit() end, desc = "Lazygit" },
    -- search
    { '<leader>s"', function() require("snacks").picker.registers() end, desc = "Registers" },
    { '<leader>s/', function() require("snacks").picker.search_history() end, desc = "Search History" },
    { "<leader>sc", function() require("snacks").picker.command_history() end, desc = "Command History" },
    { "<leader>sC", function() require("snacks").picker.commands() end, desc = "Commands" },
    { "<leader>sd", function() require("snacks").picker.diagnostics() end, desc = "Diagnostics" },
    { "<leader>sD", function() require("snacks").picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
    { "<leader>sh", function() require("snacks").picker.help() end, desc = "Help Pages" },
    { "<leader>sH", function() require("snacks").picker.highlights() end, desc = "Highlights" },
    { "<leader>si", function() require("snacks").picker.icons() end, desc = "Icons" },
    { "<leader>sj", function() require("snacks").picker.jumps() end, desc = "Jumps" },
    { "<leader>sk", function() require("snacks").picker.keymaps() end, desc = "Keymaps" },
    { "<leader>sl", function() require("snacks").picker.loclist() end, desc = "Location List" },
    { "<leader>sm", function() require("snacks").picker.marks() end, desc = "Marks" },
    { "<leader>sM", function() require("snacks").picker.man() end, desc = "Man Pages" },
    { "<leader>sp", function() require("snacks").picker.lazy() end,desc = "Search for Plugin Spec" },
    { "<leader>sq", function() require("snacks").picker.qflist() end, desc = "Quickfix List" },
    { "<leader><leader>", function() require("snacks").picker.resume() end, desc = "Resume picker" },
    { "<leader>su", function() require("snacks").picker.undo() end, desc = "Undo History" },
    { "<leader>uC", function() require("snacks").picker.colorschemes() end, desc = "Colorschemes" },
    -- LSP
    { "gd", function() require("snacks").picker.lsp_definitions() end, desc = "goto definition" },
    { "gD", function() require("snacks").picker.lsp_declarations() end, desc = "Goto Declaration" },
    { "gr", function() require("snacks").picker.lsp_references() end, nowait = true, desc = "References" },
    { "gI", function() require("snacks").picker.lsp_implementations() end, desc = "Goto Implementation" },
    { "gy", function() require("snacks").picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
    -- Other
    { "<leader>d", function() require("snacks").bufdelete() end, desc = "Delete Buffer" },
    { "<leader>un", function() require("snacks").notifier.hide() end, desc = "Dismiss All Notifications" },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          require("snacks").debug.inspect(...)
        end
        _G.bt = function()
          require("snacks").debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        require("snacks").toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        require("snacks").toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        require("snacks").toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        require("snacks").toggle.diagnostics():map("<leader>ud")
        require("snacks").toggle.line_number():map("<leader>ul")
        require("snacks").toggle
          .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
          :map("<leader>uc")
        require("snacks").toggle.treesitter():map("<leader>uT")
        require("snacks").toggle
          .option("background", { off = "light", on = "dark", name = "Dark Background" })
          :map("<leader>ub")
        require("snacks").toggle.inlay_hints():map("<leader>uh")
        require("snacks").toggle.indent():map("<leader>ug")
        require("snacks").toggle.dim():map("<leader>uD")
      end,
    })
  end,
}
