local km = vim.keymap

return {
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        lazy = true,
        build = 'make',
    },
    {
        'nvim-telescope/telescope.nvim',
        event = "VeryLazy",
        dependencies = {
            'nvim-telescope/telescope-fzf-native.nvim',
            "tsakirist/telescope-lazy.nvim",
        },
        config = function()
            local glyphs = require("common").glyphs
            local actions = require("telescope.actions")
            require('telescope').setup({
                defaults = {
                    path_display = {
                        filename_first = {
                            reverse_directories = false
                        }
                    },
                    winblend = vim.g.custom_blend,
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
                            ["<m-f>"] = false,
                            -- ["<C-o>"] = functioc(c vim.cmd("stopinsert") end,
                            -- ["<esc>"] = actions.close,
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-b>"] = actions.results_scrolling_up,
                            ["<C-f>"] = actions.results_scrolling_down,
                            ["<m-k>"] = actions.results_scrolling_right,
                            ["<m-j>"] = actions.results_scrolling_left,
                            ["<C-n>"] = actions.preview_scrolling_down,
                            ["<C-p>"] = actions.preview_scrolling_up,
                            ["<m-n>"] = actions.preview_scrolling_left,
                            ["<m-p>"] = actions.preview_scrolling_right,
                            ["<LeftMouse>"] = actions.select_default + actions.center,
                            ["<RightMouse>"] = actions.close,
                            ["<ScrollWheelDown>"] = actions.move_selection_next,
                            ["<ScrollWheelUp>"] = actions.move_selection_previous,
                            ["<m-s>"] = function() vim.cmd("Telescope") end,
                        },
                        n = {
                            ["q"] = actions.close,
                            ["<CR>"] = actions.select_default + actions.center,
                            ["<C-s>"] = actions.select_horizontal + actions.center,
                            ["<C-x>"] = false,
                            ["<C-v>"] = actions.select_vertical + actions.center,
                            ["<C-t>"] = actions.select_tab + actions.center,
                            ["<C-u>"] = false,
                            ["<C-d>"] = false,
                            ["<C-c>"] = actions.close,
                            ["<C-b>"] = actions.results_scrolling_up,
                            ["<C-f>"] = actions.results_scrolling_down,
                            ["<m-k>"] = actions.results_scrolling_right,
                            ["<m-j>"] = actions.results_scrolling_left,
                            ["<C-n>"] = actions.preview_scrolling_down,
                            ["<C-p>"] = actions.preview_scrolling_up,
                            ["<m-n>"] = actions.preview_scrolling_left,
                            ["<m-p>"] = actions.preview_scrolling_right,
                            ["<RightMouse>"] = actions.close,
                            ["<LeftMouse>"] = actions.select_default + actions.center,
                            ["<ScrollWheelDown>"] = actions.move_selection_next,
                            ["<ScrollWheelUp>"] = actions.move_selection_previous,
                            ["<m-s>"] = function() vim.cmd("Telescope") end,
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
                        recency_values = {
                            { age = 10,     value = 200 },
                            { age = 30,     value = 160 },
                            { age = 60,     value = 140 },
                            { age = 120,    value = 120 },
                            { age = 240,    value = 100 }, -- past 4 hours
                            { age = 1440,   value = 80 },  -- past day
                            { age = 4320,   value = 60 },  -- past 3 days
                            { age = 10080,  value = 40 },  -- past week
                            { age = 43200,  value = 20 },  -- past month
                            { age = 129600, value = 10 },  -- past 90 days
                        },
                        db_safe_mode = false,
                        show_filter_column = false,
                        matcher = "fuzzy",
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
                    lazy = {
                        mappings = {
                            open_in_browser = "<C-o>",
                            open_in_file_browser = "<cr>",
                            open_in_find_files = "<c-d>",
                            open_in_live_grep = "<C-e>",
                            open_in_terminal = "<c-t>",
                            open_plugins_picker = "<m-s>", -- Works only after having called first another action
                            open_lazy_root_find_files = "<C-r>f",
                            open_lazy_root_live_grep = "<C-r>e",
                            change_cwd_to_plugin = "<c-d>",
                        },
                        actions_opts = {
                            open_in_browser = {
                                -- Close the telescope window after the action is executed
                                auto_close = true,
                            },
                            change_cwd_to_plugin = {
                                -- Close the telescope window after the action is executed
                                auto_close = false,
                            },
                        },
                    },
                },
            })

            km.set('n', "<space>ss", "<cmd>Telescope<CR>", { noremap = true, silent = true })
            km.set('n', "<space>sp", "<cmd>Telescope resume<CR>", { noremap = true, silent = true })
            km.set('n', "<space>se", "<cmd>Telescope live_grep<CR>", { noremap = true, silent = true })
            km.set('n', "<space>sr", "<cmd>Telescope oldfiles<CR>", { noremap = true, silent = true })
            km.set('n', "<space>sb", "<cmd>Telescope buffers<CR>", { noremap = true, silent = true })
            km.set('n', "<space>sl", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { noremap = true, silent = true })

            require("telescope").load_extension("fzf")
            require("telescope").load_extension("lazy")
        end
    },
    {
        "ryanmsnyder/toggleterm-manager.nvim",
        dependencies = {
            "akinsho/toggleterm.nvim",
            "nvim-telescope/telescope.nvim",
            "nvim-lua/plenary.nvim", -- only needed because it's a dependency of telescope
        },
        keys = {
            { "<space>st", "<cmd>Telescope toggleterm_manager<cr>", { noremap = true, silent = true }, desc = "Telescope Toggleterm" }
        },
        config = function()
            local toggleterm_manager = require("toggleterm-manager")
            local actions = toggleterm_manager.actions
            require("toggleterm-manager").setup {
                mappings = {
                    i = {
                        ["<CR>"] = { action = actions.open_term, exit_on_action = true }, -- toggles terminal open/closed
                    },
                }
            }
        end,
    },
    {
        -- 'Mr-LLLLL/telescope-frecency.nvim',
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
        'Mr-LLLLL/telescope-file-browser.nvim',
        -- 'nvim-telescope/telescope-file-browser.nvim',
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
