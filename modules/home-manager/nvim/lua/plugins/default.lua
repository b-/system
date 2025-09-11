return {
    {
        "navarasu/onedark.nvim",
        lazy = false,
        dir = require("lazy-nix-helper").get_plugin_path("onedark.nvim"),
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            require("onedark").setup({})
            -- Enable theme
            require("onedark").load()
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        lazy = false,
        opts = {
            options = { theme = "auto" },
            sections = {
                lualine_x = {
                    function()
                        return require("direnv").statusline()
                    end,
                    "encoding",
                    "fileformat",
                    "filetype",
                },
            },
        },
        dir = require("lazy-nix-helper").get_plugin_path("lualine.nvim"),
        dependencies = {
            {
                "nvim-tree/nvim-web-devicons",
                dir = require("lazy-nix-helper").get_plugin_path("nvim-web-devicons"),
            },
        },
    },
    {
        "nvim-tree/nvim-tree.lua",
        opts = {
            renderer = {
                group_empty = true,
            },
            filters = {
                dotfiles = true,
            },
        },
        dir = require("lazy-nix-helper").get_plugin_path("nvim-tree.lua"),
        keys = {
            { "<C-e>", desc = "nvim-tree Open: In Place" },
            { "<C-t>", desc = "nvim tree Open: New Tab" },
            { "<C-v>", desc = "nvim tree Open: Vertical Split" },
            { "<C-x>", desc = "nvim tree Open: Horizontal Split" },
        },
        dependencies = {
            {
                "nvim-tree/nvim-web-devicons",
                dir = require("lazy-nix-helper").get_plugin_path("nvim-web-devicons"),
            },
        },
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        dir = require("lazy-nix-helper").get_plugin_path("indent-blankline.nvim"),
        main = "ibl",
        ---@module "ibl"
        ---@type ibl.config
        opts = {},
    },
    {
        "nmac427/guess-indent.nvim",
        dir = require("lazy-nix-helper").get_plugin_path("guess-indent.nvim"),
        event = "InsertEnter",
    },
    {
        "windwp/nvim-autopairs",
        dir = require("lazy-nix-helper").get_plugin_path("nvim-autopairs"),
        event = "InsertEnter",
        opts = {},
    },
    {
        "tpope/vim-sensible",
        dir = require("lazy-nix-helper").get_plugin_path("vim-sensible"),
    },
    {
        "tpope/vim-fugitive",
        dir = require("lazy-nix-helper").get_plugin_path("vim-fugitive"),
    },
    {
        "tpope/vim-commentary",
        dir = require("lazy-nix-helper").get_plugin_path("vim-commentary"),
    },
    {
        "machakann/vim-sandwich",
        dir = require("lazy-nix-helper").get_plugin_path("vim-sandwich"),
    },
    {
        "NotAShelf/direnv.nvim",
        lazy = false,
        dir = require("lazy-nix-helper").get_plugin_path("direnv.nvim"),
        main = "direnv",
        opts = {
            -- Whether to automatically load direnv when entering a directory with .envrc
            autoload_direnv = false,

            -- Statusline integration
            statusline = {
                -- Enable statusline component
                enabled = true,
                -- Icon to display in statusline
                icon = "󱚟",
            },
            keybindings = {
                allow = "<Leader>da",
                deny = "<Leader>dd",
                reload = "<Leader>dr",
                edit = "<Leader>de",
            },
        },
    },
    {
        "kelly-lin/ranger.nvim",
        dir = require("lazy-nix-helper").get_plugin_path("ranger.nvim"),
    },
}
