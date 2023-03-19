local m              = {}

m.glyphs             = {
    modified = "",
    added = "",
    unmerged = "",
    renamed = "",
    untracked = "ﲉ",
    copied = "",
    deleted = "",
    ignored = "",
    locked = "",
    lua = "",
    debug = "",
    error = "",
    info = "",
    trace = "✎",
    warn = "",
    sign_error = "",
    sign_warn = "",
    sign_hint = "",
    sign_info = "",
}

m.get_tele_project   = function()
    require("telescope").extensions.project.project {
        display_type = 'two-segment',
        attach_mappings = function(prompt_bufnr, map)
            map('i', '<cr>', function()
                require("telescope._extensions.project.actions").change_working_directory(prompt_bufnr
                , false)
                require('telescope').extensions.frecency.frecency({ workspace = 'CWD' })
            end)
            return true
        end,
    }
end

m.get_dapvt_conf     = function()
    return {
        enabled = true,                        -- enable this plugin (the default)
        enabled_commands = true,               -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
        highlight_changed_variables = true,    -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
        highlight_new_as_changed = false,      -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
        show_stop_reason = true,               -- show stop reason when stopped for exceptions
        commented = false,                     -- prefix virtual text with comment string
        only_first_definition = true,          -- only show virtual text at first definition (if there are multiple)
        all_references = false,                -- show virtual text on all all references of the variable (not only definitions)
        filter_references_pattern = '<module', -- filter references (not definitions) pattern when all_references is activated (Lua gmatch pattern, default filters out Python modules)
        -- experimental features:
        virt_text_pos = 'eol',                 -- position of virtual text, see `:h nvim_buf_set_extmark()`
        all_frames = false,                    -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
        virt_lines = false,                    -- show virtual lines instead of virtual text (will flicker!)
        virt_text_win_col = nil                -- position the virtual text at a fixed window column (starting from the first text column) ,
        -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
    }
end

m.get_dapui_conf     = function()
    return {
        icons = { expanded = "", collapsed = "", current_frame = "" },
        mappings = {
            -- Use a table to apply multiple mappings
            expand = { "o", "<2-LeftMouse>" },
            open = "<cr>",
            remove = "d",
            edit = "e",
            -- repl = "r",
            toggle = "t",
        },
        -- Use this to override mappings for specific elements
        element_mappings = {
            -- Example:
            -- stacks = {
            --   open = "<CR>",
            --   expand = "o",
            -- }
        },
        -- Expand lines larger than the window
        -- Requires >= 0.7
        expand_lines = vim.fn.has("nvim-0.7") == 1,
        -- Layouts define sections of the screen to place windows.
        -- The position can be "left", "right", "top" or "bottom".
        -- The size specifies the height/width depending on position. It can be an Int
        -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
        -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
        -- Elements are the elements shown in the layout (in order).
        -- Layouts are opened in order so that earlier layouts take priority in window sizing.
        layouts = {
            {
                elements = {
                    -- Elements can be strings or table with id and size keys.
                    { id = "scopes",  size = 0.80 },
                    { id = "watches", size = 0.20 },
                    -- { id = "breakpoints", size = 0.15 }
                },
                size = 40, -- 40 columns
                position = "left",
            },
            -- {
            --     elements = {
            --         "repl",
            --         "stacks",
            --         -- "console",
            --     },
            --     size = 0.25, -- 25% of total lines
            --     position = "bottom",
            -- },
        },
        controls = {
            -- Requires Neovim nightly (or 0.8 when released)
            enabled = true,
            -- Display controls in this element
            element = "repl",
            icons = {
                pause = "",
                play = "",
                step_into = "",
                step_over = "",
                step_out = "",
                step_back = "",
                run_last = "",
                terminate = "",
            },
        },
        floating = {
            max_height = nil,   -- These can be integers or a float between 0 and 1.
            max_width = nil,    -- Floats will be treated as percentage of your screen.
            border = "rounded", -- Border style. Can be "single", "double" or "rounded"
            mappings = {
                close = { "q", "<Esc>" },
            },
        },
        render = {
            indent = 1,
            max_value_lines = 100, -- Can be integer or nil.
        }
    }
end

m.skip_next_char     = function(char)
    local pos = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    pos[2] = pos[2] + 1
    local next_char = string.sub(line, pos[2], pos[2])
    if vim.v.char == char and next_char == char then
        vim.v.char = ''
        vim.api.nvim_win_set_cursor(0, pos)
    end
end

local keymaps_backup = {}
local keymaps        = {}

m.set_key_map        = function(module, keys)
    keymaps_backup[module] = vim.api.nvim_get_keymap('n')
    keymaps[module] = keys
    for k, v in pairs(keys) do
        vim.keymap.set('n', k, v.f, { noremap = true, silent = true, desc = v.desc })
    end
end

m.revert_key_map     = function(module)
    for k in pairs(keymaps[module]) do
        local cmd = 'silent! unmap ' .. k
        vim.cmd(cmd)
    end

    for _, v in pairs(keymaps_backup[module] or {}) do
        local nr = (v.noremap == 1)
        local sl = (v.slient == 1)
        local exp = (v.expr == 1)
        local mode = v.mode
        local desc = v.desc
        if v.mode == ' ' then
            mode = { 'n', 'v' }
        end

        vim.keymap.set(
            mode,
            v.lhs,
            v.rhs or v.callback,
            { noremap = nr, silent = sl, expr = exp, desc = desc }
        )
    end
    keymaps_backup = {}
end

return m
