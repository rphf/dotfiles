return {
  "nvim-neotest/neotest",
  lazy = true,
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "olimorris/neotest-rspec",
  },
  keys = {
    { "<leader>tn", "<cmd>lua require('neotest').run.run()<cr>", desc = "Run nearest test" },
    { "<leader>tl", "<cmd>lua require('neotest').run.run_last()<cr>", desc = "Run last test" },
    { "<leader>ts", "<cmd>lua require('neotest').summary.toggle()<cr>", desc = "Toggle test summary" },
    { "<leader>tS", "<cmd>require('neotest').run.stop()<cr>", desc = "Stop test run" },
    { "<leader>tt", "<cmd>require('neotest').run.run(vim.fn.expand(' % '))<cr>", desc = "Run the current file" },
    { "<leader>to", "<cmd>lua require('neotest').output_panel.toggle()<cr>", desc = "Toggle test output panel" },
    { "<leader>tp", "<cmd>lua require('neotest').output.open()<cr>", desc = "Preview test output" },
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-rspec")({
          rspec_cmd = function()
            return vim.list_extend({}, {
              "env",
              "SPEC_HEADLESS=1",
              "bundle",
              "exec",
              "rspec",
            })
          end,
        }),
      },
      benchmark = {
        enabled = true,
      },
      consumers = {},
      default_strategy = "integrated",
      diagnostic = {
        enabled = true,
        severity = 1,
      },
      discovery = {
        concurrent = 0,
        enabled = true,
        filter_dir = function(name, _rel_path, _root)
          return name ~= "dist" and name ~= "node_modules" and name ~= "vendor"
        end,
      },
      floating = {
        border = "rounded",
        max_height = 0.6,
        max_width = 0.6,
        options = {},
      },
      highlights = {
        adapter_name = "NeotestAdapterName",
        border = "NeotestBorder",
        dir = "NeotestDir",
        expand_marker = "NeotestExpandMarker",
        failed = "NeotestFailed",
        file = "NeotestFile",
        focused = "NeotestFocused",
        indent = "NeotestIndent",
        marked = "NeotestMarked",
        namespace = "NeotestNamespace",
        passed = "NeotestPassed",
        running = "NeotestRunning",
        select_win = "NeotestWinSelect",
        skipped = "NeotestSkipped",
        target = "NeotestTarget",
        test = "NeotestTest",
        unknown = "NeotestUnknown",
        watching = "NeotestWatching",
      },
      icons = {
        child_indent = "│",
        child_prefix = "├",
        collapsed = "─",
        expanded = "╮",
        failed = "",
        final_child_indent = " ",
        final_child_prefix = "╰",
        non_collapsible = "─",
        notify = "",
        passed = "",
        running = "",
        running_animated = { "/", "|", "\\", "-", "/", "|", "\\", "-" },
        skipped = "",
        unknown = "",
        watching = "",
      },
      jump = {
        enabled = true,
      },
      log_level = 3,
      output = {
        enabled = true,
        open_on_run = "short",
      },
      output_panel = {
        enabled = true,
        open = "botright split | resize 15",
      },
      projects = {},
      quickfix = {
        enabled = true,
        open = false,
      },
      run = {
        enabled = true,
      },
      running = {
        concurrent = true,
      },
      state = {
        enabled = true,
      },
      status = {
        enabled = true,
        signs = true,
        virtual_text = false,
      },
      strategies = {
        integrated = {
          height = 40,
          width = 120,
        },
      },
      summary = {
        animated = true,
        count = true,
        enabled = true,
        expand_errors = true,
        follow = true,
        mappings = {
          attach = "a",
          clear_marked = "M",
          clear_target = "T",
          debug = "d",
          debug_marked = "D",
          expand = { "<CR>", "<2-LeftMouse>" },
          expand_all = "e",
          help = "?",
          jumpto = "i",
          mark = "m",
          next_failed = "J",
          output = "o",
          prev_failed = "K",
          run = "r",
          run_marked = "R",
          short = "O",
          stop = "u",
          target = "t",
          watch = "w",
        },
        open = "botright vsplit | vertical resize 50",
      },
      watch = { enabled = false, symbol_queries = {} },
    })
  end,
}
