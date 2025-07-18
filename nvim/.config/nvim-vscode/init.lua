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

    -- Setup lazy.nvim with no plugins for VS Code
    require("lazy").setup({
        spec = {
            -- Add your plugins here
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
else
    -- Regular Neovim (fallback, should not be used in VS Code context)
    print("This config is designed for VS Code integration only")
end
