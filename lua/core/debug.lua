local km = vim.keymap
local api = vim.api

local m = {}

local function load_dap_map()
    api.nvim_create_user_command('DapClearBreakpoints', require('dap').clear_breakpoints, { nargs = 0 })
    api.nvim_create_user_command('DapRestart', require('dap').run_last, { nargs = 0 })
    km.set("n", "<F5>", require('dap').continue, { noremap = true, silent = true })
    km.set("n", "<F6>", require('dap').run_to_cursor, { noremap = true, silent = true })
    km.set("n", "<F7>", require('dap').step_into, { noremap = true, silent = true })
    km.set("n", "<F8>", require('dap').step_out, { noremap = true, silent = true })
    km.set("n", "<F9>", require('dap').toggle_breakpoint, { noremap = true, silent = true })
    km.set("n", "<F10>", require('dap').step_over, { noremap = true, silent = true })
end

local function load_dap()
    -- this two plug will be rewrite by go.nvim
    local load_dapui = function()
        require("dapui").setup(require("core.common").get_dapui_conf())

        local dap, dapui = require("dap"), require("dapui")
        dap.listeners.after.event_initialized["dapui_config"] = function()
            require("core.common").set_key_map("dap_help", "n", "g?", require("go.dap").debug_keys)
            dapui.open({})
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            require("core.common").revert_key_map("dap_help", "n", "g?")
            dapui.close({})
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
            require("core.common").revert_key_map("dap_help", "n", "g?")
            dapui.close({})
        end
    end

    local load_daptvt = function()
        require("nvim-dap-virtual-text").setup(require("core.common").get_dapvt_conf())
    end

    load_dapui()
    load_daptvt()
    load_dap_map()
end

local function load_sniprun()
    require('sniprun').setup({})

    km.set('n', "<leader>rr", "<cmd>SnipRun<CR>", { noremap = true, silent = true })
    km.set('v', "<leader>rr", ":SnipRun<CR>", { noremap = true, silent = true })
    km.set('n', "<leader>R", "<cmd>SnipClose<CR>", { noremap = true, silent = true })
end

m.setup = function()
    load_dap()
    load_sniprun()
end

return m
