local api = vim.api
local km = vim.keymap
local fn = vim.fn
local o = vim.o
local g = vim.g

local m = {}

local function load_dress()
    require('dressing').setup({})
end

local function load_noice()
    require("noice").setup({
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
            bottom_search = true,          -- use a classic bottom cmdline for search
            command_palette = true,        -- position the cmdline and popupmenu together
            long_message_to_split = false, -- long messages will be sent to a split
            inc_rename = false,            -- enables an input dialog for inc-rename.nvim
            lsp_doc_border = false,        -- add a border to hover docs and signature help
        },
        cmdline = {
            enabled = false,        -- enables the Noice cmdline UI
            view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom,option cmdline_popup
            opts = {},              -- global options for the cmdline. See section on views
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
                lua = { pattern = "^:%s*lua%s+", icon = require("core.common").glyphs["lua"], lang = "lua" },
                help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
                input = {}, -- Used by input()
                -- lua = false, -- to disable a format, set to `false`
            },
        },
        messages = {
            enabled = true,            -- enables the Noice messages UI
            view = "notify",           -- default view for messages
            view_error = "notify",     -- view for errors
            view_warn = "notify",      -- view for warnings
            view_history = "messages", -- view for :messages
            view_search = false,       -- view for search count messages. Set to `false` to disable
        },
        popupmenu = {
            enabled = false, -- enables the Noice popupmenu UI
            ---@type 'nui'|'cmp'
            backend = "nui", -- backend to use to show regular cmdline completions
            -- Icons for completion item kinds (see defaults at noice.config.icons.kinds)
            kind_icons = {}, -- set to `false` to disable icons
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
    })

    require("telescope").load_extension("noice")
end

local function load_notify()
    local glyphs = require("core.common").glyphs
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
        render = "default",
        stages = "fade_in_slide_out",
        timeout = 5000,
        top_down = true
    })

    local notify_quit = api.nvim_create_augroup("NotifyQuit", { clear = true })
    api.nvim_create_autocmd(
        { "Filetype" },
        {
            pattern = "notify",
            callback = function()
                km.set('n', 'q', '<cmd>quit<cr>', { noremap = true, silent = true, buffer = true })
            end,
            group = notify_quit,
        }
    )
    require("telescope").load_extension("notify")
end

local function load_dashboard()
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
                    action = 'PackerSync',
                    key = 'u',
                },
                {
                    desc = ' Frecency Files',
                    group = 'Constant',
                    action = 'Telescope frecency',
                    key = 'f',
                },
                {
                    desc = ' Projects',
                    group = 'Special',
                    action = require("core.common").get_tele_project,
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

local function load_lualine()
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

    local glyphs = require("core.common").glyphs

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
                require("lsp-progress").progress,
                -- {
                --   require("noice").api.status.message.get_hl,
                --   cond = require("noice").api.status.message.has,
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
                {
                    require("interestingwords").lualine_get,
                    cond = require("interestingwords").lualine_has,
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
                ---@diagnostic disable-next-line: unused-local
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
                function() return "祥" .. os.date('%H:%M') end,
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

    require('lsp-progress').setup({
        format = function(client_messages)
            return #client_messages > 0
                and (" LSP " .. table.concat(client_messages, " "))
                or ""
        end,
        decay = 3000,
    })
    -- listen to user event and trigger lualine refresh
    local lualine_augroup = api.nvim_create_augroup("LualineAugroup", { clear = true })
    api.nvim_create_autocmd(
        { "User" },
        {
            pattern = "LspProgressStatusUpdated",
            callback = function()
                require("lualine").refresh()
            end,
            group = lualine_augroup,
        }
    )
end

local function load_nvim_tree()
    local glyphs = require("core.common").glyphs
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

    km.set("n", "<space>q", "<cmd>NvimTreeFindFileToggle<cr>", { noremap = true, silent = true })

    if vim.g.colors_name == 'gruvbox-material' then
        api.nvim_set_hl(0, "NvimTreeCursorLine", { bg = '#3c3836' })
    elseif vim.g.colors_name == 'everforest' then
        api.nvim_set_hl(0, "NvimTreeCursorLine", { bg = '#374145' })
    end
    api.nvim_set_hl(0, "NvimTreeNormal", { link = 'Normal' })
    api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { link = 'EndOfBuffer' })
end

local function load_neovide()
    if g.neovide == nil then
        return
    end
    g.neovide_fullscreen = true
    g.neovide_confirm_quit = true
    g.neovide_floating_blur_amount_x = 1.0
    g.neovide_floating_blur_amount_y = 1.0
    g.neovide_transparency = 1.0
    g.neovide_scroll_animation_length = 0.3
    g.neovide_cursor_trail_size = 0.8
    g.neovide_cursor_antialiasing = true
    -- g.neovide_cursor_animation_length=1.00
    g.neovide_cursor_unfocused_outline_width = 0.125
    g.neovide_hide_mouse_when_typing = true
    g.neovide_underline_automatic_scaling = true
    g.neovide_refresh_rate = 60
    g.neovide_refresh_rate_idle = 5
    g.neovide_remember_window_size = true
    g.neovide_profiler = false
    g.neovide_cursor_vfx_mode = "pixiedust"
    g.neovide_cursor_vfx_particle_density = 50.0
    g.neovide_cursor_vfx_opacity = 200.0
    g.neovide_cursor_vfx_particle_phase = 1.5
    g.neovide_cursor_vfx_particle_curl = 1.0
    g.neovide_cursor_vfx_particle_lifetime = 1.2
    g.neovide_cursor_vfx_particle_speed = 10.0
    g.neovide_cursor_animate_command_line = true
    g.neovide_cursor_animate_in_insert_mode = true

    km.set({ 'i', 'n', 'c' }, "<C-S-v>", "<C-r>*", { noremap = true, silent = true })
    -- BUG: it's not work, and will be block
    -- km.set({ 't' }, "<C-R>", '<C-\\><C-N>"' .. fn.nr2char(fn.getchar()) .. 'pi',
    --     { silent = true, expr = true })
    km.set({ 't' }, "<C-S-v>", '<C-\\><C-N>"*pi', { noremap = false, silent = true })

    km.set(
        { 'n' },
        "F11",
        function() if g.neovide_fullscreen then g.neovide_fullscreen = false else g.neovide_fullscreen = true end end,
        { noremap = true, silent = true, expr = true }
    )

    g.neovide_scale_factor = 1.0
    local function scale(delta)
        g.neovide_scale_factor = g.neovide_scale_factor * delta
    end

    km.set({ 'n' }, "<c-=>", function() scale(1.25) end, { noremap = true, silent = true, expr = true })
    km.set({ 'n' }, "<c-->", function() scale(1 / 1.25) end, { noremap = true, silent = true, expr = true })
end

local function load_colorizer()
    require('ccc').setup({
        highlighter = {
            auto_enable = false,
            lsp = true,
        },
    })
end

local function load_interesting()
    require("interestingwords").setup({
        colors = { '#6CBBDA', '#A4C5EA', '#DFDB72', '#ff5e63', '#ff9036', '#CF9292', '#BFA3DF', '#9999EA' }
    })
end

local function load_cursor_word()
    require('illuminate').configure({
        modes_allowlist = { 'n', 'v', 'V', '' },
    })

    km.set("v", "<a-n>", require("illuminate").goto_next_reference, { noremap = true, silent = true })
    km.set("v", "<a-p>", require("illuminate").goto_prev_reference, { noremap = true, silent = true })
    km.set("n", "<a-i>", require("illuminate").textobj_select, { noremap = true, silent = true })
end

local function load_gitsigns()
    require('gitsigns').setup({
        signs = {
            add          = { hl = 'GitSignsAdd', text = '│', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
            change       = { hl = 'GitSignsChange', text = '│', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
            delete       = { hl = 'GitSignsDelete', text = '_', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
            topdelete    = { hl = 'GitSignsDelete', text = '‾', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
            changedelete = { hl = 'GitSignsChange', text = '~', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
            untracked    = { hl = 'GitSignsAdd', text = '┆', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
        },
        on_attach = function(bufnr)
            local gs = package.loaded.gitsigns

            local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
            end

            -- Navigation
            map('n', ']c', function()
                if vim.wo.diff then return ']c' end
                vim.schedule(function() gs.next_hunk() end)
                return '<Ignore>'
            end, { expr = true })

            map('n', '[c', function()
                if vim.wo.diff then return '[c' end
                vim.schedule(function() gs.prev_hunk() end)
                return '<Ignore>'
            end, { expr = true })

            -- Actions
            map({ 'n', 'v' }, '<leader>gs', ':Gitsigns stage_hunk<CR>')
            map({ 'n', 'v' }, '<leader>gr', ':Gitsigns reset_hunk<CR>')
            map('n', '<leader>gS', gs.stage_buffer)
            map('n', '<leader>gu', gs.undo_stage_hunk)
            map('n', '<leader>gR', gs.reset_buffer)
            map('n', '<leader>gp', gs.preview_hunk)
            map('n', '<leader>gb', function() gs.blame_line { full = true } end)
            map('n', '<leader>gB', gs.toggle_current_line_blame)
            -- map('n', '<leader>gd', gs.diffthis)
            map('n', '<leader>gd', function() gs.diffthis('~') end)
            map('n', '<leader>gD', gs.toggle_deleted)

            -- Text object
            map({ 'o', 'x' }, 'ig', '<esc><cmd>Gitsigns select_hunk<CR>')
        end
    })
end

local function load_guihua()
    require("guihua").setup({
        maps = {
            close_view = '<esc>',
            send_qf = '<C-q>',
            save = '<C-s>',
            jump_to_list = '<C-w>k',
            jump_to_preview = '<C-w>j',
            prev = '<C-k>',
            next = '<C-j>',
            pageup = '<C-b>',
            pagedown = '<C-f>',
            confirm = '<cr>',
            split = '<C-s>',
            vsplit = '<C-v>',
            tabnew = '<C-t>',
        },
    })
end

local function load_wilder()
    local wilder = require('wilder')
    wilder.setup({
        modes = { ':' },
        next_key = "<Tab>",
        previous_key = "<S-Tab>",
    })
    km.set({ 'c' }, "<c-j>", function()
        if wilder.in_context() then
            wilder.next()
        end
    end, { noremap = true, silent = false })
    km.set({ 'c' }, "<c-k>", function()
        if wilder.in_context() then
            wilder.previous()
        end
    end, { noremap = true, silent = false })

    wilder.set_option('pipeline', {
        wilder.branch(
            wilder.cmdline_pipeline({
                fuzzy = 2,
            })
        ),
    })

    local gradient = {
        '#f4468f', '#fd4a85', '#ff507a', '#ff566f', '#ff5e63',
        '#ff6658', '#ff704e', '#ff7a45', '#ff843d', '#ff9036',
        '#f89b31', '#efa72f', '#e6b32e', '#dcbe30', '#d2c934',
        '#c8d43a', '#bfde43', '#b6e84e', '#aff05b'
    }

    for i, fg in ipairs(gradient) do
        gradient[i] = wilder.make_hl('WilderGradient' .. i, 'Pmenu', { { a = 1 }, { a = 1 }, { foreground = fg } })
    end

    wilder.set_option('renderer', wilder.renderer_mux({
        [':'] = wilder.popupmenu_renderer(
            wilder.popupmenu_palette_theme({
                -- 'single', 'double', 'rounded' or 'solid'
                -- can also be a list of 8 characters, see :h wilder#popupmenu_palette_theme() for more details
                pumblend = 20,
                border = 'rounded',
                max_height = '25%', -- max height of the palette
                min_height = 0,     -- set to the same as 'max_height' for a fixed height window
                margin = '15%',
                min_width = '30%',
                prompt_position = 'top', -- 'top' or 'bottom' to set the location of the prompt
                reverse = 0,             -- set to 1 to reverse the order of the list, use in combination with 'prompt_position'
                left = {
                    ' ',
                    wilder.popupmenu_devicons(),
                    wilder.popupmenu_buffer_flags({
                        flags = ' a + ',
                        icons = { ['+'] = '', a = '', h = '' },
                    }),
                },
                right = {
                    ' ',
                    -- wilder.popupmenu_scrollbar(),
                },
                highlights = {
                    border = 'FloatBorder',
                    gradient = gradient, -- must be set
                    selected_gradient = gradient,
                },
                highlighter = wilder.highlighter_with_gradient({
                    wilder.basic_highlighter(), -- or wilder.lua_fzy_highlighter(),
                }),
                empty_message = wilder.popupmenu_empty_message_with_spinner(),
            })
        ),
    }))
end

m.setup = function()
    load_guihua()
    load_notify()
    load_wilder()
    load_noice()
    load_dress()
    load_dashboard()
    load_lualine()
    load_nvim_tree()
    load_neovide()
    load_colorizer()
    load_interesting()
    load_cursor_word()
    load_gitsigns()
end

return m
