vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`

vim.opt.swapfile = false

-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = false

-- Enable mouse mode, can be useful for resizing splits
vim.opt.mouse = "a"

-- Disable the line, column and % position of the cursor
vim.opt.ruler = false

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- Enable break indent
--[[ 
    Every wrapped line will continue visually indented (same amount of
    space as the beginning of that line), thus preserving horizontal blocks
    of text. 
--]]
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 500

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Use spaces instead of tabs
vim.opt.expandtab = true
-- Number of spaces for each indentation level
vim.opt.shiftwidth = 2
-- Number of spaces per Tab character (set to 8 for compatibility with other tools)
vim.opt.tabstop = 8
-- Number of spaces inserted when pressing <Tab>
vim.opt.softtabstop = 2

-- Preview substitutions live, as you type
vim.opt.inccommand = "split"

-- Hide command bar (also done by noice.nvim)
vim.opt.cmdheight = 0

-- Show diagnostic inline
vim.diagnostic.config({ virtual_text = true })

vim.api.nvim_set_hl(0, "CursorLine", { cterm = {}, ctermbg = "", bg = "none" })

-- Minimal number of screen lines to keep above and below the cursor.
-- Keeps the cursor always in the middle
vim.opt.scrolloff = 30

vim.opt.fillchars:append("diff:╱")

-- NOTE: I don't actually know what it does, it was required by auto-session.nvim
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

vim.filetype.add({
  extension = {
    jsonjbuilder = "ruby", -- Treat .json.builder as Ruby for treesitter to highlight them correctly
  },
})

-- Only run if we are inside neovide GUI
if vim.g.neovide then
  vim.g.neovide_theme = "tokyonight"
  vim.o.guifont = "JetBrainsMonoNL Nerd Font Mono"
  vim.g.neovide_scale_factor = 0.9
  -- vim.g.neovide_normal_opacity = 1
  -- vim.g.neovide_transparency = 1
  vim.g.neovide_padding_left = 8
  vim.g.experimental_layer_grouping = true
  vim.g.neovide_floating_blur_amount_x = 15.0
  vim.g.neovide_floating_blur_amount_y = 15.0
  vim.g.neovide_window_blurred = true
  vim.g.neovide_refresh_rate = 120
  vim.g.neovide_refresh_rate_idle = 1
  vim.g.neovide_profiler = false
  vim.g.neovide_input_macos_option_key_is_meta = "only_left"
  vim.g.neovide_cursor_animation_length = 0.01
  vim.g.neovide_cursor_trail_size = 0.85

  -- -- Doesn't seem to work
  -- vim.g.neovide_text_gamma = 0.1
  -- vim.g.neovide_text_contrast = 0.0

  vim.keymap.set("n", "<D-s>", ":w<CR>") -- Save
  vim.keymap.set("v", "<D-c>", '"+y') -- Copy
  vim.keymap.set({ "n", "v" }, "<D-v>", '"+P') -- Paste normal and visual mode
  vim.keymap.set({ "i", "c" }, "<D-v>", "<C-R>+") -- Paste insert and command mode
  vim.keymap.set("t", "<D-v>", [[<C-\><C-N>"+P]]) -- Paste terminal mode
end
