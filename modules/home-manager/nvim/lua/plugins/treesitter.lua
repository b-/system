return {
    "nvim-treesitter/nvim-treesitter",
    dir = require("lazy-nix-helper").get_plugin_path("nvim-treesitter"),
    opts = {
        sync_install = false,
        auto_install = false,
        highlight = {
            enable = true,

            disable = function(lang, buf)
                local max_filesize = 1024 * 1024
                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok and stats and stats.size > max_filesize then
                    return true
                end
            end,

            additional_vim_regex_highlighting = false,
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "gnn",
                node_incremental = "grn",
                scope_incremental = "grc",
                node_decremental = "grm",
            },
        },
        indent = {
            enable = true,
        },

        textobjects = {
            select = {
                enable = true,
                keymaps = {
                    ["af"] = "@function.outer",
                    ["if"] = "@function.inner",
                    ["ac"] = "@class.outer",
                    ["ic"] = "@class.inner",
                },
            },
            move = {
                enable = true,
                goto_next_start = {
                    ["]m"] = "@function.outer",
                    ["]]"] = "@class.outer",
                },
                goto_next_end = {
                    ["]M"] = "@function.outer",
                    ["]["] = "@class.outer",
                },
                goto_previous_start = {
                    ["[m"] = "@function.outer",
                    ["[["] = "@class.outer",
                },
                goto_previous_end = {
                    ["[M"] = "@function.outer",
                    ["[]"] = "@class.outer",
                },
            },
            swap = {
                enable = true,
                swap_next = {
                    ["<leader>a"] = "@parameter.inner",
                },
                swap_previous = {
                    ["<leader>A"] = "@parameter.inner",
                },
            },
        },
        refactor = {
            navigation = {
                enable = true,
                -- Assign keymaps to false to disable them, e.g. `goto_definition = false`.
                keymaps = {
                    goto_definition = "gnd",
                    list_definitions = "gnD",
                    list_definitions_toc = "gO",
                    goto_next_usage = "<a-*>",
                    goto_previous_usage = "<a-#>",
                },
            },
            smart_rename = {
                enable = true,
                -- Assign keymaps to false to disable them, e.g. `smart_rename = false`.
                keymaps = {
                    smart_rename = "grr",
                },
            },
            highlight_definitions = {
                enable = true,
                -- Set to false if you have an `updatetime` of ~100.
                clear_on_cursor_move = true,
            },
        },
    },
    config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
    end,
    dependencies = {
        {
            "nvim-treesitter/nvim-treesitter-refactor",
            dir = require("lazy-nix-helper").get_plugin_path("nvim-treesitter-refactor"),
        },
        {
            "nvim-treesitter/nvim-treesitter-textobjects",
            dir = require("lazy-nix-helper").get_plugin_path("nvim-treesitter-textobjects"),
        },
        {
            "nvim-treesitter/nvim-treesitter-context",
            dir = require("lazy-nix-helper").get_plugin_path("nvim-treesitter-context"),
        },
    },
}
