local km = vim.keymap
local g = vim.g
local cmd = vim.cmd
local api = vim.api

local function load_toggle_term_map()
    local currTerm = 0
    local max_value = 0
    local function get_next_value(v)
        if v == max_value then
            return 1
        else
            return v + 1
        end
    end

    local function get_prev_value(v)
        if v == 1 then
            return max_value
        else
            return v - 1
        end
    end

    local function get_curr_value()
        if currTerm == 0 then
            max_value = max_value + 1
            currTerm = max_value
        end
        return currTerm
    end

    local function set_curr_value(v)
        if v > max_value then
            max_value = v
        end
        currTerm = v
    end

    local function get_max_value()
        return max_value
    end

    local short_cwd = function()
        return string.match(vim.fn.getcwd(), '([^/]+/[^/]+)/?$')
    end

    km.set({ 'n', 't' }, "<M-w>", function()
        cmd(get_curr_value() .. 'ToggleTerm' .. ' name=' .. short_cwd())
    end, { noremap = true, silent = true, desc = "ToggleTerm toggle terminal" })
    km.set({ 'n', 't' }, "<M-e>", function()
        if get_curr_value() == get_next_value(get_curr_value()) then
            return
        else
            set_curr_value(get_next_value(get_curr_value()))
        end
        cmd(get_curr_value() .. 'ToggleTerm' .. ' name=' .. short_cwd())
    end, { noremap = true, silent = true, desc = "ToggleTerm next terminal" })
    km.set({ 'n', 't' }, "<M-q>", function()
        if get_curr_value() == get_prev_value(get_curr_value()) then
            return
        else
            set_curr_value(get_prev_value(get_curr_value()))
        end
        cmd(get_curr_value() .. 'ToggleTerm' .. ' name=' .. short_cwd())
    end, { noremap = true, silent = true, desc = "ToggleTerm prev terminal" })
    km.set({ 'n', 't' }, "<M-r>", function()
        set_curr_value(get_max_value() + 1)
        cmd(get_curr_value() .. 'ToggleTerm' .. ' name=' .. short_cwd())
    end, { noremap = true, silent = true, desc = "ToggleTerm new terminal" })
    km.set({ 'n', 't' }, "<M-s>", function()
        cmd(get_curr_value() .. "TermExec cmd=exit dir=~")
    end, { noremap = true, silent = true, desc = "ToggleTerm reset current terminal" })

    local mongoTerm
    local mongo = function()
        if mongoTerm == nil then
            set_curr_value(get_max_value() + 1)
            mongoTerm = require("toggleterm.terminal").Terminal:new({
                display_name = "Mongo",
                cmd = "bash ~/.config/nvim/lua/private/mongo.sh",
                count = get_curr_value(),
                hidden = false,
                on_exit = function()
                    mongoTerm = nil
                end,
            })
            mongoTerm.termNo = get_curr_value()
        end
        return mongoTerm
    end
    local redisTerm
    local redis = function()
        if redisTerm == nil then
            set_curr_value(get_max_value() + 1)
            redisTerm = require("toggleterm.terminal").Terminal:new({
                display_name = "Redis",
                cmd = "bash ~/.config/nvim/lua/private/redis.sh",
                count = get_curr_value(),
                hidden = false,
                on_exit = function()
                    redisTerm = nil
                end,
            })
            redisTerm.termNo = get_curr_value()
        end
        return redisTerm
    end
    local sshTerm
    local ssh = function()
        if sshTerm == nil then
            set_curr_value(get_max_value() + 1)
            sshTerm = require("toggleterm.terminal").Terminal:new({
                display_name = "ssh",
                cmd = "bash ~/.config/nvim/lua/private/ssh.sh",
                count = get_curr_value(),
                hidden = false,
                on_exit = function()
                    sshTerm = nil
                end,
            })
            sshTerm.termNo = get_curr_value()
        end
        return sshTerm
    end

    api.nvim_create_user_command('Mongo', function()
        local term = mongo()
        set_curr_value(term.termNo)
        term:toggle()
    end, {})

    api.nvim_create_user_command('Redis', function()
        local term = redis()
        set_curr_value(term.termNo)
        term:toggle()
    end, {})

    api.nvim_create_user_command('SSH', function()
        local term = ssh()
        set_curr_value(term.termNo)
        term:toggle()
    end, {})
end

return {
    {
        "vinnymeller/swagger-preview.nvim",
        cmd = "SwaggerPreview",
        build = "npm install --localtion=global swagger-ui-watcher",
        config = function()
            require("swagger-preview").setup({
                -- The port to run the preview server on
                port = 8000,
                -- The host to run the preview server on
                host = "0.0.0.0",
            })
        end
    },
    {
        'uga-rosa/ccc.nvim',
        cmd = "CccHighlighterEnable",
        config = function()
            require('ccc').setup({
                highlighter = {
                    auto_enable = false,
                    lsp = true,
                },
            })
        end
    },
    {
        'iamcco/markdown-preview.nvim',
        ft = "markdown",
        build = 'cd app && ./install.sh'
    },
    -- {
    --     'voldikss/vim-translator',
    --     cmd = "Translate",
    --     keys = {
    --         { "<space>tt", "<Plug>TranslateW",  { noremap = true, silent = true }, mode = { "n" }, desc = "Translate In Float" },
    --         { "<space>tt", "<Plug>TranslateWV", { noremap = true, silent = true }, mode = { "v" }, desc = "Translate In Float" },
    --         { "<space>tr", "<Plug>TranslateR",  { noremap = true, silent = true }, mode = { "n" }, desc = "Translate Replace" },
    --         { "<space>tr", "<Plug>TranslateRV", { noremap = true, silent = true }, mode = { "v" }, desc = "Translate Replace" },
    --     },
    --     config = function()
    --         vim.g.translator_source_lang = 'auto'
    --         vim.g.translator_target_lang = 'zh'
    --         vim.g.translator_default_engines = { "bing", "google", "haici", "youdao" }
    --         vim.g.translator_window_borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
    --
    --         api.nvim_set_hl(0, "TranslatorBorder", { link = 'CustomBorder' })
    --     end
    -- },
    -- {
    --     'potamides/pantran.nvim',
    --     keys = {
    --         { "<space>to", nil, mode = { "n", "v" }, desc = "Pantran" }
    --     },
    --     config = function()
    --         local pantran_actions = require("pantran.ui.actions")
    --         require("pantran").setup {
    --             -- Default engine to use for translation. To list valid engine names run
    --             -- `:lua =vim.tbl_keys(require("pantran.engines"))`.
    --             default_engine = "google",
    --             -- Configuration for individual engines goes here.
    --             window = {
    --                 window_config = {
    --                     border = "rounded"
    --                 },
    --             },
    --             engines = {
    --                 google = {
    --                     -- Default languages can be defined on a per engine basis. In this case
    --                     -- `:lua vim.pretty_print(require("pantran.engines").google:languages())
    --                     default_source = "auto",
    --                     default_target = "zh-CN",
    --                     fallback = {
    --                         default_source = "auto",
    --                         default_target = "zh-CN",
    --                     }
    --                 },
    --             },
    --             controls = {
    --                 mappings = {
    --                     edit = {
    --                         n = {
    --                             -- Use this table to add additional mappings for the normal mode in
    --                             -- the translation window. Either strings or function references are
    --                             -- supported.
    --                             ["<C-c>"] = pantran_actions.close,
    --                             ["<C-a>"] = pantran_actions.append_close_translation,
    --                             ["<C-r>"] = pantran_actions.replace_close_translation,
    --                             ["<C-s>"] = pantran_actions.select_source,
    --                             ["<C-t>"] = pantran_actions.select_target,
    --                             ["<C-e>"] = pantran_actions.select_engine,
    --                         },
    --                         i = {
    --                             -- Similar table but for insert mode. Using 'false' disables
    --                             -- existing keybindings.
    --                             ["<c-c>"] = function(ui)
    --                                 vim.cmd("stopinsert")
    --                                 pantran_actions.close(ui)
    --                             end,
    --                             -- ["<c-o>"] = function()
    --                             --     vim.cmd("stopinsert")
    --                             -- end,
    --                             ["<C-r>"] = pantran_actions.replace_close_translation,
    --                             ["<C-a>"] = pantran_actions.append_close_translation,
    --                             ["<C-s>"] = pantran_actions.select_source,
    --                             ["<C-t>"] = pantran_actions.select_target,
    --                             ["<C-e>"] = pantran_actions.select_engine,
    --                         }
    --                     },
    --                     -- Keybindings here are used in the selection window.
    --                     select = {
    --                         i = {
    --                             ["<c-c>"] = function(ui)
    --                                 vim.cmd("stopinsert")
    --                                 pantran_actions.close(ui)
    --                             end,
    --                             ["<C-s>"] = pantran_actions.select_source,
    --                             ["<C-t>"] = pantran_actions.select_target,
    --                             ["<C-e>"] = pantran_actions.select_engine,
    --                         },
    --                         n = {
    --                             ["<C-c>"] = pantran_actions.close,
    --                             ["<C-s>"] = pantran_actions.select_source,
    --                             ["<C-t>"] = pantran_actions.select_target,
    --                             ["<C-e>"] = pantran_actions.select_engine,
    --                         }
    --                     }
    --                 }
    --             },
    --         }
    --
    --         vim.api.nvim_set_hl(0, "PantranBorder", { link = 'CustomBorder' })
    --         km.set('n', "<space>to", "<cmd>Pantran<CR>i", { noremap = true, silent = true, desc = "pantran panel" })
    --     end
    -- },
    {
        'mistweaverco/kulala.nvim',
        keys = {
            {
                "<leader>cc",
                function()
                    require('kulala').run()
                end,
                { noremap = true, silent = true },
                desc = "Kulala request",
            },
            {
                "<leader>ch",
                function()
                    require('kulala').toggle_view()
                end,
                { noremap = true, silent = true },
                desc = "Kulala toggle header",
            },
        },
        init = function()
            vim.filetype.add({
                extension = {
                    http = "http"
                }
            })
        end,
        config = function()
            require("kulala").setup()
        end
    },
    -- {
    --     'rest-nvim/rest.nvim',
    --     ft = "http",
    --     rocks = { "lua-curl", "nvim-nio", "mimetypes", "xml2lua", "magick" },
    --     config = function()
    --         require("rest-nvim").setup({
    --             client = "curl",
    --             env_file = ".env",
    --             env_pattern = "\\.env$",
    --             env_edit_command = "tabedit",
    --             custom_dynamic_variables = {},
    --             logs = {
    --                 level = "info",
    --                 save = true,
    --             },
    --             -- Skip SSL verification, useful for unknown certificates
    --             skip_ssl_verification = true,
    --             -- Encode URL before making request
    --             encode_url = false,
    --             -- Highlight request on run
    --             highlight = {
    --                 enable = true,
    --                 timeout = 750,
    --             },
    --             result = {
    --                 split = {
    --                     horizontal = false,
    --                     in_place = false,
    --                     stay_in_current_window_after_split = true,
    --                 },
    --                 behavior = {
    --                     show_info = {
    --                         url = true,
    --                         headers = true,
    --                         http_info = true,
    --                         curl_command = true,
    --                     },
    --                     -- executables or functions for formatting response body [optional]
    --                     -- set them to nil if you want to disable them
    --                     formatters = {
    --                         json = "jq",
    --                         html = function(body)
    --                             if vim.fn.executable("tidy") == 0 then
    --                                 return body, { found = false, name = "tidy" }
    --                             end
    --                             local fmt_body = vim.fn.system({
    --                                 "tidy",
    --                                 "-i",
    --                                 "-q",
    --                                 "--tidy-mark", "no",
    --                                 "--show-body-only", "auto",
    --                                 "--show-errors", "0",
    --                                 "--show-warnings", "0",
    --                                 "-",
    --                             }, body):gsub("\n$", "")
    --
    --                             return fmt_body, { found = true, name = "tidy" }
    --                         end,
    --                     },
    --                 }
    --             },
    --             keybinds = {
    --                 { "<leader>cc", "<cmd>Rest run<cr>",      "Rest Run" },
    --                 { "<leader>cp", "<cmd>Rest run last<cr>", "Rest Run Last" },
    --             },
    --         })
    --     end
    -- },
    {
        'kristijanhusak/vim-dadbod-ui',
        cmd = "DBUI",
        dependencies = {
            'tpope/vim-dadbod',
        },
        init = function()
            g.db_ui_show_database_icon = 1
            g.db_ui_use_nerd_fonts = 1
            g.vim_dadbod_completion_mark = ''
        end,
        config = function()
            -- local cmp = require("cmp")
            -- cmp.setup.filetype({ 'mysql', 'sql', 'plsql' }, {
            --     sources = cmp.config.sources({
            --         { name = 'vim-dadbod-completion' }, -- You can specify the `cmp_git` source if you were installed it.
            --     }, {
            --         { name = 'buffer' },
            --     })
            -- })

            require("private.private").load_db()
        end
    },
    -- {
    --     'eandrju/cellular-automaton.nvim',
    --     cmd = "CellularAutomaton",
    -- },
    {
        'windwp/nvim-spectre',
        cmd = "Spectre",
        opts = {
            live_update = true, -- auto execute search again when you write any file in vim
        }
    },
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        cmd = {
            "SSH",
            "Mongo",
            "Redis"
        },
        keys = {
            { "<M-w>", nil, desc = "Toggle Terminal" },
            { "<M-r>", nil, desc = "New Terminal" },
        },
        config = function()
            require("toggleterm").setup({
                -- size can be a number or function which is passed the current terminal
                size = function(term)
                    if term.direction == "horizontal" then
                        return 15
                    elseif term.direction == "vertical" then
                        return vim.o.columns * 0.4
                    else
                        return 20
                    end
                end,
                -- open_mapping = [[<c-\>]],
                -- on_create = fun(t: Terminal), -- function to run when the terminal is first created
                -- on_open = fun(t: Terminal), -- function to run when the terminal opens
                -- on_close = fun(t: Terminal), -- function to run when the terminal closes
                -- on_stdout = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stdout
                -- on_stderr = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stderr
                -- on_exit = fun(t: Terminal, job: number, exit_code: number, name: string) -- function to run when terminal process exits
                hide_numbers = true, -- hide the number column in toggleterm buffers
                shade_filetypes = {},
                autochdir = false,   -- when neovim changes it current directory the terminal will change it's own when next it's opened
                highlights = {
                    -- highlights which map to a highlight group name and a table of it's values
                    -- NOTE: this is only a subset of values, any group placed here will be set for the terminal window split
                    Normal = {
                        -- guibg = "<VALUE-HERE>",
                    },
                    NormalFloat = {
                        link = 'Normal'
                    },
                    FloatBorder = {
                        guifg = require("common").colors.CustomBorderFg,
                        guibg = require("common").colors.CustomBorderBg,
                    },
                },
                shade_terminals = true,   -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
                shading_factor = '1',     -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
                start_in_insert = true,
                insert_mappings = true,   -- whether or not the open mapping applies in insert mode
                terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
                persist_size = true,
                persist_mode = true,      -- if set to true (default) the previous terminal mode will be remembered
                -- direction = 'vertical' | 'horizontal' | 'tab' | 'float',
                direction = 'float',
                close_on_exit = true, -- close the terminal window when the process exits
                shell = vim.o.shell,  -- change the default shell
                auto_scroll = true,   -- automatically scroll to the bottom on terminal output
                -- This field is only relevant if direction is set to 'float'
                float_opts = {
                    -- The border key is *almost* the same as 'nvim_open_win'
                    -- see :h nvim_open_win for details on borders however
                    -- the 'curved' border is a custom border type
                    -- not natively supported but implemented in this plugin.
                    -- border = 'single' | 'double' | 'shadow' | 'curved' |
                    border = 'rounded',
                    -- like `size`, width and height can be a number or function which is passed the current terminal
                    width = vim.o.columns - 3,
                    height = g.neovide and vim.o.lines - 4 or vim.o.lines - 3,
                    winblend = vim.g.custom_blend,
                },
                winbar = {
                    enabled = false,
                    name_formatter = function(term) --  term: Terminal
                        return term.name
                    end
                },
            })

            load_toggle_term_map()
        end
    },
    {
        'sindrets/diffview.nvim',
        cmd = "DiffviewOpen",
        config = function()
            local actions = require("diffview.actions")

            require("diffview").setup({
                diff_binaries = false,   -- Show diffs for binaries
                enhanced_diff_hl = true, -- See ':h diffview-config-enhanced_diff_hl'
                git_cmd = { "git" },     -- The git executable followed by default args.
                use_icons = true,        -- Requires nvim-web-devicons
                show_help_hints = true,  -- Show hints for how to open the help panel
                watch_index = true,      -- Update views and index buffers when the git index changes.
                icons = {
                    -- Only applies when use_icons is true.
                    folder_closed = "",
                    folder_open = "",
                },
                signs = {
                    fold_closed = "",
                    fold_open = "",
                    done = "✓",
                },
                view = {
                    -- Configure the layout and behavior of different types of views.
                    -- Available layouts:
                    --  'diff1_plain'
                    --    |'diff2_horizontal'
                    --    |'diff2_vertical'
                    --    |'diff3_horizontal'
                    --    |'diff3_vertical'
                    --    |'diff3_mixed'
                    --    |'diff4_mixed'
                    -- For more info, see ':h diffview-config-view.x.layout'.
                    default = {
                        -- Config for changed files, and staged files in diff views.
                        layout = "diff2_horizontal",
                        winbar_info = false, -- See ':h diffview-config-view.x.winbar_info'
                    },
                    merge_tool = {
                        -- Config for conflicted files in diff views during a merge or rebase.
                        layout = "diff3_mixed",
                        disable_diagnostics = true, -- Temporarily disable diagnostics for conflict buffers while in the view.
                        winbar_info = true,         -- See ':h diffview-config-view.x.winbar_info'
                    },
                    file_history = {
                        -- Config for changed files in file history views.
                        layout = "diff2_horizontal",
                        winbar_info = false, -- See ':h diffview-config-view.x.winbar_info'
                    },
                },
                file_panel = {
                    listing_style = "tree", -- One of 'list' or 'tree'
                    tree_options = {
                        -- Only applies when listing_style is 'tree'
                        flatten_dirs = true,             -- Flatten dirs that only contain one single dir
                        folder_statuses = "only_folded", -- One of 'never', 'only_folded' or 'always'.
                    },
                    win_config = {
                        -- See ':h diffview-config-win_config'
                        position = "left",
                        width = 35,
                        win_opts = {}
                    },
                },
                file_history_panel = {
                    log_options = {
                        -- See ':h diffview-config-log_options'
                        git = {
                            single_file = {
                                diff_merges = "combined",
                            },
                            multi_file = {
                                diff_merges = "first-parent",
                            },
                        },
                        hg = {
                            single_file = {},
                            multi_file = {},
                        },
                    },
                    win_config = {
                        -- See ':h diffview-config-win_config'
                        position = "bottom",
                        height = 16,
                        win_opts = {}
                    },
                },
                commit_log_panel = {
                    win_config = { -- See ':h diffview-config-win_config'
                        win_opts = {},
                    }
                },
                default_args = {
                    -- Default args prepended to the arg-list for the listed commands
                    DiffviewOpen = {},
                    DiffviewFileHistory = {},
                },
                hooks = {},                   -- See ':h diffview-config-hooks'
                keymaps = {
                    disable_defaults = false, -- Disable the default keymaps
                    view = {
                        -- The `view` bindings are active in the diff buffers, only when the current
                        -- tabpage is a Diffview.
                        { "n", "<tab>",   actions.select_next_entry, { desc = "Open the diff for the next file" } },
                        { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
                        { "n", "gf", actions.goto_file, {
                            desc =
                            "Open the file in a new split in the previous tabpage"
                        } },
                        { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "Open the file in a new split" } },
                        { "n", "<C-w>gf",    actions.goto_file_tab,   { desc = "Open the file in a new tabpage" } },
                        { "n", "<leader>e",  actions.focus_files,     { desc = "Bring focus to the file panel" } },
                        { "n", "<leader>q",  actions.toggle_files,    { desc = "Toggle the file panel." } },
                        { "n", "g<C-x>",     actions.cycle_layout,    { desc = "Cycle through available layouts." } },
                        { "n", "[x", actions.prev_conflict, {
                            desc =
                            "In the merge-tool: jump to the previous conflict"
                        } },
                        { "n", "]x", actions.next_conflict, {
                            desc =
                            "In the merge-tool: jump to the next conflict"
                        } },
                        { "n", "co", actions.conflict_choose("ours"),
                            {
                                desc =
                                "Choose the OURS version of a conflict"
                            } },
                        { "n", "ct", actions.conflict_choose("theirs"),
                            { desc = "Choose the THEIRS version of a conflict" } },
                        { "n", "cb", actions.conflict_choose("base"),
                            {
                                desc =
                                "Choose the BASE version of a conflict"
                            } },
                        { "n", "ca", actions.conflict_choose("all"),
                            {
                                desc =
                                "Choose all the versions of a conflict"
                            } },
                        { "n", "cx", actions.conflict_choose("none"), { desc = "Delete the conflict region" } },
                    },
                    diff1 = {
                        -- Mappings in single window diff layouts
                        { "n", "g?", actions.help({ "view", "diff1" }), { desc = "Open the help panel" } },
                    },
                    diff2 = {
                        -- Mappings in 2-way diff layouts
                        { "n", "g?", actions.help({ "view", "diff2" }), { desc = "Open the help panel" } },
                    },
                    diff3 = {
                        -- Mappings in 3-way diff layouts
                        { { "n",                                                          "x" }, "2do",
                            actions.diffget("ours"),
                            { desc = "Obtain the diff hunk from the OURS version of the file" } },
                        { { "n",                                                            "x" }, "3do",
                            actions.diffget("theirs"),
                            { desc = "Obtain the diff hunk from the THEIRS version of the file" } },
                        { "n", "g?", actions.help({ "view", "diff3" }), { desc = "Open the help panel" } },
                    },
                    diff4 = {
                        -- Mappings in 4-way diff layouts
                        { { "n",                                                          "x" }, "1do",
                            actions.diffget("base"),
                            { desc = "Obtain the diff hunk from the BASE version of the file" } },
                        { { "n",                                                          "x" }, "2do",
                            actions.diffget("ours"),
                            { desc = "Obtain the diff hunk from the OURS version of the file" } },
                        { { "n",                                                            "x" }, "3do",
                            actions.diffget("theirs"),
                            { desc = "Obtain the diff hunk from the THEIRS version of the file" } },
                        { "n", "g?", actions.help({ "view", "diff4" }), { desc = "Open the help panel" } },
                    },
                    file_panel = {
                        { "n", "j",      actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
                        { "n", "<down>", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
                        { "n", "k", actions.prev_entry, {
                            desc =
                            "Bring the cursor to the previous file entry."
                        } },
                        { "n", "<up>", actions.prev_entry, {
                            desc =
                            "Bring the cursor to the previous file entry."
                        } },
                        { "n", "<cr>", actions.select_entry, {
                            desc =
                            "Open the diff for the selected entry."
                        } },
                        { "n", "o", actions.select_entry, {
                            desc =
                            "Open the diff for the selected entry."
                        } },
                        { "n", "<2-LeftMouse>", actions.select_entry, {
                            desc =
                            "Open the diff for the selected entry."
                        } },
                        { "n", "-", actions.toggle_stage_entry,
                            {
                                desc =
                                "Stage / unstage the selected entry."
                            } },
                        { "n", "S", actions.stage_all,   { desc = "Stage all entries." } },
                        { "n", "U", actions.unstage_all, { desc = "Unstage all entries." } },
                        { "n", "X", actions.restore_entry, {
                            desc =
                            "Restore entry to the state on the left side."
                        } },
                        { "n", "L",       actions.open_commit_log,    { desc = "Open the commit log panel." } },
                        { "n", "<c-b>",   actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
                        { "n", "<c-f>",   actions.scroll_view(0.25),  { desc = "Scroll the view down" } },
                        { "n", "<tab>",   actions.select_next_entry,  { desc = "Open the diff for the next file" } },
                        { "n", "<s-tab>", actions.select_prev_entry,  { desc = "Open the diff for the previous file" } },
                        { "n", "gf", actions.goto_file,
                            {
                                desc =
                                "Open the file in a new split in the previous tabpage"
                            } },
                        { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "Open the file in a new split" } },
                        { "n", "<C-w>gf",    actions.goto_file_tab,   { desc = "Open the file in a new tabpage" } },
                        { "n", "i",          actions.listing_style,   { desc = "Toggle between 'list' and 'tree' views" } },
                        { "n", "f", actions.toggle_flatten_dirs,
                            {
                                desc =
                                "Flatten empty subdirectories in tree listing style."
                            } },
                        { "n", "R", actions.refresh_files, {
                            desc =
                            "Update stats and entries in the file list."
                        } },
                        { "n", "<leader>e", actions.focus_files,        { desc = "Bring focus to the file panel" } },
                        { "n", "<leader>b", actions.toggle_files,       { desc = "Toggle the file panel" } },
                        { "n", "g<C-x>",    actions.cycle_layout,       { desc = "Cycle available layouts" } },
                        { "n", "[x",        actions.prev_conflict,      { desc = "Go to the previous conflict" } },
                        { "n", "]x",        actions.next_conflict,      { desc = "Go to the next conflict" } },
                        { "n", "g?",        actions.help("file_panel"), { desc = "Open the help panel" } },
                    },
                    file_history_panel = {
                        { "n", "g!", actions.options,         { desc = "Open the option panel" } },
                        { "n", "<C-A-d>", actions.open_in_diffview,
                            {
                                desc =
                                "Open the entry under the cursor in a diffview"
                            } },
                        { "n", "y", actions.copy_hash,
                            {
                                desc =
                                "Copy the commit hash of the entry under the cursor"
                            } },
                        { "n", "L",  actions.open_commit_log, { desc = "Show commit details" } },
                        { "n", "zR", actions.open_all_folds,  { desc = "Expand all folds" } },
                        { "n", "zM", actions.close_all_folds, { desc = "Collapse all folds" } },
                        { "n", "j", actions.next_entry, {
                            desc =
                            "Bring the cursor to the next file entry"
                        } },
                        { "n", "<down>", actions.next_entry, {
                            desc =
                            "Bring the cursor to the next file entry"
                        } },
                        { "n", "k", actions.prev_entry, {
                            desc =
                            "Bring the cursor to the previous file entry."
                        } },
                        { "n", "<up>", actions.prev_entry, {
                            desc =
                            "Bring the cursor to the previous file entry."
                        } },
                        { "n", "<cr>", actions.select_entry, {
                            desc =
                            "Open the diff for the selected entry."
                        } },
                        { "n", "o", actions.select_entry, {
                            desc =
                            "Open the diff for the selected entry."
                        } },
                        { "n", "<2-LeftMouse>", actions.select_entry, {
                            desc =
                            "Open the diff for the selected entry."
                        } },
                        { "n", "<c-b>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
                        { "n", "<c-f>", actions.scroll_view(0.25),  { desc = "Scroll the view down" } },
                        { "n", "<tab>", actions.select_next_entry,  { desc = "Open the diff for the next file" } },
                        { "n", "<s-tab>", actions.select_prev_entry, {
                            desc =
                            "Open the diff for the previous file"
                        } },
                        { "n", "gf", actions.goto_file,
                            {
                                desc =
                                "Open the file in a new split in the previous tabpage"
                            } },
                        { "n", "<C-w><C-f>", actions.goto_file_split,            { desc = "Open the file in a new split" } },
                        { "n", "<C-w>gf", actions.goto_file_tab, {
                            desc =
                            "Open the file in a new tabpage"
                        } },
                        { "n", "<leader>e",  actions.focus_files,                { desc = "Bring focus to the file panel" } },
                        { "n", "<leader>b",  actions.toggle_files,               { desc = "Toggle the file panel" } },
                        { "n", "g<C-x>",     actions.cycle_layout,               { desc = "Cycle available layouts" } },
                        { "n", "g?",         actions.help("file_history_panel"), { desc = "Open the help panel" } },
                    },
                    option_panel = {
                        { "n", "<tab>", actions.select_entry,         { desc = "Change the current option" } },
                        { "n", "q",     actions.close,                { desc = "Close the panel" } },
                        { "n", "g?",    actions.help("option_panel"), { desc = "Open the help panel" } },
                    },
                    help_panel = {
                        { "n", "q",     actions.close, { desc = "Close help menu" } },
                        { "n", "<esc>", actions.close, { desc = "Close help menu" } },
                    },
                },
            })
        end
    },
    {
        "epwalsh/obsidian.nvim",
        version = "*", -- recommended, use latest release instead of latest commit
        ft = "markdown",
        cmd = "Obsidian",
        keys = {
            { "<space>zz", "<cmd>ObsidianQuickSwitch<CR>", { noremap = true, silent = true }, desc = "Obsidian Notes" },
            { "<space>ze", "<cmd>ObsidianSearch<CR>",      { noremap = true, silent = true }, desc = "Obsidian Search" },
            { "<space>zt", "<cmd>ObsidianTag<CR>",         { noremap = true, silent = true }, desc = "Obsidian Tags" },
        },
        -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
        -- event = {
        --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
        --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
        --   "BufReadPre path/to/my-vault/**.md",
        --   "BufNewFile path/to/my-vault/**.md",
        -- },
        dependencies = {
            -- Required.
            "nvim-lua/plenary.nvim",

            -- see below for full list of optional dependencies 👇
        },
        config = function()
            require("obsidian").setup({
                -- A list of workspace names, paths, and configuration overrides.
                -- If you use the Obsidian app, the 'path' of a workspace should generally be
                -- your vault root (where the `.obsidian` folder is located).
                -- When obsidian.nvim is loaded by your plugin manager, it will automatically set
                -- the workspace to the first workspace in the list whose `path` is a parent of the
                -- current markdown file being edited.
                workspaces = {
                    {
                        name = "personal",
                        path = "~/Documents/notes",
                    },
                },

                -- Alternatively - and for backwards compatibility - you can set 'dir' to a single path instead of
                -- 'workspaces'. For example:
                -- dir = "~/vaults/work",

                -- Optional, if you keep notes in a specific subdirectory of your vault.
                notes_subdir = "notes",

                -- Optional, set the log level for obsidian.nvim. This is an integer corresponding to one of the log
                -- levels defined by "vim.log.levels.*".
                log_level = vim.log.levels.INFO,

                daily_notes = {
                    -- Optional, if you keep daily notes in a separate directory.
                    folder = "notes/dailies",
                    -- Optional, if you want to change the date format for the ID of daily notes.
                    date_format = "%Y-%m-%d",
                    -- Optional, if you want to change the date format of the default alias of daily notes.
                    alias_format = "%B %-d, %Y",
                    -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
                    template = nil
                },

                -- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
                completion = {
                    -- Set to false to disable completion.
                    nvim_cmp = true,
                    -- Trigger completion at 2 chars.
                    min_chars = 2,
                },

                -- Optional, configure key mappings. These are the defaults. If you don't want to set any keymappings this
                -- way then set 'mappings = {}'.
                mappings = {
                    -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
                    ["gf"] = {
                        action = function()
                            return require("obsidian").util.gf_passthrough()
                        end,
                        opts = { noremap = false, expr = true, buffer = true, desc = "Obsidian Passthrough" },
                    },
                    -- -- Toggle check-boxes.
                    -- ["<leader>x"] = {
                    --     action = function()
                    --         return require("obsidian").util.toggle_checkbox()
                    --     end,
                    --     opts = { buffer = true, desc = "Obsidian ToggleCheckbox" },
                    -- },
                    -- -- Smart action depending on context, either follow link or toggle checkbox.
                    ["<leader>a"] = {
                        action = function()
                            return require("obsidian").util.smart_action()
                        end,
                        opts = { buffer = true, desc = "Obsidian SmartAction" },
                    }
                },

                -- Where to put new notes. Valid options are
                --  * "current_dir" - put new notes in same directory as the current buffer.
                --  * "notes_subdir" - put new notes in the default notes subdirectory.
                new_notes_location = "notes_subdir",

                -- Optional, customize how note IDs are generated given an optional title.
                ---@param title string|?
                ---@return string
                note_id_func = function(title)
                    -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
                    -- In this case a note with the title 'My new note' will be given an ID that looks
                    -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
                    local suffix = ""
                    if title ~= nil then
                        -- If title is given, transform it into valid file name.
                        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
                    else
                        -- If title is nil, just add 4 random uppercase letters to the suffix.
                        for _ = 1, 4 do
                            suffix = suffix .. string.char(math.random(65, 90))
                        end
                    end
                    return tostring(os.time()) .. "-" .. suffix
                end,

                -- Optional, customize how note file names are generated given the ID, target directory, and title.
                ---@param spec { id: string, dir: obsidian.Path, title: string|? }
                ---@return string|obsidian.Path The full path to the new note.
                note_path_func = function(spec)
                    -- This is equivalent to the default behavior.
                    local path = spec.dir / tostring(spec.id)
                    return path:with_suffix(".md")
                end,

                -- Optional, customize how wiki links are formatted. You can set this to one of:
                --  * "use_alias_only", e.g. '[[Foo Bar]]'
                --  * "prepend_note_id", e.g. '[[foo-bar|Foo Bar]]'
                --  * "prepend_note_path", e.g. '[[foo-bar.md|Foo Bar]]'
                --  * "use_path_only", e.g. '[[foo-bar.md]]'
                -- Or you can set it to a function that takes a table of options and returns a string, like this:
                wiki_link_func = function(opts)
                    return require("obsidian.util").wiki_link_id_prefix(opts)
                end,

                -- Optional, customize how markdown links are formatted.
                markdown_link_func = function(opts)
                    return require("obsidian.util").markdown_link(opts)
                end,

                -- Either 'wiki' or 'markdown'.
                preferred_link_style = "wiki",

                -- Optional, customize the default name or prefix when pasting images via `:ObsidianPasteImg`.
                ---@return string
                image_name_func = function()
                    -- Prefix image names with timestamp.
                    return string.format("%s-", os.time())
                end,

                -- Optional, boolean or a function that takes a filename and returns a boolean.
                -- `true` indicates that you don't want obsidian.nvim to manage frontmatter.
                disable_frontmatter = false,

                -- Optional, alternatively you can customize the frontmatter data.
                ---@return table
                note_frontmatter_func = function(note)
                    -- Add the title of the note as an alias.
                    if note.title then
                        note:add_alias(note.title)
                    end

                    local out = { id = note.id, aliases = note.aliases, tags = note.tags }

                    -- `note.metadata` contains any manually added fields in the frontmatter.
                    -- So here we just make sure those fields are kept in the frontmatter.
                    if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
                        for k, v in pairs(note.metadata) do
                            out[k] = v
                        end
                    end

                    return out
                end,

                -- Optional, for templates (see below).
                templates = {
                    subdir = "templates",
                    date_format = "%Y-%m-%d",
                    time_format = "%H:%M",
                    -- A map for custom variables, the key should be the variable and the value a function
                    substitutions = {},
                },

                -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
                -- URL it will be ignored but you can customize this behavior here.
                ---@param url string
                follow_url_func = function(url)
                    -- Open the URL in the default web browser.
                    vim.fn.jobstart({ "open", url }) -- Mac OS
                    -- vim.fn.jobstart({"xdg-open", url})  -- linux
                end,

                -- Optional, set to true if you use the Obsidian Advanced URI plugin.
                -- https://github.com/Vinzent03/obsidian-advanced-uri
                use_advanced_uri = false,

                -- Optional, set to true to force ':ObsidianOpen' to bring the app to the foreground.
                open_app_foreground = false,

                picker = {
                    -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
                    name = "telescope.nvim",
                    -- Optional, configure key mappings for the picker. These are the defaults.
                    -- Not all pickers support all mappings.
                    mappings = {
                        -- Create a new note from your query.
                        new = "<C-x>",
                        -- Insert a link to the selected note.
                        insert_link = "<C-l>",
                    },
                },

                -- Optional, sort search results by "path", "modified", "accessed", or "created".
                -- The recommend value is "modified" and `true` for `sort_reversed`, which means, for example,
                -- that `:ObsidianQuickSwitch` will show the notes sorted by latest modified time
                sort_by = "modified",
                sort_reversed = true,

                -- Optional, determines how certain commands open notes. The valid options are:
                -- 1. "current" (the default) - to always open in the current window
                -- 2. "vsplit" - to open in a vertical split if there's not already a vertical split
                -- 3. "hsplit" - to open in a horizontal split if there's not already a horizontal split
                open_notes_in = "current",

                -- Optional, define your own callbacks to further customize behavior.
                callbacks = {
                    -- Runs at the end of `require("obsidian").setup()`.
                    ---@param client obsidian.Client
                    post_setup = function(client) end,

                    -- Runs anytime you enter the buffer for a note.
                    ---@param client obsidian.Client
                    ---@param note obsidian.Note
                    enter_note = function(client, note) end,

                    -- Runs anytime you leave the buffer for a note.
                    ---@param client obsidian.Client
                    ---@param note obsidian.Note
                    leave_note = function(client, note) end,

                    -- Runs right before writing the buffer for a note.
                    ---@param client obsidian.Client
                    ---@param note obsidian.Note
                    pre_write_note = function(client, note) end,

                    -- Runs anytime the workspace is set/changed.
                    ---@param client obsidian.Client
                    ---@param workspace obsidian.Workspace
                    post_set_workspace = function(client, workspace) end,
                },

                -- Optional, configure additional syntax highlighting / extmarks.
                -- This requires you have `conceallevel` set to 1 or 2. See `:help conceallevel` for more details.
                ui = {
                    enable = false,        -- set to false to disable all additional syntax features
                    update_debounce = 200, -- update delay after a text change (in milliseconds)
                    -- Define how various check-boxes are displayed
                    checkboxes = {
                        -- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
                        [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
                        ["x"] = { char = "", hl_group = "ObsidianDone" },
                        [">"] = { char = "", hl_group = "ObsidianRightArrow" },
                        ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
                        -- Replace the above with this if you don't have a patched font:
                        -- [" "] = { char = "☐", hl_group = "ObsidianTodo" },
                        -- ["x"] = { char = "✔", hl_group = "ObsidianDone" },

                        -- You can also add more custom ones...
                    },
                    -- Use bullet marks for non-checkbox lists.
                    bullets = { char = "•", hl_group = "ObsidianBullet" },
                    external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
                    -- Replace the above with this if you don't have a patched font:
                    -- external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
                    reference_text = { hl_group = "ObsidianRefText" },
                    highlight_text = { hl_group = "ObsidianHighlightText" },
                    tags = { hl_group = "ObsidianTag" },
                    block_ids = { hl_group = "ObsidianBlockID" },
                    hl_groups = {
                        -- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
                        ObsidianTodo = { bold = true, fg = "#f78c6c" },
                        ObsidianDone = { bold = true, fg = "#89ddff" },
                        ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
                        ObsidianTilde = { bold = true, fg = "#ff5370" },
                        ObsidianBullet = { bold = true, fg = "#89ddff" },
                        ObsidianRefText = { underline = true, fg = "#c792ea" },
                        ObsidianExtLinkIcon = { fg = "#c792ea" },
                        ObsidianTag = { italic = true, fg = "#89ddff" },
                        ObsidianBlockID = { italic = true, fg = "#89ddff" },
                        ObsidianHighlightText = { bg = "#75662e" },
                    },
                },

                -- Specify how to handle attachments.
                attachments = {
                    -- The default folder to place images in via `:ObsidianPasteImg`.
                    -- If this is a relative path it will be interpreted as relative to the vault root.
                    -- You can always override this per image by passing a full path to the command instead of just a filename.
                    img_folder = "assets/imgs", -- This is the default
                    -- A function that determines the text to insert in the note when pasting an image.
                    -- It takes two arguments, the `obsidian.Client` and an `obsidian.Path` to the image file.
                    -- This is the default implementation.
                    ---@param client obsidian.Client
                    ---@param path obsidian.Path the absolute path to the image file
                    ---@return string
                    img_text_func = function(client, path)
                        path = client:vault_relative_path(path) or path
                        return string.format("![%s](%s)", path.name, path)
                    end,
                },
            })


            vim.api.nvim_create_autocmd(
                { "Filetype" },
                {
                    pattern = "markdown",
                    callback = function(opts)
                        vim.keymap.set({ "n", "x" }, "<leader>x", function()
                            return require("obsidian").util.toggle_checkbox()
                        end, { noremap = true, silent = true, buffer = opts.buf, desc = "Obsidian ToggleCheckbox" })
                    end,
                    group = vim.api.nvim_create_augroup("ObsidianCustom", { clear = true }),
                }
            )
        end
    },
    {
        "mistricky/codesnap.nvim",
        build = "make",
        cmd = "CodeSnap",
        opts = {
            mac_window_bar = true,
            code_font_family = "JetBrainsMono Nerd Font Mono",
            watermark_font_family = "Pacifico",
            watermark = "CodeSnapshot",
            bg_theme = "default",
            breadcrumbs_separator = "/",
            has_breadcrumbs = true,
            show_workspace = true,
            save_path = "~/Pictures",
            has_line_number = true,
        }
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        event = "VeryLazy",
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons',
        },
        ft = { "markdown", "vimwiki", "Avante", "codecompanion" },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        config = function()
            require('render-markdown').setup({
                file_types = { 'markdown', 'vimwiki', 'Avante', "codecompanion" },
            })

            vim.treesitter.language.register('markdown', 'vimwiki', 'Avante', "codecompanion")
        end
    },
    {
        'stevearc/oil.nvim',
        keys = {
            { "-", "<cmd>Oil --float<CR>", { noremap = true, silent = true }, desc = "Oil" },
        },
        ---@module 'oil'
        ---@type oil.SetupOpts
        opts = {
            keymaps = {
                ["g?"] = "actions.show_help",
                ["<CR>"] = "actions.select",
                ["<C-v>"] = { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split" },
                ["<C-s>"] = { "actions.select", opts = { horizontal = true }, desc = "Open the entry in a horizontal split" },
                ["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open the entry in new tab" },
                ["<C-p>"] = "actions.preview",
                ["<C-c>"] = "actions.close",
                ["<C-l>"] = "actions.refresh",
                ["-"] = "actions.parent",
                ["_"] = "actions.open_cwd",
                ["`"] = "actions.cd",
                ["~"] = { "actions.cd", opts = { scope = "tab" }, desc = ":tcd to the current oil directory", mode = "n" },
                ["gs"] = "actions.change_sort",
                ["gx"] = "actions.open_external",
                ["g."] = "actions.toggle_hidden",
                ["g\\"] = "actions.toggle_trash",
            },
            columns = {
                "icon",
                -- "permissions",
                "size",
                -- "mtime",
            },
            delete_to_trash = true,
            float = {
                -- Padding around the floating window
                padding = 2,
                max_width = 0,
                max_height = 0,
                border = "rounded",
                win_options = {
                    winblend = vim.g.custom_blend,
                },
                -- optionally override the oil buffers window title with custom function: fun(winid: integer): string
                get_win_title = nil,
                -- preview_split: Split direction: "auto", "left", "right", "above", "below".
                preview_split = "auto",
                -- This is the config that will be passed to nvim_open_win.
                -- Change values here to customize the layout
                override = function(conf)
                    return conf
                end,
            },
            confirmation = {
                win_options = {
                    winblend = vim.g.custom_blend,
                }
            },
            progress = {
                win_options = {
                    winblend = vim.g.custom_blend,
                },
            },
        },
        -- Optional dependencies
        -- dependencies = { { "echasnovski/mini.icons", opts = {} } },
        dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
    },
    {
        'voldikss/vim-translator',
        cmd = "Translate",
        keys = {
            { "<space>tt", "<Plug>TranslateW",  { noremap = true, silent = true }, mode = { "n" }, desc = "Translate In Float" },
            { "<space>tt", "<Plug>TranslateWV", { noremap = true, silent = true }, mode = { "v" }, desc = "Translate In Float" },
            { "<space>tr", "<Plug>TranslateR",  { noremap = true, silent = true }, mode = { "n" }, desc = "Translate Replace" },
            { "<space>tr", "<Plug>TranslateRV", { noremap = true, silent = true }, mode = { "v" }, desc = "Translate Replace" },
        },
        config = function()
            vim.g.translator_source_lang = 'auto'
            vim.g.translator_target_lang = 'zh'
            vim.g.translator_default_engines = { "bing", "google", "haici", "youdao" }
            vim.g.translator_window_borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

            api.nvim_set_hl(0, "TranslatorBorder", { link = 'CustomBorder' })
        end
    },
}
