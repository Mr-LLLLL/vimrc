local m = {}

local function pick_visual()
    local lines
    local start_row, start_col = vim.fn.getpos("v")[2], vim.fn.getpos("v")[3]
    local end_row, end_col = vim.fn.getpos(".")[2], vim.fn.getpos(".")[3]
    if end_row < start_row then
        start_row, end_row = end_row, start_row
        start_col, end_col = end_col, start_col
    elseif end_row == start_row and end_col < start_col then
        start_col, end_col = end_col, start_col
    end
    start_row = start_row - 1
    start_col = start_col - 1
    end_row = end_row - 1
    if vim.api.nvim_get_mode().mode == 'V' then
        lines = vim.api.nvim_buf_get_text(0, start_row, 0, end_row, -1, {})
    elseif vim.api.nvim_get_mode().mode == 'v' then
        lines = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})
    end
    vim.cmd("normal! " .. vim.api.nvim_get_mode().mode)
    if lines == nil then
        return ""
    end

    local line = ""
    for i, v in ipairs(lines) do
        if i == 1 then
            line = line .. vim.fn.escape(v, "\\")
        else
            line = line .. "\\n" .. vim.fn.escape(v, "\\")
        end
    end


    return '\\V' .. line
end

local function pick_word(mode)
    if mode == 'v' then
        return pick_visual()
    else
        return "\\<" .. vim.fn.expand("<cword>") .. "\\>"
    end
end

m.colorn = function()
    local word = pick_word()
    vim.cmd("set hls")
    vim.fn.setreg('/', word)
end

m.colorv = function()
    local word = pick_word('v')
    vim.cmd("set hls")
    vim.fn.setreg('/', word)
end

return m
