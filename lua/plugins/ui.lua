local km = vim.keymap
local api = vim.api
local g = vim.g
local o = vim.o
local fn = vim.fn

return {
    {
        'nvim-tree/nvim-tree.lua',
        keys = {
            { "<space>q", "<cmd>NvimTreeFindFileToggle<cr>", { noremap = true, silent = true } }
        },
        config = function()
            local glyphs = require("common").glyphs
            local on_attach = function(bufnr)
                local tree_api = require('nvim-tree.api')

                tree_api.config.mappings.default_on_attach(bufnr)

                local function opts(desc)
                    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end

                km.del('n', "<C-e>", { buffer = bufnr })
                km.del('n', "<C-x>", { buffer = bufnr })
                km.set('n', '<C-s>', tree_api.node.open.horizontal, opts('Open: Horizontal Split'))
            end
            require("nvim-tree").setup({
                on_attach = on_attach,
                sync_root_with_cwd = true,
                respect_buf_cwd = true,
                sort_by = "name",
                view = {
                    adaptive_size = true,
                    preserve_window_proportions = true,
                },
                renderer = {
                    group_empty = false,
                    icons = {
                        glyphs = {
                            modified = glyphs["modified"],
                            git = {
                                unstaged = glyphs["modified"],
                                staged = glyphs["added"],
                                unmerged = glyphs["unmerged"],
                                renamed = glyphs["renamed"],
                                untracked = glyphs["untracked"],
                                deleted = glyphs["deleted"],
                                ignored = glyphs["ignored"],
                            },
                        },
                    }
                },
                git = {
                    enable = true,
                    ignore = false,
                    show_on_dirs = true,
                    show_on_open_dirs = true,
                    timeout = 400,
                },
                modified = {
                    enable = true,
                    show_on_dirs = true,
                    show_on_open_dirs = true,
                },
                update_focused_file = {
                    enable = true,
                    update_root = true,
                    ignore_list = {},
                },
                filters = {
                    dotfiles = true,
                    git_clean = false,
                    no_buffer = false,
                    custom = {},
                    exclude = {},
                },
            })

            if vim.g.colors_name == 'gruvbox-material' then
                api.nvim_set_hl(0, "NvimTreeCursorLine", { bg = '#3c3836' })
            elseif vim.g.colors_name == 'everforest' then
                api.nvim_set_hl(0, "NvimTreeCursorLine", { bg = '#374145' })
            end
            api.nvim_set_hl(0, "NvimTreeNormal", { link = 'Normal' })
            api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { link = 'EndOfBuffer' })
        end
    },
    {
        'glepnir/dashboard-nvim',
        event = "VimEnter",
        config = function()
            require('dashboard').setup {
                theme = 'hyper', --  t theme = 'hyper',
                config = {
                    week_header = {
                        enable = true,
                    },
                    project = {
                        action = function(path)
                            vim.fn.chdir(path)
                            require('telescope').extensions.frecency.frecency({ workspace = 'CWD' })
                        end,
                    },
                    shortcut = {
                        {
                            desc = ' Empty',
                            group = 'Statement',
                            action = "enew",
                            key = 'e',
                        },
                        {
                            desc = 'ﮮ Update',
                            group = '@property',
                            action = 'Lazy update',
                            key = 'u',
                        },
                        {
                            desc = ' Frecency Files',
                            group = 'Constant',
                            action = function()
                                require('telescope').extensions.frecency.frecency({ workspace = 'CWD' })
                            end,
                            key = 'f',
                        },
                        {
                            desc = ' Projects',
                            group = 'Special',
                            action = require("common").get_tele_project,
                            key = 'i',
                        },
                        {
                            desc = '老Quit',
                            group = 'Label',
                            action = "quit",
                            key = 'q',
                        },
                    },
                },
            }

            api.nvim_set_hl(0, "DashboardProjectTitle", { link = "Special" })
            api.nvim_set_hl(0, "DashboardProjectTitleIcon", { link = "Special" })
            api.nvim_set_hl(0, "DashboardProjectIcon", { link = "Special" })

            api.nvim_set_hl(0, "DashboardMruTitle", { link = "Number" })
            api.nvim_set_hl(0, "DashboardMruIcon", { link = "Number" })
        end
    },
    {
        'nvim-lualine/lualine.nvim',
        event = "VeryLazy",
        config = function()
            local colors = {}
            if g.colors_name == 'gruvbox-material' then
                colors = {
                    color = '#504945',
                    fg    = '#ddc7a1',
                    fg2   = 'gray'
                }
            elseif g.colors_name == 'everforest' then
                colors = {
                    color = '#4f5b58',
                    fg    = '#9da9a0',
                    fg2   = '#7a8478'
                }
            end

            local glyphs = require("common").glyphs

            require('lualine').setup({
                options = {
                    icons_enabled = true,
                    theme = 'auto',
                    component_separators = '|',
                    section_separators = { left = '', right = '' },
                    disabled_filetypes = {
                        statusline = {},
                        winbar = {},
                    },
                    ignore_focus = {},
                    always_divide_middle = true,
                    globalstatus = true,
                    refresh = {
                        statusline = 1000,
                        tabline = 1000,
                        winbar = 1000,
                    }
                },
                sections = {
                    lualine_a = {
                        { 'mode', separator = { left = '' }, right_padding = 2 },
                    },
                    lualine_b = {
                        'branch',
                        {
                            'diff',
                            symbols = {
                                added = glyphs["added"] .. ' ',
                                modified = glyphs["modified"] .. ' ',
                                removed = glyphs["deleted"] .. ' '
                            }
                        },
                        {
                            'diagnostics',
                            symbols = {
                                error = glyphs["sign_error"],
                                warn = glyphs["sign_warn"],
                                info = glyphs["sign_info"],
                                hint = glyphs["sign_hint"],
                            },
                        },
                        { 'fileformat', separator = { right = '' } }
                    },
                    lualine_c = {
                        {
                            'filename',
                            file_status = true,    -- Displays file status (readonly status, modified status)
                            newfile_status = true, -- Display new file status (new file means no write after created)
                            path = 1,              -- 0: Just the filename
                            -- 1: Relative path
                            -- 2: Absolute path
                            -- 3: Absolute path, with tilde as the home directory

                            shorting_target = 40, -- Shortens path to leave 40 spaces in the window
                            -- for other components. (terrible name, any suggestions?)
                            symbols = {
                                modified = glyphs["modified"], -- Text to show when the file is modified.
                                readonly = glyphs["locked"],   -- Text to show when the file is non-modifiable or readonly.
                                unnamed = '[No Name]',         -- Text to show for unnamed buffers.
                                newfile = '[New]',             -- Text to show for newly created file before first write
                            }
                        },
                    },
                    lualine_x = {
                        -- {
                        --     require("noice").api.status.message.get_hl,
                        --     cond = require("noice").api.status.message.has,
                        -- },
                        {
                            require("noice").api.status.command.get,
                            cond = require("noice").api.status.command.has,
                            color = { fg = "#ff9e64" },
                        },
                        {
                            require("noice").api.status.mode.get,
                            cond = function()
                                local msg = require("noice").api.status.mode.get()
                                if msg == nil then
                                    return false
                                end
                                if string.match(msg, "recording") == "recording" then
                                    return true
                                else
                                    return false
                                end
                            end,
                            color = { fg = "#ff9e64" },
                        },
                        'encoding',
                    },
                    lualine_y = {
                        { 'filetype', separator = { left = '' }, right_padding = 2 },
                    },
                    lualine_z = {
                        { '%3l/%L:%2v', separator = { right = '' } },
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = {},
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {}
                },
                tabline = {
                    lualine_a = { {
                        "tabs",
                        max_length = o.columns * 2 / 3,
                        mode = 2,
                        fmt = function(name, context)
                            local emptyName = '[No Name]'
                            local buflist = fn.tabpagebuflist(context.tabnr)
                            local winnr = fn.tabpagewinnr(context.tabnr)
                            local bufnr = buflist[winnr]
                            local winid = fn.win_getid(winnr, context.tabnr)
                            local bufferPath = fn.bufname(bufnr)
                            local project_icon = fn.tabpagenr() == context.tabnr and " " or " "
                            local file_icon = fn.tabpagenr() == context.tabnr and " " or " "
                            if bufferPath == "" then
                                return emptyName .. file_icon
                            end
                            if api.nvim_buf_get_option(bufnr, 'buftype') == "nofile" then
                                return bufferPath .. file_icon
                            end

                            if bufferPath:sub(1, 1) ~= '/' then
                                bufferPath = fn.getcwd() .. "/" .. bufferPath

                                local title = fn.findfile('.git', bufferPath .. ';')
                                if title == "" then
                                    title = fn.finddir('.git', bufferPath .. ';')
                                end
                                title = fn.getcwd() .. "/" .. title
                                return fn.fnamemodify(title, ':h:t') .. project_icon
                            end

                            local title = fn.findfile('.git', bufferPath .. ';')
                            if title == "" then
                                title = fn.finddir('.git', bufferPath .. ';')
                            end

                            if title == "" then
                                if fn.getqflist({ ['qfbufnr'] = 0 }).qfbufnr == bufnr then
                                    return '[Quickfix List]'
                                elseif winid and fn.getloclist(winid, { ['qfbufnr'] = 0 }).qfbufnr == bufnr then
                                    return '[Location List]'
                                end
                                return fn.fnamemodify(bufferPath, ':p:t') .. file_icon
                            end

                            return fn.fnamemodify(title, ':h:t') .. project_icon
                        end,
                        separator = { left = '', right = '' },
                        tabs_color = {
                            -- Same values as the general color option can be used here.
                            -- active = { fg = colors.black, bg = colors.grey },
                            inactive = { fg = colors.fg, bg = colors.color }, -- Color for inactive tab.
                        },
                    } },
                    lualine_x = { {
                        'windows',
                        show_filename_only = false,  -- Shows shortened relative path when set to false.
                        show_modified_status = true, -- Shows indicator when the window is modified.
                        symbols = { modified = ' ' .. glyphs["modified"] },
                        mode = 0,                    -- 0: Shows window name
                        -- 1: Shows window index
                        -- 2: Shows window name + window index

                        max_length = vim.o.columns * 2 / 3, -- Maximum width of windows component,
                        -- it can also be a function that returns
                        -- the value of `max_length` dynamically.
                        filetype_names = {
                            TelescopePrompt = 'Telescope',
                            dashboard = 'Dashboard',
                            packer = 'Packer',
                            fzf = 'FZF',
                            alpha = 'Alpha'
                        },                                                     -- Shows specific window name for that filetype ( { `filetype` = `window_name`, ... } )
                        disabled_buftypes = { 'quickfix', 'prompt' },          -- Hide a window if its buffer's type is disabled,
                        windows_color = {
                            active = { fg = colors.fg, bg = colors.color },    -- Color for active window.
                            inactive = { fg = colors.fg2, bg = colors.color }, -- Color for inactive window.
                        },
                        separator = { left = '' },
                    } },
                    lualine_z = { {
                        function() return "󰔛 " .. os.date('%H:%M') end,
                        separator = { right = '' }
                    } },
                },
                winbar = {},
                inactive_winbar = {},
                extensions = {
                    'aerial',
                    'chadtree',
                    'fern',
                    'fugitive',
                    'fzf',
                    'man',
                    'mundo',
                    'neo-tree',
                    'nerdtree',
                    'nvim-dap-ui',
                    'nvim-tree',
                    'quickfix',
                    'symbols-outline',
                    'toggleterm',
                }
            })
        end,
    },
    {
        'linrongbin16/lsp-progress.nvim',
        event = "LspAttach",
        dependencies = { "nvim-lualine/lualine.nvim" },
        config = function()
            require("lsp-progress").setup {
                format = function(client_messages)
                    return #client_messages > 0
                        and (" LSP " .. table.concat(client_messages, " "))
                        or ""
                end,
                decay = 3000,
            }

            local old = require("lualine").get_config()
            table.insert(old.sections.lualine_x, 1, require("lsp-progress").progress)
            require("lualine").setup(old)

            local lualine_augroup = api.nvim_create_augroup("LualineAugroup", { clear = true })
            api.nvim_create_autocmd(
                { "User" },
                {
                    pattern = "LspProgressStatusUpdated",
                    callback = function()
                        require("lualine").refresh({
                            scope = 'tabpage',
                            place = { 'statusline' }
                        })
                    end,
                    group = lualine_augroup,
                }
            )
        end
    },
    {
        'stevearc/dressing.nvim',
        event = "VeryLazy",
        opts = {},
    },
    {
        "rcarriga/nvim-notify",
        lazy = true,
        config = function()
            local glyphs = require("common").glyphs
            local scroll_to_tobbom = function(win, buf)
                local content_line_cnt = api.nvim_buf_line_count(buf)
                local win_height = api.nvim_win_get_height(win)
                local scroll_interal_millisec = 30

                local func = nil
                func = function(cnt)
                    if api.nvim_win_is_valid(win) then
                        api.nvim_win_set_cursor(win, { content_line_cnt - cnt, 0 })
                    else
                        return
                    end

                    if cnt > 0 then
                        vim.defer_fn(function()
                            func(cnt - math.ceil(cnt / 10))
                        end, scroll_interal_millisec)
                    end
                end

                if content_line_cnt > win_height then
                    func(win_height)
                end
            end

            require("notify").setup({
                background_colour = "Normal",
                fps = 30,
                icons = {
                    DEBUG = glyphs["debug"],
                    ERROR = glyphs["error"],
                    INFO = glyphs["info"],
                    TRACE = glyphs["trace"],
                    WARN = glyphs["warn"],
                },
                level = 2,
                minimum_width = 50,
                max_height = vim.o.lines - 4,
                max_width = vim.o.columns,
                render = "default",
                stages = "fade_in_slide_out",
                timeout = 5000,
                top_down = true,
                on_open = function(win)
                    local buf = api.nvim_win_get_buf(win)
                    api.nvim_buf_attach(buf, false, {
                        on_lines = function()
                            vim.defer_fn(function()
                                scroll_to_tobbom(win, buf)
                            end, 100)
                        end
                    })

                    scroll_to_tobbom(win, buf)
                end,
            })


            local notifyClear = function()
                local wins = api.nvim_tabpage_list_wins(0)
                for _, v in pairs(wins) do
                    local buf = api.nvim_win_get_buf(v)
                    local ft = api.nvim_buf_get_option(buf, 'filetype')
                    if ft == "notify" then api.nvim_win_close(v, false) end
                end
            end

            api.nvim_create_user_command(
                "NotifyClear",
                notifyClear,
                {})

            km.set('n', "<c-[>", function()
                vim.cmd("mode")
                notifyClear()
            end, { noremap = true, silent = true, desc = "refresh screen" })
        end
    },
    {
        "folke/noice.nvim",
        enabled = true,
        event = "VeryLazy",
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            "rcarriga/nvim-notify",
        },
        opts = {
            lsp = {
                progress = {
                    enabled = false,
                },
                hover = {
                    enabled = false
                },
                signature = {
                    enabled = false,
                },
                documentation = {
                    view = false,
                },
                message = {
                    enabled = true,
                    view = "notify",
                    opts = {},
                },
                -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
                    ["vim.lsp.util.stylize_markdown"] = false,
                    ["cmp.entry.get_documentation"] = false,
                },
            },
            -- you can enable a preset for easier configuration
            presets = {
                -- you can enable a preset by setting it to true, or a table that will override the preset config
                -- you can also add custom presets that you can enable/disable with enabled=true
                bottom_search = true,              -- use a classic bottom cmdline for search
                command_palette = true,            -- position the cmdline and popupmenu together
                long_message_to_split = false,     -- long messages will be sent to a split
                inc_rename = false,                -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = false,            -- add a border to hover docs and signature help
            },
            cmdline = {
                enabled = true,             -- enables the Noice cmdline UI
                view = "cmdline_popup",     -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom,option cmdline_popup
                opts = {},                  -- global options for the cmdline. See section on views
                format = {
                    -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
                    -- view: (default is cmdline view)
                    -- opts: any options passed to the view
                    -- icon_hl_group: optional hl_group for the icon
                    -- title: set to anything or empty string to hide
                    cmdline = { pattern = "^:", icon = "", lang = "vim" },
                    search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
                    search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
                    filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
                    lua = { pattern = "^:%s*lua%s+", icon = require("common").glyphs["lua"], lang = "lua" },
                    help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
                    input = {},     -- Used by input()
                    -- lua = false, -- to disable a format, set to `false`
                },
            },
            messages = {
                enabled = true,                -- enables the Noice messages UI
                view = "notify",               -- default view for messages
                view_error = "notify",         -- view for errors
                view_warn = "notify",          -- view for warnings
                view_history = "messages",     -- view for :messages
                view_search = false,           -- view for search count messages. Set to `false` to disable
            },
            popupmenu = {
                enabled = false,     -- enables the Noice popupmenu UI
                ---@type 'nui'|'cmp'
                backend = "nui",     -- backend to use to show regular cmdline completions
                -- Icons for completion item kinds (see defaults at noice.config.icons.kinds)
                kind_icons = {},     -- set to `false` to disable icons
            },
            redirect = {
                view = "popup",
                filter = { event = "msg_show" },
            },
            routes = {
                {
                    filter = { event = "msg_show", kind = "search_count" },
                    opts = { skip = true },
                },
            },
            commands = {
                history = {
                    -- options for the message history that you get with `:Noice`
                    view = "split",
                    opts = { enter = true, format = "details" },
                    filter = {
                        any = {
                            { event = "notify" },
                            { error = true },
                            { warning = true },
                            { event = "msg_show", kind = { "" } },
                            { event = "lsp",      kind = "message" },
                        },
                    },
                },
                -- :Noice last
                last = {
                    view = "popup",
                    opts = { enter = true, format = "details" },
                    filter = {
                        any = {
                            { event = "notify" },
                            { error = true },
                            { warning = true },
                            { event = "msg_show", kind = { "" } },
                            { event = "lsp",      kind = "message" },
                        },
                    },
                    filter_opts = { count = 1 },
                },
                -- :Noice errors
                errors = {
                    -- options for the message history that you get with `:Noice`
                    view = "popup",
                    opts = { enter = true, format = "details" },
                    filter = { error = true },
                    filter_opts = { reverse = true },
                },
            },
            notify = {
                -- Noice can be used as `vim.notify` so you can route any notification like other messages
                -- Notification messages have their level and other properties set.
                -- event is always "notify" and kind can be any log level as a string
                -- The default routes will forward notifications to nvim-notify
                -- Benefit of using Noice for this is the routing and consistent history view
                enabled = true,
                view = "notify",
            },
        }
    },
    {
        'MR-LLLLL/interestingwords.nvim',
        dependencies = { "nvim-lualine/lualine.nvim" },
        keys = {
            { "<leader>k", nil, mode = { "n", "v" } },
            { "<leader>m", nil, mode = { "n", "v" } },
            { "n",         nil, mode = { "n", "v" } },
            { "N",         nil, mode = { "n", "v" } },
            { "/",         nil, mode = { "n", "v" } },
        },
        config = function()
            require("interestingwords").setup {
                colors = { '#6CBBDA', '#A4C5EA', '#DFDB72', '#ff5e63', '#ff9036', '#CF9292', '#BFA3DF', '#9999EA' },
                search_key = "<leader>m",
                color_key = "<leader>k",
            }

            local old = require("lualine").get_config()
            table.insert(old.sections.lualine_x, #old.sections.lualine_x, {
                require("interestingwords").lualine_get,
                cond = require("interestingwords").lualine_has,
                color = { fg = "#ff9e64" },
            })
            require("lualine").setup(old)
        end,
    },
    {
        'lukas-reineke/indent-blankline.nvim',
        event = "VeryLazy",
        opts = {
            space_char_blankline = " ",
            show_current_context = true,
            show_current_context_start = false,
            filetype_exclude = { 'dashboard' }
        }
    },
    {
        'eandrju/cellular-automaton.nvim',
        cmd = "CellularAutomaton",
    },
    {
        "RRethy/vim-illuminate",
        event = "CursorHold",
        config = function()
            require('illuminate').configure({
                modes_allowlist = { 'n', 'v', 'V', '' },
            })

            km.set("v", "<a-n>", require("illuminate").goto_next_reference,
                { noremap = true, silent = true, desc = "illuminate move to next reference" })
            km.set("v", "<a-p>", require("illuminate").goto_prev_reference,
                { noremap = true, silent = true, desc = "illuminate move to prev reference" })
            km.set("n", "<a-i>", require("illuminate").textobj_select,
                { noremap = true, silent = true, desc = "illuminate visual current node" })
        end
    },
    {
        "Bekaboo/dropbar.nvim",
        enabled = false,
        event = "VeryLazy",
        config = function()
            local icons = {}
            for k, v in pairs(require("common").treesiter_symbol) do
                vim.api.nvim_set_hl(0, "DropBarIconKind" .. k, { link = v[2] })
                vim.api.nvim_set_hl(0, "DropBarKind" .. k, { link = v[2] })
                icons[k] = v[1]
            end

            require('dropbar').setup {
                menu = {
                    preview = true,
                    quick_navigation = true,
                    win_configs = {
                        border = 'rounded',
                    },
                    keymaps = {
                        ['<esc>'] = function()
                            while true do
                                local menu = require('dropbar.api').get_current_dropbar_menu()
                                if not menu then
                                    return
                                end
                                menu:close()
                            end
                        end,
                        ['q'] = function()
                            local menu = require('dropbar.api').get_current_dropbar_menu()
                            if not menu then
                                return
                            end
                            menu:close()
                        end,
                        ['o'] = function()
                            local menu = require('dropbar.api').get_current_dropbar_menu()
                            if not menu then
                                return
                            end
                            local cursor = vim.api.nvim_win_get_cursor(menu.win)
                            local component = menu.entries[cursor[1]]:first_clickable(0)
                            if component then
                                menu:click_on(component, nil, 1, 'l')
                            end
                        end,
                        ['<CR>'] = function()
                            local menu = require('dropbar.api').get_current_dropbar_menu()
                            if not menu then
                                return
                            end
                            local cursor = vim.api.nvim_win_get_cursor(menu.win)
                            local component, range = menu.entries[cursor[1]]:first_clickable(0)
                            if component then
                                local next_component = menu.entries[cursor[1]]:first_clickable(range['end'])
                                if next_component then
                                    menu:click_on(next_component, nil, 1, 'l')
                                else
                                    menu:click_on(component, nil, 1, 'l')
                                end
                            end
                        end,
                    }
                },
                sources = {
                },
                bar = {
                    sources = function(_, _)
                        local sources = require('dropbar.sources')
                        return {
                            -- sources.path,
                            {
                                get_symbols = function(buf, win, cursor)
                                    if vim.bo[buf].ft == 'markdown' then
                                        return sources.markdown.get_symbols(buf, win, cursor)
                                    end
                                    for _, source in ipairs({
                                        sources.lsp,
                                        sources.treesitter,
                                    }) do
                                        local symbols = source.get_symbols(buf, win, cursor)
                                        if not vim.tbl_isempty(symbols) then
                                            return symbols
                                        end
                                    end
                                    return {}
                                end,
                            },
                        }
                    end,
                    padding = {
                        left = 1,
                        right = 1,
                    },
                    pick = {
                        pivots = 'abcdefghijklmnopqrstuvwxyz',
                    },
                    truncate = true,
                },
                icons = {
                    kinds = {
                        symbols = icons
                    }
                },
                symbol = {
                    jump = {
                        ---@param win integer source window id
                        ---@param range {start: {line: integer}, end: {line: integer}} 0-indexed
                        reorient = function(win, range)
                            local view = vim.fn.winsaveview()
                            local win_height = vim.api.nvim_win_get_height(win)
                            local topline = range.start.line - math.floor(win_height / 2)
                            if
                                topline > view.topline
                                and topline + win_height < vim.fn.line('$')
                            then
                                view.topline = topline
                                vim.fn.winrestview(view)
                            end
                        end,
                    },
                }
            }

            vim.api.nvim_set_hl(0, "DropBarMenuCurrentContext", { bg = '#425047', blend = vim.g.custom_blend })

            km.set(
                { 'n' },
                "<leader>q",
                function() require('dropbar.api').pick() end,
                { noremap = true, silent = true, desc = "Dropbar Pick" }
            )
        end
    },
    {
        'kevinhwang91/nvim-ufo',
        event = "VeryLazy",
        dependencies = 'kevinhwang91/promise-async',
        config = function()
            local ftMap = {
                vim = 'indent',
                python = { 'indent' },
                git = ''
            }

            local handler = function(virtText, lnum, endLnum, width, truncate)
                local newVirtText = {}
                local suffix = ('  %d '):format(endLnum - lnum)
                local sufWidth = vim.fn.strdisplaywidth(suffix)
                local targetWidth = width - sufWidth
                local curWidth = 0
                for _, chunk in ipairs(virtText) do
                    local chunkText = chunk[1]
                    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    if targetWidth > curWidth + chunkWidth then
                        table.insert(newVirtText, chunk)
                    else
                        chunkText = truncate(chunkText, targetWidth - curWidth)
                        local hlGroup = chunk[2]
                        table.insert(newVirtText, { chunkText, hlGroup })
                        chunkWidth = vim.fn.strdisplaywidth(chunkText)
                        -- str width returned from truncate() may less than 2nd argument, need padding
                        if curWidth + chunkWidth < targetWidth then
                            suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
                        end
                        break
                    end
                    curWidth = curWidth + chunkWidth
                end
                table.insert(newVirtText, { suffix, 'CustomVirtualText' })
                return newVirtText
            end

            ---@param bufnr number
            local function customizeSelector(bufnr)
                local function handleFallbackException(err, providerName)
                    if type(err) == 'string' and err:match('UfoFallbackException') then
                        return require('ufo').getFolds(bufnr, providerName)
                    else
                        return require('promise').reject(err)
                    end
                end

                return require('ufo').getFolds(bufnr, 'lsp'):catch(function(err)
                    return handleFallbackException(err, 'treesitter')
                end):catch(function(err)
                    return handleFallbackException(err, 'indent')
                end)
            end

            require('ufo').setup({
                fold_virt_text_handler = handler,
                open_fold_hl_timeout = 150,
                close_fold_kinds = { 'imports', 'comment' },
                preview = {
                    win_config = {
                        border = { '', '─', '', '', '', '─', '', '' },
                        winhighlight = 'Normal:Folded',
                        winblend = vim.g.custom_blend
                    },
                    mappings = {
                        scrollU = '<C-u>',
                        scrollD = '<C-d>',
                        jumpTop = '[',
                        jumpBot = ']'
                    }
                },
                provider_selector = function(_, filetype, _)
                    -- if you prefer treesitter provider rather than lsp,
                    -- return ftMap[filetype] or {'treesitter', 'indent'}
                    return ftMap[filetype] or customizeSelector

                    -- refer to ./doc/example.lua for detail
                end
            })

            km.set('n', 'zR', require('ufo').openAllFolds)
            km.set('n', 'zM', require('ufo').closeAllFolds)
            km.set('n', 'zr', require('ufo').openFoldsExceptKinds)
            km.set('n', 'zm', require('ufo').closeFoldsWith)
            km.set('n', '[z', require('ufo').goPreviousClosedFold,
                { noremap = true, silent = true, desc = 'goto previous closed fold' })
            km.set('n', ']z', require('ufo').goNextClosedFold,
                { noremap = true, silent = true, desc = 'goto next closed fold' })

            vim.api.nvim_set_hl(0, "Folded", { link = 'Normal' })
        end
    }
}
