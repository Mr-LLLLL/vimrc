local km = vim.keymap
local g = vim.g

return {
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        lazy = true,
        build = 'make',
    },
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        event = "VeryLazy",
        dependencies = {
            'nvim-telescope/telescope-fzf-native.nvim',
        },
        config = function()
            local glyphs = require("common").glyphs
            local actions = require("telescope.actions")
            require('telescope').setup({
                defaults = {
                    winblend = vim.g.custom_blend + (vim.g.neovide and 20 or 0),
                    mappings = {
                        i = {
                            ["<CR>"] = actions.select_default + actions.center,
                            ["<C-s>"] = actions.select_horizontal + actions.center,
                            ["<C-x>"] = false,
                            ["<C-v>"] = actions.select_vertical + actions.center,
                            ["<C-t>"] = actions.select_tab + actions.center,
                            ["<C-l>"] = false,
                            ["<C-u>"] = false,
                            ["<C-d>"] = false,
                            ["<C-o>"] = function() vim.cmd("stopinsert") end,
                            ["<esc>"] = actions.close,
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-b>"] = actions.results_scrolling_up,
                            ["<C-f>"] = actions.results_scrolling_down,
                            ["<C-n>"] = actions.preview_scrolling_down,
                            ["<C-p>"] = actions.preview_scrolling_up,
                            ["<LeftMouse>"] = actions.select_default + actions.center,
                            ["<RightMouse>"] = actions.close,
                            ["<ScrollWheelDown>"] = actions.move_selection_next,
                            ["<ScrollWheelUp>"] = actions.move_selection_previous,
                        },
                        n = {
                            ["<CR>"] = actions.select_default + actions.center,
                            ["<C-s>"] = actions.select_horizontal + actions.center,
                            ["<C-x>"] = false,
                            ["<C-v>"] = actions.select_vertical + actions.center,
                            ["<C-t>"] = actions.select_tab + actions.center,
                            ["<C-u>"] = false,
                            ["<C-d>"] = false,
                            ["q"] = actions.close,
                            ["<C-b>"] = actions.results_scrolling_up,
                            ["<C-f>"] = actions.results_scrolling_down,
                            ["<C-n>"] = actions.preview_scrolling_down,
                            ["<C-p>"] = actions.preview_scrolling_up,
                            ["<RightMouse>"] = actions.close,
                            ["<LeftMouse>"] = actions.select_default + actions.center,
                            ["<ScrollWheelDown>"] = actions.move_selection_next,
                            ["<ScrollWheelUp>"] = actions.move_selection_previous,
                        }
                    }
                },
                pickers = {
                    oldfiles = {
                        only_cwd = true
                    },
                    builtin = {
                        include_extensions = true
                    },
                    find_files = {
                        no_ignore = true,
                        no_ignore_parent = true,
                    },
                    diagnostics = {
                        mappings = {
                            i = {
                                ["<c-i>"] = require('telescope.actions').complete_tag,
                            },
                        }
                    },
                    current_buffer_fuzzy_find = {
                        skip_empty_lines = true,
                    },
                },
                extensions = {
                    fzf = {
                        fuzzy = true,                   -- false will only do exact matching
                        override_generic_sorter = true, -- override the generic sorter
                        override_file_sorter = true,    -- override the file sorter
                        case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
                        -- the default case_mode is "smart_case"
                    },
                    project = {
                        base_dirs = {
                            "~/study",
                            { path = "~/workspace",              max_depth = 5 },
                            "~/.config",
                            { path = "~/.local/share/nvim/lazy", max_depth = 5 },
                        },
                        hidden_files = false, -- default: false
                        theme = "dropdown",
                        order_by = "recent",
                        search_by = "title",
                        sync_with_nvim_tree = false, -- default false
                    },
                    frecency = {
                        db_safe_mode = false,
                        show_filter_column = false,
                        show_scores = false,
                        show_unindexed = false,
                        disable_devicons = false,
                    },
                    file_browser = {
                        respect_gitignore = false,
                        auto_depth = true,
                        hijack_netrw = true,
                        hide_parent_dir = true,
                        git_icons = {
                            added = glyphs["added"],
                            changed = glyphs["modified"],
                            copied = glyphs["copied"],
                            deleted = glyphs["deleted"],
                            renamed = glyphs["renamed"],
                            unmerged = glyphs["unmerged"],
                            untracked = glyphs["untracked"],
                        },
                        mappings = {
                            i = {
                                ["<CR>"] = require("telescope.actions").select_default,
                                ["<C-s>"] = actions.select_horizontal,
                                ["<C-v>"] = actions.select_vertical,
                                ["<C-t>"] = actions.select_tab,
                            },
                            n = {
                                ["<CR>"] = require("telescope.actions").select_default,
                                ["<C-s>"] = actions.select_horizontal,
                                ["<C-v>"] = actions.select_vertical,
                                ["<C-t>"] = actions.select_tab,
                            },
                        },
                    },
                },
            })

            require("telescope").load_extension("todo-comments")
            require("telescope").load_extension("noice")
            require("telescope").load_extension("notify")

            require('telescope').load_extension('fzf')

            km.set('n', "<space>ss", "<cmd>Telescope<CR>", { noremap = true, silent = true })
            km.set('n', "<space>sp", "<cmd>Telescope resume<CR>", { noremap = true, silent = true })
            km.set('n', "<space>se", "<cmd>Telescope live_grep<CR>", { noremap = true, silent = true })
            km.set('n', "<space>sr", "<cmd>Telescope oldfiles<CR>", { noremap = true, silent = true })
            km.set('n', "<space>sb", "<cmd>Telescope buffers<CR>", { noremap = true, silent = true })
            km.set('n', "<space>sl", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { noremap = true, silent = true })
        end
    },
    {
        'nvim-telescope/telescope-frecency.nvim',
        keys = {
            { "<space>sm", "<cmd>Telescope frecency workspace=CWD<CR>", { noremap = true, silent = true }, desc = "Telescope Frecency File" }
        },
        dependencies = {
            'kkharji/sqlite.lua',
            'nvim-telescope/telescope.nvim',
        },
        config = function()
            require("telescope").load_extension("frecency")
        end
    },
    {
        'nvim-telescope/telescope-file-browser.nvim',
        keys = {
            { "<space>sf", "<cmd>Telescope file_browser<CR>", { noremap = true, silent = true }, desc = "Telescope FileBrowser" }
        },
        dependencies = {
            'nvim-telescope/telescope.nvim',
        },
        config = function()
            require("telescope").load_extension('file_browser')
        end
    },
    {
        'nvim-telescope/telescope-project.nvim',
        event = { "CursorHold" },
        keys = {
            {
                '<space>i',
                require("common").get_tele_project,
                { noremap = true, silent = true },
                desc = "telescope projects"
            }
        },
        dependencies = {
            'nvim-telescope/telescope.nvim',
        },
        config = function()
            require('telescope').load_extension('project')
        end
    },
    {
        'gbprod/yanky.nvim',
        keys = {
            { "<space>sy", "<cmd>Telescope yank_history<CR>", { noremap = true, silent = true }, desc = "Yanky" },
        },
        dependencies = {
            'kkharji/sqlite.lua',
            'nvim-telescope/telescope.nvim',
        },
        config = function()
            local mapping = require("yanky.telescope.mapping")
            local actions = require("telescope.actions")
            require("yanky").setup({
                ring = {
                    storage = "sqlite"
                },
                highlight = {
                    on_put = true,
                    on_yank = false,
                    timer = 500,
                },
                picker = {
                    select = {
                        action = nil, -- nil to use default put action
                    },
                    telescope = {
                        mappings = {
                            i = {
                                ["<c-k>"] = actions.move_selection_previous,
                                ["<c-p>"] = actions.preview_scrolling_up,
                                ["<cr>"] = mapping.put("p"),
                            },
                            n = {
                                ["<cr>"] = mapping.put("p"),
                                ["<c-k>"] = actions.move_selection_previous,
                                ["<c-p>"] = actions.preview_scrolling_up,
                            }
                        }
                    },
                },
            })

            require("telescope").load_extension("yank_history")
        end
    },
}
