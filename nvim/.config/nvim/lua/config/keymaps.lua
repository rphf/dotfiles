-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Move line up and down using J an K in visual mode
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up", silent = true })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down", silent = true })

-- Indent selected text using Tab and Shift Tab
vim.api.nvim_set_keymap("v", "<Tab>", ">gv", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<S-Tab>", "<gv", { noremap = true, silent = true })

-- Write file (save) with leader + w in normal mode
vim.keymap.set("n", "<leader>w", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows

--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason" })

-- Toggle mini.files explorer on the current buffer's directory or project root
vim.keymap.set("n", "<leader>e", function()
  local mini_files = require("mini.files")

  -- If mini.files is already open, close it
  if mini_files.close() then
    return
  end

  local current_buffer = vim.api.nvim_get_current_buf()
  local current_file = vim.api.nvim_buf_get_name(current_buffer)
  local current_dir = current_file ~= "" and vim.fn.fnamemodify(current_file, ":h") or vim.loop.cwd()

  -- Open mini.files at the current directory or project root
  mini_files.open(current_dir)
end, { desc = "File explorer" })
