local km = vim.keymap
local g = vim.g

local m = {}

local function load_pantran()
    local pantran_actions = require("pantran.ui.actions")
    require("pantran").setup {
        -- Default engine to use for translation. To list valid engine names run
        -- `:lua =vim.tbl_keys(require("pantran.engines"))`.
        default_engine = "google",
        -- Configuration for individual engines goes here.
        window = {
            window_config = {
                border = "rounded"
            },
        },
        engines = {
            google = {
                -- Default languages can be defined on a per engine basis. In this case
                -- `:lua vim.pretty_print(require("pantran.engines").google:languages())
                default_source = "auto",
                default_target = "zh-CN",
                fallback = {
                    default_source = "auto",
                    default_target = "zh-CN",
                }
            },
        },
        controls = {
            mappings = {
                edit = {
                    n = {
                        -- Use this table to add additional mappings for the normal mode in
                        -- the translation window. Either strings or function references are
                        -- supported.
                        ["q"] = pantran_actions.close,
                        ["<C-a>"] = pantran_actions.append_close_translation,
                        ["<C-r>"] = pantran_actions.replace_close_translation,
                        ["<C-s>"] = pantran_actions.select_source,
                        ["<C-t>"] = pantran_actions.select_target,
                        ["<C-e>"] = pantran_actions.select_engine,
                    },
                    i = {
                        -- Similar table but for insert mode. Using 'false' disables
                        -- existing keybindings.
                        ["<esc>"] = function(ui)
                            pantran_actions.close(ui)
                            vim.cmd("stopinsert")
                        end,
                        ["<c-o>"] = function()
                            vim.cmd("stopinsert")
                        end,
                        ["<C-r>"] = pantran_actions.replace_close_translation,
                        ["<C-a>"] = pantran_actions.append_close_translation,
                        ["<C-s>"] = pantran_actions.select_source,
                        ["<C-t>"] = pantran_actions.select_target,
                        ["<C-e>"] = pantran_actions.select_engine,
                    }
                },
                -- Keybindings here are used in the selection window.
                select = {
                    i = {
                        ["<C-s>"] = pantran_actions.select_source,
                        ["<C-t>"] = pantran_actions.select_target,
                        ["<C-e>"] = pantran_actions.select_engine,
                    },
                    n = {
                        ["<C-s>"] = pantran_actions.select_source,
                        ["<C-t>"] = pantran_actions.select_target,
                        ["<C-e>"] = pantran_actions.select_engine,
                    }
                }
            }
        },
    }

    vim.api.nvim_set_hl(0, "PantranBorder", { link = 'CustomBorder' })
    km.set('n', "<space>to", "<cmd>Pantran<CR>i", { noremap = true, silent = true })
    km.set("n", "<space>tt", function() return require("pantran").motion_translate() .. "iw" end,
        { noremap = true, silent = true, expr = true })
    km.set("x", "<space>tt", require("pantran").motion_translate, { noremap = true, silent = true, expr = true })
end

local function load_rest()
    require("rest-nvim").setup({
        -- Open request results in a horizontal split
        result_split_horizontal = false,
        -- Keep the http file buffer above|left when split horizontal|vertical
        result_split_in_place = false,
        -- Skip SSL verification, useful for unknown certificates
        skip_ssl_verification = true,
        -- Encode URL before making request
        encode_url = false,
        -- Highlight request on run
        highlight = {
            enabled = true,
            timeout = 150,
        },
        result = {
            -- toggle showing URL, HTTP info, headers at top the of result window
            show_url = true,
            show_http_info = true,
            show_headers = true,
            -- executables or functions for formatting response body [optional]
            -- set them to nil if you want to disable them
            formatters = {
                json = "jq",
                html = function(body)
                    return vim.fn.system({ "tidy", "-i", "-q", "-" }, body)
                end
            },
        },
        -- Jump to request line on run
        jump_to_request = false,
        env_file = '.env',
        custom_dynamic_variables = {},
        yank_dry_run = true,
    })

    km.set('n', "<leader>cc", "<Plug>RestNvim", { noremap = true, silent = true })
    km.set('n', "<leader>cp", "<Plug>RestNvimPreview", { noremap = true, silent = true })
end

local function load_telekasten()
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

    km.set('n', "<space>z", "<cmd>Telekasten<CR>", { noremap = true, silent = true })
end

local function load_open_url()
    km.set({ 'v' }, "<space>o", "<Plug>SearchVisual", { noremap = true, silent = true })
    km.set({ 'n' }, "<space>o", "<Plug>SearchNormal", { noremap = true, silent = true })
end

local function load_db()
    g.db_ui_show_database_icon = 1
    g.db_ui_use_nerd_fonts = 1
    g.vim_dadbod_completion_mark = ''

    local cmp = require("cmp")
    cmp.setup.filetype({ 'mysql', 'sql', 'plsql' }, {
        sources = cmp.config.sources({
            { name = 'vim-dadbod-completion' }, -- You can specify the `cmp_git` source if you were installed it.
        }, {
            { name = 'buffer' },
        })
    })

    require("private.private").setup()
end

local function load_sepctre()
    require('spectre').setup({
        live_update = true, -- auto execute search again when you write any file in vim
    })
end

local function load_chatgpt()
    require("codegpt.config")

    -- Override the default chat completions url, this is useful to override when testing custom commands
    -- vim.g["codegpt_chat_completions_url"] = "http://127.0.0.1:800/test"

    vim.g["codegpt_commands"] = {
        ["tests"] = {
            -- Language specific instructions for java filetype
            language_instructions = {
                java = "Use the TestNG framework.",
            },
        },
        ["doc"] = {
            -- Language specific instructions for python filetype
            language_instructions = {
                python = "Use the Google style docstrings."
            },

            -- Overrides the max tokens to be 1024
            max_tokens = 1024,
        },
        ["code_edit"] = {
            -- Overrides the system message template
            system_message_template = "You are {{language}} developer.",

            -- Overrides the user message template
            user_message_template =
            "I have the following {{language}} code: ```{{filetype}}\n{{text_selection}}```\nEdit the above code. {{language_instructions}}",

            -- Display the response in a popup window. The popup window filetype will be the filetype of the current buffer.
            callback_type = "code_popup",
        },
        -- Custom command
        ["modernize"] = {
            user_message_template =
            "I have the following {{language}} code: ```{{filetype}}\n{{text_selection}}```\nModernize the above code. Use current best practices. Only return the code snippet and comments. {{language_instructions}}",
            language_instructions = {
                cpp =
                "Use modern C++ syntax. Use auto where possible. Do not import std. Use trailing return type. Use the c++11, c++14, c++17, and c++20 standards where applicable.",
            },
        }
    }
end

m.setup = function()
    load_pantran()
    load_rest()
    load_telekasten()
    load_open_url()
    load_db()
    load_sepctre()
    load_chatgpt()
end

return m
