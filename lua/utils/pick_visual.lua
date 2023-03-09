local m = {}

local function pick_visual()
    local _, start_row, start_col = unpack(vim.fn.getpos("'<"))
    local _, end_row, end_col = unpack(vim.fn.getpos("'>"))

    if start_row ~= end_row then
        return ""
    end

    return '\\V' .. vim.fn.escape(string.sub(vim.fn.getline("."), start_col, end_col), "\\")
end

function pick_word(mode)
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
