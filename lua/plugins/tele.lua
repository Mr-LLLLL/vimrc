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
    {
        'renerocksai/telekasten.nvim',
        dependencies = {
            'renerocksai/calendar-vim',
            'nvim-telescope/telescope.nvim',
        },
        keys = {
            { "<space>z", "<cmd>Telekasten<CR>", { noremap = true, silent = true }, desc = "Telekasten" }
        },
        config = function()
            g.calendar_no_mappings = 1

            local telekasten_home_dir = vim.fn.expand("~/.local/share/nvim/.telekasten")
            require('telekasten').setup({
                home              = telekasten_home_dir,
                -- if true, telekasten will be enabled when opening a note within the configured home
                take_over_my_home = true,
                -- auto-set telekasten filetype: if false, the telekasten filetype will not be used
                --                               and thus the telekasten syntax will not be loaded either
                auto_set_filetype = true,
                -- dir names for special notes (absolute path or subdir name)
                dailies           = telekasten_home_dir .. '/' .. 'daily',
                weeklies          = telekasten_home_dir .. '/' .. 'weekly',
                templates         = telekasten_home_dir .. '/' .. 'templates',
                -- image (sub)dir for pasting
                -- dir name (absolute path or subdir name)
                -- or nil if pasted images shouldn't go into a special subdir
                image_subdir      = "img",
                -- markdown file extension
                extension         = ".md",
                -- Generate note filenames. One of:
                -- "title" (default) - Use title if supplied, uuid otherwise
                -- "uuid" - Use uuid
                -- "uuid-title" - Prefix title by uuid
                -- "title-uuid" - Suffix title with uuid
                new_note_filename = "title",
                --[[ file UUID type
        - "rand"
        - string input for os.date()
        - or custom lua function that returns a string
    --]]
                uuid_type = "%Y%m%d%H%M",
                -- UUID separator
                uuid_sep = "-",
                -- following a link to a non-existing note will create it
                follow_creates_nonexisting = true,
                dailies_create_nonexisting = true,
                weeklies_create_nonexisting = true,
                -- skip telescope prompt for goto_today and goto_thisweek
                journal_auto_open = false,
                -- template for new notes (new_note, follow_link)
                -- set to `nil` or do not specify if you do not want a template
                template_new_note = telekasten_home_dir .. '/' .. 'templates/new_note.md',
                -- template for newly created daily notes (goto_today)
                -- set to `nil` or do not specify if you do not want a template
                template_new_daily = telekasten_home_dir .. '/' .. 'templates/daily.md',
                -- template for newly created weekly notes (goto_thisweek)
                -- set to `nil` or do not specify if you do not want a template
                template_new_weekly = telekasten_home_dir .. '/' .. 'templates/weekly.md',
                -- image link style
                -- wiki:     ![[image name]]
                -- markdown: ![](image_subdir/xxxxx.png)
                image_link_style = "markdown",
                -- default sort option: 'filename', 'modified'
                sort = "filename",
                -- integrate with calendar-vim
                plug_into_calendar = true,
                calendar_opts = {
                    -- calendar week display mode: 1 .. 'WK01', 2 .. 'WK 1', 3 .. 'KW01', 4 .. 'KW 1', 5 .. '1'
                    weeknm = 4,
                    -- use monday as first day of week: 1 .. true, 0 .. false
                    calendar_monday = 1,
                    -- calendar mark: where to put mark for marked days: 'left', 'right', 'left-fit'
                    calendar_mark = 'left-fit',
                },
                -- telescope actions behavior
                close_after_yanking = false,
                insert_after_inserting = true,
                -- tag notation: '#tag', ':tag:', 'yaml-bare'
                tag_notation = "#tag",
                -- command palette theme: dropdown (window) or ivy (bottom panel)
                command_palette_theme = "dropdown",
                -- tag list theme:
                -- get_cursor: small tag list at cursor; ivy and dropdown like above
                show_tags_theme = "dropdown",
                -- when linking to a note in subdir/, create a [[subdir/title]] link
                -- instead of a [[title only]] link
                subdirs_in_links = true,
                -- template_handling
                -- What to do when creating a new note via `new_note()` or `follow_link()`
                -- to a non-existing note
                -- - prefer_new_note: use `new_note` template
                -- - smart: if day or week is detected in title, use daily / weekly templates (default)
                -- - always_ask: always ask before creating a note
                template_handling = "smart",
                -- path handling:
                --   this applies to:
                --     - new_note()
                --     - new_templated_note()
                --     - follow_link() to non-existing note
                --
                --   it does NOT apply to:
                --     - goto_today()
                --     - goto_thisweek()
                --
                --   Valid options:
                --     - smart: put daily-looking notes in daily, weekly-looking ones in weekly,
                --              all other ones in home, except for notes/with/subdirs/in/title.
                --              (default)
                --
                --     - prefer_home: put all notes in home except for goto_today(), goto_thisweek()
                --                    except for notes with subdirs/in/title.
                --
                --     - same_as_current: put all new notes in the dir of the current note if
                --                        present or else in home
                --                        except for notes/with/subdirs/in/title.
                new_note_location = "smart",
                -- should all links be updated when a file is renamed
                rename_update_links = true,
                vaults = {
                    vault2 = {
                        -- alternate configuration for vault2 here. Missing values are defaulted to
                        -- default values from telekasten.
                        -- e.g.
                        -- home = "/home/user/vaults/personal",
                    },
                },
                -- how to preview media files
                -- "telescope-media-files" if you have telescope-media-files.nvim installed
                -- "catimg-previewer" if you have catimg installed
                media_previewer = "telescope-media-files",
                -- A customizable fallback handler for urls.
                follow_url_fallback = nil,
            })
        end
    },
}
