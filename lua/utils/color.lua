local m = {}
local fn = vim.fn
local api = vim.api

local function pick_visual()
    local lines
    local start_row, start_col = fn.getpos("v")[2], fn.getpos("v")[3]
    local end_row, end_col = fn.getpos(".")[2], fn.getpos(".")[3]
    if end_row < start_row then
        start_row, end_row = end_row, start_row
        start_col, end_col = end_col, start_col
    elseif end_row == start_row and end_col < start_col then
        start_col, end_col = end_col, start_col
    end
    start_row = start_row - 1
    start_col = start_col - 1
    end_row = end_row - 1
    if api.nvim_get_mode().mode == 'V' then
        lines = api.nvim_buf_get_text(0, start_row, 0, end_row, -1, {})
    elseif api.nvim_get_mode().mode == 'v' then
        lines = api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})
    end
    vim.cmd("normal! " .. api.nvim_get_mode().mode)
    if lines == nil then
        return ""
    end

    local line = ""
    for i, v in ipairs(lines) do
        if i == 1 then
            line = line .. fn.escape(v, "\\")
        else
            line = line .. "\\n" .. fn.escape(v, "\\")
        end
    end


    return '\\V' .. line
end

local function pick_word(mode)
    if mode == 'v' then
        return pick_visual()
    else
        return "\\V\\<" .. fn.expand("<cword>") .. "\\>"
    end
end

m.color = function(mode)
    local word = pick_word(mode)
    if word == fn.getreg('/') then
        fn.setreg('/', '')
    else
        vim.cmd("set hls")
        fn.setreg('/', word)
    end
end

m.init_search_count = function()
    m.search_count_extmark_id = 0
    m.search_count_namespace = api.nvim_create_namespace('custom/search_count')
    m.search_count_timer = vim.loop.new_timer()
    m.search_count_timer:start(0, 5000, function()
        m.search_count_cache = ""
        vim.defer_fn(function()
                api.nvim_buf_del_extmark(0, m.search_count_namespace, m.search_count_extmark_id)
            end,
            100
        )
        m.search_count_timer:stop()
    end)
end
m.init_search_count()

m.search_count = function(word)
    if word == "" then
        return
    end
    api.nvim_buf_del_extmark(0, m.search_count_namespace, m.search_count_extmark_id)

    local cur_cnt = 0
    local total_cnt = 0
    local buf_content = fn.join(api.nvim_buf_get_lines(0, 0, -1, {}), "\n")
    local cur_pos = #fn.join(api.nvim_buf_get_lines(0, 0, fn.line('.') - 1, {}), "\n")
        + ((fn.line('.') == 1) and 0 or 1) + fn.col('.') - 1
    local lst_pos = 0
    while true do
        local mat_pos = fn.matchstrpos(buf_content, word, lst_pos, 1)
        if mat_pos[1] == "" then
            break
        end
        total_cnt = total_cnt + 1
        if cur_pos >= mat_pos[2] and cur_pos < mat_pos[3] then
            cur_cnt = total_cnt
        end
        lst_pos = mat_pos[3]
    end

    local text = ' [' .. cur_cnt .. '/' .. total_cnt .. ']'
    m.search_count_extmark_id = api.nvim_buf_set_extmark(0, m.search_count_namespace, fn.line('.') - 1, 0, {
        virt_text_pos = 'eol',
        virt_text = {
            { text, "Comment" },
        },
        hl_mode = 'combine',
    })
    m.search_count_cache = text
    m.search_count_timer:again()
end

return m
