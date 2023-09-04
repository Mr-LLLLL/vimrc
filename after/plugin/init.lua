local api = vim.api
local km = vim.keymap

local function load_autocmd()
    local custom_auto_cmd = api.nvim_create_augroup("CustomAutoCmd", { clear = true })
    api.nvim_create_autocmd(
        { "Filetype" },
        {
            pattern = { "qf", "spectre_panel", "git", "fugitive", "fugitiveblame", "help", "guihua", "notify" },
            callback = function(_)
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
    api.nvim_create_autocmd(
        { "Filetype" },
        {
            pattern = { "lua", "python" },
            callback = function()
                local extend = require("utils.extend")
                vim.keymap.set({ 'n', 'v' }, '[{', function() extend.extend(true) end,
                    { noremap = true, silent = true, buffer = true, desc = "Extend to outer node start" })
                vim.keymap.set({ 'n', 'v' }, ']}', function() extend.extend(false) end,
                    { noremap = true, silent = true, buffer = true, desc = "Extend to outer node end" })
            end,
            group = custom_auto_cmd,
        }
    )
    api.nvim_create_autocmd(
        { "BufWinLeave" },
        {
            pattern = { "*.*" },
            command = "mkview",
            group = custom_auto_cmd,
        }
    )
    api.nvim_create_autocmd(
        { "BufWinEnter" },
        {
            pattern = { "*.*" },
            command = "silent! loadview",
            group = custom_auto_cmd,
        }
    )
    api.nvim_create_autocmd(
        { "CmdwinEnter" },
        {
            pattern = { "*" },
            callback = function()
                km.set('n', 'q', '<cmd>quit!<cr>', { noremap = true, silent = true, buffer = true })
            end,
            group = custom_auto_cmd,
        }
    )
end

local function load_custom_map()
    km.set({ 'i' }, "<A-j>", "<esc>o", { noremap = true, silent = true, desc = "insert in next line" })
    km.set({ 'i' }, "<A-k>", "<esc>O", { noremap = true, silent = true, desc = "insert in prev line" })
    km.set({ 'i' }, "<A-d>", "<esc>lcw", { noremap = true, silent = true, desc = "delete next word" })
    km.set({ 'i' }, "<c-j>", "<Down>", { noremap = true, silent = true, desc = "jump to next line" })
    km.set({ 'i' }, "<c-k>", "<Up>", { noremap = true, silent = true, desc = "jump to prev line" })
    km.set({ 'i' }, "<c-e>", "<End>", { noremap = true, silent = true, desc = "jump to end of current line" })
    km.set({ 'i' }, "<c-a>", "<esc>I", { noremap = true, silent = true, desc = "jump to start of current line" })
    km.set({ 'i' }, "<c-s>", "<cmd>w<cr>", { noremap = true, silent = true, desc = "save current buffer" })
    km.set({ 'i', 'c' }, "<c-d>", "<del>", { noremap = true, silent = false, desc = "delete next char" })
    km.set({ 'i', 'c' }, "<c-h>", "<left>", { noremap = true, silent = false, desc = "left char" })
    km.set({ 'i', 'c' }, "<c-l>", "<right>", { noremap = true, silent = false, desc = "right char" })
    km.set({ 'i', 'c' }, "<A-h>", "<c-Left>", { noremap = true, silent = false, desc = "left word" })
    km.set({ 'i', 'c' }, "<A-l>", "<c-Right>", { noremap = true, silent = false, desc = "right word" })

    km.set({ 'c' }, "<c-a>", "<Home>", { noremap = true, silent = false, desc = "jump to start of cmdline" })
    km.set({ 'c' }, "<A-d>", "<c-right><c-w>", { noremap = true, silent = false, desc = "delete next word" })

    km.set({ 'n' }, ">", "zl", { noremap = true, silent = true, desc = "scroll right" })
    km.set({ 'n' }, "<", "zh", { noremap = true, silent = true, desc = "scroll left" })
    km.set({ 'n' }, "<c-h>", "<c-w>h", { noremap = true, silent = true, desc = "jump to left window" })
    km.set({ 'n' }, "<c-j>", "<c-w>j", { noremap = true, silent = true, desc = "jump to right window" })
    km.set({ 'n' }, "<c-k>", "<c-w>k", { noremap = true, silent = true, desc = "jump to up window" })
    km.set({ 'n' }, "<c-l>", "<c-w>l", { noremap = true, silent = true, desc = "jump to down window" })
    km.set({ 'n' }, "<cr>", "i<cr><esc>", { noremap = true, silent = true, desc = "split line" })
    km.set({ 'n' }, "<m-k>", "O<esc>", { noremap = true, silent = true, desc = "insert line above current line" })
    km.set({ 'n' }, "<m-j>", "o<esc>", { noremap = true, silent = true, desc = "insert line follow current line" })

    km.set('n', "<c-t>", function()
        if vim.fn.gettagstack().curidx == 1 then
            vim.notify("tags is empty", vim.log.levels.INFO)
            return
        end
        vim.cmd("pop")
        vim.cmd("normal! zz")
    end, { noremap = true, silent = true, desc = "stack pop and centerize cursor" })
end

local function load()
    load_custom_map()
    load_autocmd()
end

load()
