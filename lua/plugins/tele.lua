local km = vim.keymap
local fn = vim.fn
local uv = vim.uv

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
            -- 'nvim-telescope/telescope-file-browser.nvim',
            'Mr-LLLLL/telescope-file-browser.nvim',
        },
        config = function()
            local glyphs = require("common").glyphs
            local actions = require("telescope.actions")
            local builtin = require("telescope.builtin")
            local fb_actions = require("telescope._extensions.file_browser.actions")
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
                            ["<c-i>"] = require('telescope.actions').complete_tag,
                            ["<C-d>"] = false,
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
                            ["<m-f>"] = function() builtin.builtin() end,
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
                            ["<m-f>"] = function() builtin.builtin() end,
                        }
                    }
                },
                pickers = {
                    buffers = {
                        mappings = {
                            i = {
                                ["<M-s>"] = function()
                                    local cwd = vim.loop.cwd()
                                    require("common").get_tele_smartfile()
                                    uv.chdir(cwd)
                                end,
                            }
                        },
                        only_cwd = true,
                    },
                    oldfiles = {
                        only_cwd = true,
                        mappings = {
                            i = {
                                ["<M-s>"] = function()
                                    local cwd = vim.loop.cwd()
                                    builtin.buffers({ cwd = cwd })
                                    uv.chdir(cwd)
                                end
                            }
                        }
                    },
                    lsp_document_symbols = {
                        mappings = {
                            i = {
                                ["<M-s>"] = function(opt)
                                    local cwd = vim.loop.cwd()
                                    actions.close(opt)
                                    builtin.current_buffer_fuzzy_find()
                                    uv.chdir(cwd)
                                end
                            }
                        }
                    },
                    lsp_dynamic_workspace_symbols = {
                        mappings = {
                            i = {
                                ["<M-s>"] = function()
                                    local cwd = vim.loop.cwd()
                                    builtin.live_grep({ cmd = cwd })
                                    uv.chdir(cwd)
                                end
                            }
                        }
                    },
                    live_grep = {
                        mappings = {
                            i = {
                                ["<c-g>"] = function()
                                    local parent_path = fn.fnamemodify(uv.cwd(), ":h")
                                    uv.chdir(parent_path)
                                    vim.notify(parent_path)
                                    builtin.live_grep()
                                end,
                                ["<M-s>"] = function(opt)
                                    local cwd = vim.loop.cwd()
                                    actions.close(opt)
                                    builtin.lsp_dynamic_workspace_symbols()
                                    uv.chdir(cwd)
                                end,
                            }
                        }
                    },
                    builtin = {
                        include_extensions = true
                    },
                    find_files = {
                        no_ignore = true,
                        no_ignore_parent = true,
                        mappings = {
                            i = {
                                ["<M-s>"] = function()
                                    local cwd = vim.loop.cwd()
                                    require("telescope").extensions.file_browser.file_browser({ cwd = cwd })
                                    uv.chdir(cwd)
                                end,
                            }
                        }
                    },
                    current_buffer_fuzzy_find = {
                        skip_empty_lines = true,
                        mappings = {
                            i = {
                                ["<M-s>"] = function(opt)
                                    local cwd = vim.loop.cwd()
                                    actions.close(opt)
                                    builtin.lsp_document_symbols()
                                    uv.chdir(cwd)
                                end,
                            }
                        }
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
                    -- frecency = {
                    --     recency_values = {
                    --         { age = 10,     value = 200 },
                    --         { age = 30,     value = 160 },
                    --         { age = 60,     value = 140 },
                    --         { age = 120,    value = 120 },
                    --         { age = 240,    value = 100 }, -- past 4 hours
                    --         { age = 1440,   value = 80 },  -- past day
                    --         { age = 4320,   value = 60 },  -- past 3 days
                    --         { age = 10080,  value = 40 },  -- past week
                    --         { age = 43200,  value = 20 },  -- past month
                    --         { age = 129600, value = 10 },  -- past 90 days
                    --     },
                    --     db_safe_mode = false,
                    --     show_filter_column = false,
                    --     matcher = "fuzzy",
                    --     show_scores = false,
                    --     show_unindexed = false,
                    --     disable_devicons = false,
                    -- },
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
                                ["<CR>"] = function(opt)
                                    actions.select_default(opt)
                                    actions.center(opt)
                                end,
                                ["<C-s>"] = function(opt)
                                    actions.select_horizontal(opt)
                                    actions.center(opt)
                                end,
                                ["<C-v>"] = function(opt)
                                    actions.select_vertical(opt)
                                    actions.center(opt)
                                end,
                                ["<C-t>"] = function(opt)
                                    actions.select_tab(opt)
                                    actions.center(opt)
                                end,
                                ["<M-a>"] = fb_actions.create,
                                ["<M-s>"] = function()
                                    local cwd = vim.loop.cwd()
                                    builtin.find_files({ cwd = cwd })
                                    uv.chdir(cwd)
                                end,
                            },
                            n = {
                                ["a"] = fb_actions.create,
                                ["<CR>"] = function(opt)
                                    actions.select_default(opt)
                                    actions.center(opt)
                                end,
                                ["<C-s>"] = function(opt)
                                    actions.select_horizontal(opt)
                                    actions.center(opt)
                                end,
                                ["<C-v>"] = function(opt)
                                    actions.select_vertical(opt)
                                    actions.center(opt)
                                end,
                                ["<C-t>"] = function(opt)
                                    actions.select_tab(opt)
                                    actions.center(opt)
                                end,
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

            km.set('n', "<space>ss", builtin.builtin, { noremap = true, silent = true, desc = "Telescope" })
            km.set('n', "<space>sp", builtin.resume, { noremap = true, silent = true, desc = "Telescope Resume" })
            km.set('n', "<space>se", builtin.live_grep, { noremap = true, silent = true, desc = "Telescope LiveGrep" })
            km.set('n', "<space>sf",
                function()
                    require("telescope").extensions.file_browser.file_browser({ path = "%:p:h", select_buffer = true })
                end,
                { noremap = true, silent = true, desc = "Telescope FileBrowser" })

            require("telescope").load_extension("fzf")
            require("telescope").load_extension("lazy")
            require("telescope").load_extension('file_browser')
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
        "Mr-LLLLL/smart-open.nvim",
        branch = "0.2.x",
        keys = {
            {
                "<space>sl",
                require("common").get_tele_smartfile,
                { noremap = true, silent = true },
                desc = "Telescope Smart File"
            }
        },
        config = function()
            require("telescope").load_extension("smart_open")
        end,
        dependencies = {
            "kkharji/sqlite.lua",
        },
    },
    -- {
    --     -- 'Mr-LLLLL/telescope-frecency.nvim',
    --     'nvim-telescope/telescope-frecency.nvim',
    --     keys = {
    --         {
    --             "<space>sl",
    --             require("common").get_tele_frecency,
    --             { noremap = true, silent = true },
    --             desc = "Telescope Frecency File"
    --         }
    --     },
    --     dependencies = {
    --         'nvim-telescope/telescope.nvim',
    --     },
    --     config = function()
    --         require("telescope").load_extension("frecency")
    --         vim.api.nvim_set_hl(0, "TelescopePathSeparator", { link = 'NonText' })
    --     end
    -- },
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
            'nvim-telescope/telescope.nvim',
        },
        config = function()
            local mapping = require("yanky.telescope.mapping")
            local actions = require("telescope.actions")
            require("yanky").setup({
                ring = {
                    storage = "shada"
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
