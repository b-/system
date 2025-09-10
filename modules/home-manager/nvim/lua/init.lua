---@diagnostic disable-next-line: undefined-global
local lazy_nix_helper_path = lazy_nix_helper_path or "/dev/null"
if not (vim.uv or vim.loop).fs_stat(lazy_nix_helper_path) then
    lazy_nix_helper_path = vim.fn.stdpath("data") .. "/lazy_nix_helper/lazy_nix_helper.nvim"
    if not vim.loop.fs_stat(lazy_nix_helper_path) then
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/b-src/lazy_nix_helper.nvim.git",
            lazy_nix_helper_path,
        })
    end
end

-- add the Lazy Nix Helper plugin to the vim runtime
vim.opt.rtp:prepend(lazy_nix_helper_path)

---@diagnostic disable-next-line: undefined-global
local plugins = plugins or {}
-- call the Lazy Nix Helper setup function
local non_nix_lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazy_nix_helper_opts = { lazypath = non_nix_lazypath, input_plugin_table = plugins }
local lazy_nix_helper = require("lazy-nix-helper")
lazy_nix_helper.setup(lazy_nix_helper_opts)

-- get the lazypath from Lazy Nix Helper
local lazypath = lazy_nix_helper.lazypath()
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)
-- General Vim settings
vim.opt.number = true
vim.opt.wrap = true
vim.opt.encoding = "utf-8"
vim.opt.wildmenu = true
vim.opt.lazyredraw = true
vim.opt.ruler = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.showmatch = true
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.autoindent = true
vim.opt.smartindent = false
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.foldenable = false

function vim.fn.stripTrailingWhitespace()
    local l = vim.fn.line(".")
    local c = vim.fn.col(".")
    vim.cmd("%s/\\s\\+$//e")
    vim.fn.cursor(l, c)
end

-- strip all files by default
vim.cmd("autocmd BufWritePre * :lua vim.fn.stripTrailingWhitespace()")

-- Functional wrapper for mapping custom keybindings
function map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts or {})
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end
vim.api.nvim_set_keymap("n", "j", "gj", {})
vim.api.nvim_set_keymap("n", "k", "gk", {})

-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        -- import your plugins
        { import = "plugins" },
    },
    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    install = { colorscheme = { "one" } },
    -- automatically check for plugin updates
    checker = { enabled = false },
})
