local km = vim.keymap
local cmd = vim.cmd
local g = vim.g
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

    km.set({ 'n', 't' }, "<M-w>", function()
        cmd(get_curr_value() .. 'ToggleTerm')
    end, { noremap = true, silent = true, desc = "ToggleTerm toggle terminal" })
    km.set({ 'n', 't' }, "<M-e>", function()
        if get_curr_value() == get_next_value(get_curr_value()) then
            return
        else
            set_curr_value(get_next_value(get_curr_value()))
        end
        cmd(get_curr_value() .. 'ToggleTerm')
    end, { noremap = true, silent = true, desc = "ToggleTerm next terminal" })
    km.set({ 'n', 't' }, "<M-q>", function()
        if get_curr_value() == get_prev_value(get_curr_value()) then
            return
        else
            set_curr_value(get_prev_value(get_curr_value()))
        end
        cmd(get_curr_value() .. 'ToggleTerm')
    end, { noremap = true, silent = true, desc = "ToggleTerm prev terminal" })
    km.set({ 'n', 't' }, "<M-r>", function()
        set_curr_value(get_max_value() + 1)
        cmd(get_curr_value() .. 'ToggleTerm')
    end, { noremap = true, silent = true, desc = "ToggleTerm new terminal" })
    km.set({ 'n', 't' }, "<M-s>", function()
        cmd(get_curr_value() .. "TermExec cmd=exit dir=~")
    end, { noremap = true, silent = true, desc = "ToggleTerm reset current terminal" })

    local mongoTerm
    local mongo = function()
        if mongoTerm == nil then
            set_curr_value(get_max_value() + 1)
            mongoTerm = require("toggleterm.terminal").Terminal:new({
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
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            popup_mappings = {
                scroll_down = '<c-f>', -- binding to scroll down inside the popup
                scroll_up = '<c-b>',   -- binding to scroll up inside the popup
            },
            layout = {
                height = { min = 4, max = 25 }, -- min and max height of the columns
                width = { min = 20, max = 50 }, -- min and max width of the columns
                spacing = 3,                    -- spacing between columns
                align = "left",                 -- align columns left, center or right
            },
            window = {
                border = "rounded",       -- none, single, double, shadow
                position = "bottom",      -- bottom, top
                margin = { 1, 0, 1, 0 },  -- extra window margin [top, right, bottom, left]
                padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
                winblend = vim.g.custom_blend
            },
            disable = {
                buftypes = {},
                filetypes = { "TelescopePrompt" },
            },
        }
    },
    {
        'numToStr/Comment.nvim',
        keys = {
            { "<leader>/", nil, mode = { "n", "v" } }
        },
        config = function()
            require('Comment').setup({
                -- -Add a space b/w comment and the line
                padding = true,
                ---Whether the cursor should stay at its position
                sticky = true,
                ---Lines to be ignored while (un)comment
                ignore = nil,
                ---LHS of toggle mappings in NORMAL mode
                toggler = {
                    ---Line-comment toggle keymap
                    line = 'gcc',
                    ---Block-comment toggle keymap
                    block = 'gbc',
                },
                ---LHS of operator-pending mappings in NORMAL and VISUAL mode
                opleader = {
                    ---Line-comment keymap
                    line = 'gc',
                    ---Block-comment keymap
                    block = 'gb',
                },
                ---LHS of extra mappings
                extra = {
                    ---Add comment on the line above
                    above = 'gcO',
                    ---Add comment on the line below
                    below = 'gco',
                    ---Add comment at the end of line
                    eol = 'gcA',
                },
                ---Enable keybindings
                ---NOTE: If given `false` then the plugin won't create any mappings
                mappings = {
                    ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
                    basic = false,
                    ---Extra mapping; `gco`, `gcO`, `gcA`
                    extra = false,
                },
                ---Function to call before (un)comment
                pre_hook = nil,
                ---Function to call after (un)comment
                post_hook = nil,
            })

            -- forbid default mapping, customer my key mapping
            km.set("n", "<leader>/", '<Plug>(comment_toggle_linewise)', { desc = 'Comment toggle linewise' })
            km.set("n",
                "<leader>//",
                function()
                    return api.nvim_get_vvar('count') == 0 and '<Plug>(comment_toggle_linewise_current)'
                        or '<Plug>(comment_toggle_linewise_count)'
                end,
                { expr = true, desc = 'Comment toggle current line' })
            km.set(
                "x",
                "<leader>/",
                '<Plug>(comment_toggle_linewise_visual)',
                { desc = 'Comment toggle linewise (visual)' })
        end
    },
    {
        "folke/todo-comments.nvim",
        event = "VeryLazy",
        config = function()
            require("todo-comments").setup({})

            vim.keymap.set(
                "n",
                "]t",
                function() require("todo-comments").jump_next() end,
                { desc = "Next todo comment" }
            )

            vim.keymap.set(
                "n",
                "[t",
                function() require("todo-comments").jump_prev() end,
                { desc = "Previous todo comment" }
            )
        end
    },
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        keys = {
            { "<M-w>", nil }
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
                        guifg = "#5c6a72",
                        guibg = "#2d353b",
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
        'tpope/vim-repeat',
        event = "VeryLazy",
    },
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {
            search = {
                multi_window = true,
            },
            modes = {
                search = {
                    -- when `true`, flash will be activated during regular search by default.
                    -- You can always toggle when searching with `require("flash").toggle()`
                    enabled = true,
                    highlight = { backdrop = false },
                    jump = { history = true, register = true, nohlsearch = true },
                    search = {
                        -- `forward` will be automatically set to the search direction
                        -- `mode` is always set to `search`
                        -- `incremental` is set to `true` when `incsearch` is enabled
                    },
                },
                char = {
                    enabled = true,
                    highlight = { backdrop = false },
                    multi_line = false,
                },
                treesitter = {
                    labels = "abefgimnopqrstuwz",
                    jump = { pos = "range" },
                    search = { incremental = false },
                    label = { before = true, after = true, style = "inline" },
                    highlight = {
                        backdrop = false,
                        matches = false,
                    },
                },
            },
            label = {
                -- allow uppercase labels
                uppercase = false,
            }
        },
        keys = {
            {
                "S",
                mode = { "n" },
                function() require("flash").jump({ multi_window = true }) end,
                desc = "Flash",
            },
            {
                "s",
                mode = { "n", "o", "x" },
                function() require("flash").treesitter() end,
                desc =
                "Flash Treesitter"
            },
            {
                "r",
                mode = "o",
                function() require("flash").remote() end,
                desc =
                "Remote Flash"
            },
            { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
        },
    },
    -- {
    --     'ggandor/leap.nvim',
    --     enabled = false,
    --     keys = {
    --         { "s",  nil, mode = { "n", "v" } },
    --         { "gs", nil, mode = { "n", "v" } },
    --         { "S",  nil, mode = { "n", "v" } },
    --     },
    --     config = function()
    --         require('leap').setup({
    --             -- max_phase_one_targets = nil,
    --             -- highlight_unlabeled_phase_one_targets = false,
    --             -- max_highlighted_traversal_targets = 10,
    --             -- case_sensitive = false,
    --             -- equivalence_classes = { ' \t\r\n', },
    --             -- substitute_chars = {},
    --             -- special_keys = {
    --             --     repeat_search = '<enter>',
    --             --     next_phase_one_target = '<enter>',
    --             --     next_target = { '<enter>', ';' },
    --             --     prev_target = { '<tab>', ',' },
    --             --     next_group = '<space>',
    --             --     prev_group = '<tab>',
    --             --     multi_accept = '<enter>',
    --             --     multi_revert = '<backspace>',
    --             -- }
    --         })
    --         km.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward-to)", { noremap = true, silent = true })
    --         km.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward-to)", { noremap = true, silent = true })
    --         km.set({ "n", "x", "o" }, "gs", "<Plug>(leap-cross-window)", { noremap = true, silent = true })
    --     end
    -- },
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
                        { "n", "<leader>2", actions.conflict_choose("ours"),
                            {
                                desc =
                                "Choose the OURS version of a conflict"
                            } },
                        { "n", "<leader>3", actions.conflict_choose("theirs"),
                            { desc = "Choose the THEIRS version of a conflict" } },
                        { "n", "<leader>b", actions.conflict_choose("base"),
                            {
                                desc =
                                "Choose the BASE version of a conflict"
                            } },
                        { "n", "<leader>a", actions.conflict_choose("all"),
                            {
                                desc =
                                "Choose all the versions of a conflict"
                            } },
                        { "n", "<leader>x", actions.conflict_choose("none"), { desc = "Delete the conflict region" } },
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
        'ThePrimeagen/refactoring.nvim',
        dependencies = {
            'nvim-telescope/telescope.nvim',
        },
        keys = {
            { "<leader>rf", nil, mode = { "n", "v" } }
        },
        config = function()
            require('refactoring').setup({
                -- prompt for return type
                prompt_func_return_type = {
                    go = true,
                    cpp = true,
                    c = true,
                    java = true,
                },
                -- prompt for function parameters
                prompt_func_param_type = {
                    go = true,
                    cpp = true,
                    c = true,
                    java = true,
                },
            })

            -- remap to open the Telescope refactoring menu in visual mode
            km.set(
                { 'v', 'n' },
                "<leader>rf",
                "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>",
                { noremap = true }
            )

            require("telescope").load_extension("refactoring")
        end
    },
    {
        'Abstract-IDE/penvim',
        event = "VeryLazy",
        config = function()
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
    },
    {
        'Mr-LLLLL/treesitter-outer',
        ft = { "lua", "python" },
        opts = {
            filetypes = { "lua", "python" }
        },
    },
}
