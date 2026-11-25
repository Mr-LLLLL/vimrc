local api = vim.api
local km = vim.keymap

local function load_autocmd()
    local custom_auto_cmd = api.nvim_create_augroup("CustomAutoCmd", { clear = true })
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
        { "InsertLeave" },
        {
            pattern = { "*.*" },
            callback = function()
                vim.snippet.stop()
            end,
            group = custom_auto_cmd,
        }
    )
end

-- 外部工具（formatter、git checkout、代码生成……）改动磁盘文件后，直接载入最新内容，
-- 不再弹 "File has changed" 的确认提示。
-- 本地也有未保存修改时（v:fcs_reason == "conflict"）同样以磁盘为准，但额外给一条警告，
-- 因为这种情况下本地编辑会丢失。
-- 提到函数外保存引用，避免 luv 定时器被 Lua GC 回收
local autoread_timer

local function load_autoread()
    vim.o.autoread = true

    local autoread_grp = api.nvim_create_augroup("CustomAutoRead", { clear = true })

    -- 插入模式下不检查，避免把正在输入的内容冲掉
    -- :checktime 在 autocommand 里调用会被推迟处理，用 vim.schedule 挪回主循环立即执行
    local function checktime()
        if vim.fn.mode():find("^i") then
            return
        end
        vim.schedule(function()
            vim.cmd("silent! checktime")
        end)
    end

    api.nvim_create_autocmd(
        { "FocusGained", "BufEnter", "BufWinEnter", "WinEnter" },
        { callback = checktime, group = autoread_grp }
    )
    -- CursorHold 依赖真实的空闲状态，headless / 未聚焦时不可靠，这里用 1s 轮询兜底
    -- （:checktime 只是对已载入 buffer 逐个 stat，代价可忽略）
    autoread_timer = vim.uv.new_timer()
    autoread_timer:start(1000, 1000, vim.schedule_wrap(function()
        if vim.fn.mode():find("^i") then
            return
        end
        vim.cmd("silent! checktime")
    end))

    api.nvim_create_autocmd("FileChangedShell", {
        group = autoread_grp,
        callback = function(args)
            local reason = vim.v.fcs_reason
            if reason == "conflict" then
                vim.notify(
                    ("%s 已被外部修改，已按磁盘版本重载（本地未保存的修改已丢弃）"):format(
                        vim.fn.fnamemodify(args.file, ":t")
                    ),
                    vim.log.levels.WARN
                )
            end
            if reason == "changed" or reason == "conflict" then
                vim.v.fcs_choice = "reload"
            end
        end,
    })
end

local function load_custom_map()
    km.set({ 'i' }, "<A-d>", "<esc>lcw", { noremap = true, silent = true, desc = "delete next word" })
    km.set({ 'i' }, "<c-j>", "<Down>", { noremap = true, silent = true, desc = "jump to next line" })
    km.set({ 'i' }, "<c-k>", "<Up>", { noremap = true, silent = true, desc = "jump to prev line" })
    km.set({ 'i' }, "<c-e>", "<End>", { noremap = true, silent = true, desc = "jump to end of current line" })
    km.set({ 'i' }, "<c-a>", function()
        local line = api.nvim_get_current_line()
        api.nvim_win_set_cursor(0, { vim.fn.line("."), vim.fn.match(line, "\\S") })
    end, { noremap = true, silent = true, desc = "jump to start of current line" })
    km.set({ 'i' }, "<c-s>", "<cmd>w<cr>", { noremap = true, silent = true, desc = "save current buffer" })
    km.set({ 'i', 'c' }, "<c-d>", "<del>", { noremap = true, silent = false, desc = "delete next char" })
    km.set({ 'i', 'c' }, "<c-h>", "<left>", { noremap = true, silent = false, desc = "left char" })
    km.set({ 'i', 'c' }, "<c-l>", "<right>", { noremap = true, silent = false, desc = "right char" })
    km.set({ 'i', 'c' }, "<A-h>", "<c-Left>", { noremap = true, silent = false, desc = "left word" })
    km.set({ 'i', 'c' }, "<A-l>", "<c-Right>", { noremap = true, silent = false, desc = "right word" })

    km.set({ 'c' }, "<c-a>", "<Home>", { noremap = true, silent = false, desc = "jump to start of cmdline" })
    km.set({ 'c' }, "<A-d>", "<c-right><c-w>", { noremap = true, silent = false, desc = "delete next word" })

    km.set({ 'n' }, "<c-h>", "<c-w>h", { noremap = true, silent = true, desc = "jump to left window" })
    km.set({ 'n' }, "<c-j>", "<c-w>j", { noremap = true, silent = true, desc = "jump to right window" })
    km.set({ 'n' }, "<c-k>", "<c-w>k", { noremap = true, silent = true, desc = "jump to up window" })
    km.set({ 'n' }, "<c-l>", "<c-w>l", { noremap = true, silent = true, desc = "jump to down window" })
end

local function load_hi()
    api.nvim_set_hl(0, "SagaBorder", { link = 'CustomBorder' })
    api.nvim_set_hl(0, "SagaVirtLine", { link = 'NonText' })

    api.nvim_set_hl(0, "LspInfoBorder", { link = 'CustomBorder' })
end

local function del_km()
    vim.keymap.del('n', "grn")
    vim.keymap.del({ 'n', 'x' }, "gra")
    vim.keymap.del('n', "grr")
    vim.keymap.del('n', "gri")
    vim.keymap.del('n', "gO")
end

local function load()
    load_custom_map()
    load_autocmd()
    load_autoread()
    load_hi()
    del_km()
end

load()
