local km = vim.keymap

local m = {}

local function load_sniprun()
    require('sniprun').setup({})

    km.set('n', "<leader>rr", "<cmd>SnipRun<CR>", { noremap = true, silent = true })
    km.set('v', "<leader>rr", ":SnipRun<CR>", { noremap = true, silent = true })
    km.set('n', "<leader>R", "<cmd>SnipClose<CR>", { noremap = true, silent = true })
end

local keys

local dap_stop = function()
    local has_dap, dap = pcall(require, 'dap')
    if has_dap then
        dap.disconnect()
        vim.cmd('sleep 100m') -- allow cleanup
    else
        vim.notify('dap not found')
    end
end

local dap_keys = function()
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

local init_keys = function()
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

local function load_dap()
    -- this two plug will be rewrite by go.nvim
    local load_dapui = function()
        require("dapui").setup(require("core.common").get_dapui_conf())

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
        require("nvim-dap-virtual-text").setup(require("core.common").get_dapvt_conf())
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
