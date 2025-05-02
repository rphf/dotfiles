return {
  "MagicDuck/grug-far.nvim",
  config = function()
    -- optional setup call to overridce plugin options
    -- alternatively you can set options with vim.g.grug_far = { ... }
    require("grug-far").setup({
      -- options, see Configuration section below
      -- there are no required options atm
      -- engine = 'ripgrep' is default, but 'astgrep' or 'astgrep-rules' can
      -- be specified
    })

    -- Get the Search highlight group
    local search_hl = vim.api.nvim_get_hl(0, { name = "Search" })

    -- Set GrugFarResultsMatch with only the needed fields
    vim.api.nvim_set_hl(0, "GrugFarResultsMatch", {
      fg = search_hl.fg,
      bg = search_hl.bg,
    })
  end,
  keys = {
    {
      "<leader>sr",
      function()
        local grug = require("grug-far")
        local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
        grug.open({
          transient = true,
          prefills = {
            flags = "--fixed-strings --hidden --glob=!**/.git/*",
          },
        })
      end,
      mode = { "n", "v" },
      desc = "Search and Replace",
    },
    {
      "<leader>sR",
      function()
        local grug = require("grug-far")
        local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
        grug.open({
          transient = true,
          prefills = {
            flags = "--fixed-strings --hidden -i",
            paths = vim.fn.expand("%"),
          },
        })
      end,
      mode = { "n", "v" },
      desc = "Search and Replace",
    },
  },
}
