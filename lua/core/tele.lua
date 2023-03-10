local km = vim.keymap

local mod = {}

local function load_telescope()
    local glyphs = require("core.common").glyphs
    local actions = require("telescope.actions")
    require('telescope').setup({
        defaults = {
            winblend = 20,
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
                        ["<C-o>"] = { "<esc>", type = "command" },
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
                    { path = "~/.local/share/nvim/site", max_depth = 5 },
                    "~/Documents",
                },
                hidden_files = false, -- default: false
                theme = "dropdown",
                order_by = "recent",
                search_by = "title",
                sync_with_nvim_tree = false, -- default false
            },
            bookmarks = {
                -- Available:
                --  * 'brave'
                --  * 'brave_beta'
                --  * 'buku'
                --  * 'chrome'
                --  * 'chrome_beta'
                --  * 'edge'
                --  * 'firefox'
                --  * 'qutebrowser'
                --  * 'safari'
                --  * 'vivaldi'
                --  * 'waterfox'
                selected_browser = 'chrome',
                -- Either provide a shell command to open the URL
                url_open_command = 'open',
                -- Or provide the plugin name which is already installed
                -- Available: 'vim_external', 'open_browser'
                url_open_plugin = 'open_browser',
                -- Show the full path to the bookmark instead of just the bookmark name
                full_path = true,
                -- Provide a custom profile name for Firefox browser
                firefox_profile_name = nil,
                -- Provide a custom profile name for Waterfox browser
                waterfox_profile_name = nil,
                -- Add a column which contains the tags for each bookmark for buku
                buku_include_tags = false,
                -- Provide debug messages
                debug = false,
            },
            frecency = {
                show_filter_column = false,
                show_scores = false,
                show_unindexed = false,
                ignore_patterns = { "*.git/*", "*/tmp/*" },
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

    require('telescope').load_extension('project')
    require("telescope").load_extension("frecency")
    require('telescope').load_extension('fzf')
    require('telescope').load_extension('bookmarks')
    require("telescope").load_extension('file_browser')

    km.set('n', "<space>ss", "<cmd>Telescope<CR>", { noremap = true, silent = true })
    km.set('n', "<space>sp", "<cmd>Telescope resume<CR>", { noremap = true, silent = true })
    km.set('n', "<space>se", "<cmd>Telescope live_grep<CR>", { noremap = true, silent = true })
    km.set('n', "<space>sm", "<cmd>Telescope frecency workspace=CWD<CR>", { noremap = true, silent = true })
    km.set('n', "<space>sr", "<cmd>Telescope oldfiles<CR>", { noremap = true, silent = true })
    km.set('n', "<space>sf", "<cmd>Telescope file_browser<CR>", { noremap = true, silent = true })
    km.set('n', "<space>sb", "<cmd>Telescope buffers<CR>", { noremap = true, silent = true })
    km.set('n', "<space>sl", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { noremap = true, silent = true })

    km.set('n', '<space>i', require("core.common").get_tele_project, { noremap = true, silent = true })
end


local function load_yanky()
    local mapping = require("yanky.telescope.mapping")
    local actions = require("telescope.actions")
    require("yanky").setup({
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
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-p>"] = actions.preview_scrolling_up,
                            ["<cr>"] = mapping.put("p"),
                    },
                    n = {
                            ["<cr>"] = mapping.put("p"),
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-p>"] = actions.preview_scrolling_up,
                    }
                }
            },
        },
    })

    require("telescope").load_extension("yank_history")
end

-- auto chenge dir for workspace
local function load_penvim()
    require("penvim").setup({
        rooter = {
            enable = true, -- enable/disable rooter
            patterns = { '.git' }
        },
        indentor = {
            enable = false,    -- enable/disable indentor
            indent_length = 4, -- tab indent width
            accuracy = 5,      -- positive integer. higher the number, the more accurate result (but affects the startup time)
            disable_types = {
                'help', 'dashboard', 'dashpreview', 'NvimTree', 'vista', 'sagahover', 'terminal',
            },
        },
        project_env = {
            enable = false,               -- enable/disable project_env
            config_name = '.__nvim__.lua' -- config file name
        },
    })
end

mod.setup = function()
    load_telescope()
    load_yanky()
    load_penvim()
end

return mod
