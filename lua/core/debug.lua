local km = vim.keymap

local m = {}

local function load_sniprun()
    require('sniprun').setup({})

    km.set('n', "<leader>rr", "<cmd>SnipRun<CR>", { noremap = true, silent = true })
    km.set('v', "<leader>rr", ":SnipRun<CR>", { noremap = true, silent = true })
    km.set('n', "<leader>R", "<cmd>SnipClose<CR>", { noremap = true, silent = true })
end

local keys

local dap_stop       = function()
    local has_dap, dap = pcall(require, 'dap')
    if has_dap then
        dap.disconnect()
        vim.cmd('sleep 100m') -- allow cleanup
    else
        vim.notify('dap not found')
    end
end

local dap_keys       = function()
    local keymap_help = {}
    local width = 0
    local line = ''
    for key, val in pairs(keys) do
        -- local m = vim.fn.matchlist(val, [[\v(\p+)\.(\p+\(\p*\))]]) -- match last function e.g.float_element("repl")

        line = key .. ' -> ' .. val.desc
        table.insert(keymap_help, line)
        if #line > width then
            width = #line
        end
    end

    local ListView = require('guihua.listview')
    return ListView:new({
        loc = 'top_center',
        border = 'rounded',
        prompt = true,
        enter = true,
        rect = { height = #keymap_help, width = width },
        data = keymap_help,
    })
end

local init_keys      = function()
    keys = {
            ['R'] = { f = require('dap').run_last, desc = 'restart' },
            ['c'] = { f = require('dap').continue, desc = 'continue' },
            ['n'] = { f = require('dap').step_over, desc = 'step_over' },
            ['s'] = { f = require('dap').step_into, desc = 'step_into' },
            ['o'] = { f = require('dap').step_out, desc = 'step_out' },
            ['S'] = { f = dap_stop, desc = 'stop debug session' },
            ['u'] = { f = require('dap').up, desc = 'up' },
            ['d'] = { f = require('dap').down, desc = 'down' },
            ['C'] = { f = require('dap').run_to_cursor, desc = 'run_to_cursor' },
            ['b'] = { f = require('dap').toggle_breakpoint, desc = 'toggle_breakpoint' },
            ['B'] = { f = require('dap').clear_breakpoints, desc = 'clear_breakpoints' },
            ['P'] = { f = require('dap').pause, desc = 'pause' },
            ['p'] = { f = require('dapui').eval, m = { 'n' }, desc = 'eval' },
            ['K'] = { f = require('dapui').float_element, desc = 'float_element' },
            ['g?'] = { f = dap_keys, desc = "dap_keys" },
    }
end

local get_dapvt_conf = function()
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

local get_dapui_conf = function()
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
            --         -- "stacks",
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


local function load_dap()
    -- this two plug will be rewrite by go.nvim
    local load_dapui = function()
        require("dapui").setup(get_dapui_conf())

        local dap, dapui = require("dap"), require("dapui")
        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open({})
            require("core.common").set_key_map("dap", keys)
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close({})
            require("core.common").revert_key_map("dap")
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close({})
            require("core.common").revert_key_map("dap")
        end
    end

    local load_daptvt = function()
        require("nvim-dap-virtual-text").setup(get_dapvt_conf())
    end

    load_dapui()
    load_daptvt()
end

m.setup = function()
    init_keys()
    load_dap()
    load_sniprun()
end

return m
