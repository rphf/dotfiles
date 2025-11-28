-- Lightweight Neovim config specifically for VS Code integration
-- This config is minimal and focused on enhancing the VS Code experience

-- Disable unused providers for performance
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0

-- Basic options
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Leader key (setup before lazy.nvim)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- VS Code specific settings
if vim.g.vscode then
    -- Bootstrap lazy.nvim
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
        if vim.v.shell_error ~= 0 then
            vim.api.nvim_echo({
                { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
                { out,                            "WarningMsg" },
                { "\nPress any key to exit..." },
            }, true, {})
            vim.fn.getchar()
            os.exit(1)
        end
    end
    vim.opt.rtp:prepend(lazypath)

    -- Setup lazy.nvim with VSCode-specific plugins
    require("lazy").setup({
        spec = {
            -- Official vscode-multi-cursor plugin
            {
                'vscode-neovim/vscode-multi-cursor.nvim',
                event = 'VeryLazy',
                cond = not not vim.g.vscode,
                opts = {},
            },
        },
        -- Configure settings
        install = { colorscheme = { "habamax" } },
        checker = { enabled = false }, -- Disable update checker for minimal setup
        performance = {
            rtp = {
                disabled_plugins = {
                    "gzip",
                    "matchit",
                    "matchparen",
                    "netrwPlugin",
                    "tarPlugin",
                    "tohtml",
                    "tutor",
                    "zipPlugin",
                },
            },
        },
    })
    -- Multi-cursor support using official vscode-multi-cursor.nvim plugin
    -- Using the "Wrapped VSCode commands" approach from the official docs

    -- Ctrl+D implementation using the wrapped command
    vim.keymap.set({ "n", "x", "i" }, "<C-d>", function()
        require("vscode-multi-cursor").addSelectionToNextFindMatch()
    end, { desc = "Add selection to next find match" })

    -- Cmd+D for Mac users
    vim.keymap.set({ "n", "x", "i" }, "<D-d>", function()
        require("vscode-multi-cursor").addSelectionToNextFindMatch()
    end, { desc = "Add selection to next find match" })

    -- Additional useful multi-cursor commands from the plugin
    vim.keymap.set({ "n", "x", "i" }, "<C-S-d>", function()
        require("vscode-multi-cursor").addSelectionToPreviousFindMatch()
    end, { desc = "Add selection to previous find match" })

    vim.keymap.set({ "n", "x", "i" }, "<C-S-l>", function()
        require("vscode-multi-cursor").selectHighlights()
    end, { desc = "Select all highlights (Ctrl+Shift+L)" })

    -- Add autocmd for markdown wrapped line navigation
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        vim.keymap.set("n", "j", "gj", { buffer = true, remap = true })
        vim.keymap.set("n", "k", "gk", { buffer = true, remap = true })
        vim.keymap.set("v", "j", "gj", { buffer = true, remap = true })
        vim.keymap.set("v", "k", "gk", { buffer = true, remap = true })
      end,
    })

    -- Notification to confirm config is loaded
    vim.notify("vscode-multi-cursor.nvim plugin loaded!", vim.log.levels.INFO)
else
    -- Regular Neovim (fallback, should not be used in VS Code context)
    print("This config is designed for VS Code integration only")
end
