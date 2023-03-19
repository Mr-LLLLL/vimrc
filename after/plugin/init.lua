local api = vim.api
local km = vim.keymap

local function del_user_cmd()
    api.nvim_del_user_command('DapContinue')
    api.nvim_del_user_command('DapToggleBreakpoint')
    api.nvim_del_user_command('DapToggleRepl')
    api.nvim_del_user_command('DapStepOver')
    api.nvim_del_user_command('DapStepInto')
    api.nvim_del_user_command('DapStepOut')
    api.nvim_del_user_command('DapLoadLaunchJSON')
    api.nvim_del_user_command('DapRestartFrame')
end

local function load_autocmd()
    local custom_auto_cmd = api.nvim_create_augroup("CustomAutoCmd", { clear = true })
    api.nvim_create_autocmd(
        { "InsertCharPre" },
        {
            pattern = { "*" },
            callback = function()
                require("core.common").skip_next_char(",")
            end,
            group = custom_auto_cmd,
        }
    )
    api.nvim_create_autocmd(
        { "Filetype" },
        {
            pattern = { "qf", "spectre_panel", "git", "fugitive", "fugitiveblame", "help", "guihua" },
            callback = function()
                km.set('n', 'q', '<cmd>quit!<cr>', { noremap = true, silent = true, buffer = true })
            end,
            group = custom_auto_cmd,
        }
    )
    api.nvim_create_autocmd(
        { "Filetype" },
        {
            pattern = { "qf" },
            callback = function()
                km.set(
                    'n',
                    '<cr>',
                    function()
                        local pos = api.nvim_win_get_cursor(0)
                        vim.cmd("cr " .. pos[1])
                    end,
                    { noremap = true, silent = true, buffer = true }
                )
            end,
            group = custom_auto_cmd,
        }
    )
end

local function load_custom_map()
    km.set({ 'i' }, "<A-j>", "<esc>o", { noremap = true, silent = true })
    km.set({ 'i' }, "<A-k>", "<esc>O", { noremap = true, silent = true })
    km.set({ 'i' }, "<A-d>", "<esc>lcw", { noremap = true, silent = true })
    km.set({ 'i' }, "<c-j>", "<Down>", { noremap = true, silent = true })
    km.set({ 'i' }, "<c-k>", "<Up>", { noremap = true, silent = true })
    km.set({ 'i' }, "<c-e>", "<End>", { noremap = true, silent = true })
    km.set({ 'i' }, "<c-a>", "<esc>I", { noremap = true, silent = true })
    km.set({ 'i' }, "<c-s>", "<cmd>w<cr>", { noremap = true, silent = true })
    km.set({ 'i', 'c' }, "<c-d>", "<del>", { noremap = true, silent = false })
    km.set({ 'i', 'c' }, "<c-h>", "<left>", { noremap = true, silent = false })
    km.set({ 'i', 'c' }, "<c-l>", "<right>", { noremap = true, silent = false })
    km.set({ 'i', 'c' }, "<A-h>", "<c-Left>", { noremap = true, silent = false })
    km.set({ 'i', 'c' }, "<A-l>", "<c-Right>", { noremap = true, silent = false })

    km.set({ 'c' }, "<c-a>", "<Home>", { noremap = true, silent = false })
    km.set({ 'c' }, "<A-d>", "<c-right><c-w>", { noremap = true, silent = false })

    km.set({ 'n' }, ">", "zl", { noremap = true, silent = true })
    km.set({ 'n' }, "<", "zh", { noremap = true, silent = true })
    km.set({ 'n' }, "<c-h>", "<c-w>h", { noremap = true, silent = true })
    km.set({ 'n' }, "<c-j>", "<c-w>j", { noremap = true, silent = true })
    km.set({ 'n' }, "<c-k>", "<c-w>k", { noremap = true, silent = true })
    km.set({ 'n' }, "<c-l>", "<c-w>l", { noremap = true, silent = true })
    km.set({ 'n' }, "<cr>", "i<cr><esc>", { noremap = true, silent = true })
    km.set({ 'n' }, "<m-k>", "O<esc>", { noremap = true, silent = true })
    km.set({ 'n' }, "<m-j>", "o<esc>", { noremap = true, silent = true })

    km.set('n', "<c-t>", function()
        if vim.fn.gettagstack().curidx == 1 then
            vim.notify("tags is empty")
            return
        end
        vim.cmd(":pop")
        vim.cmd(":normal! zz")
    end, { noremap = true, silent = true })
    km.set('n', "<leader>m", require("utils.pick_visual").colorn, { noremap = true, silent = true })
    km.set('x', "<leader>m", ":<c-u>lua require('utils.pick_visual').colorv()<cr>", { noremap = true, silent = true })
    km.set('n', "<leader>M", "<cmd>noh<CR>", { noremap = true, silent = true })

    local custom_extend = vim.api.nvim_create_augroup("CustomExtend", { clear = true })
    api.nvim_create_autocmd(
        { "Filetype" },
        {
            pattern = "lua",
            callback = function()
                local extend = require("utils.extend")
                vim.keymap.set({ 'n', 'v' }, '[{', function() extend.extend(true) end,
                    { noremap = true, silent = true, buffer = true })
                vim.keymap.set({ 'n', 'v' }, ']}', function() extend.extend(false) end,
                    { noremap = true, silent = true, buffer = true })
            end,
            group = custom_extend,
        }
    )
end

local function load()
    del_user_cmd()
    load_custom_map()
    load_autocmd()
end

load()
