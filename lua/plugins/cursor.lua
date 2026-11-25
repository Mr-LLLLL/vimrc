local g = vim.g

local function autopair_multi_line_jump()
    local npairs               = require("nvim-autopairs")
    local cond                 = require('nvim-autopairs.conds')
    local utils                = require('nvim-autopairs.utils')
    local rule                 = require('nvim-autopairs.rule')

    local multiline_close_jump = function(open, close)
        return rule(close, "")
            :with_pair(function()
                local row, col = utils.get_cursor(0)
                local line = utils.text_get_current_line(0)

                if #line ~= col then --not at EOL
                    return false
                end

                local unclosed_count = 0
                for c in line:gmatch("[\\" .. open .. "\\" .. close .. "]") do
                    if c == open then unclosed_count = unclosed_count + 1 end
                    if unclosed_count > 0 and c == close then unclosed_count = unclosed_count - 1 end
                end
                if unclosed_count > 0 then return false end

                local nextrow = row + 1

                if nextrow < vim.api.nvim_buf_line_count(0) and vim.regex("^\\s*" .. close):match_line(0, nextrow) then
                    return true
                end
                return false
            end)
            :with_move(cond.none())
            :with_cr(cond.none())
            :with_del(cond.none())
            :set_end_pair_length(0)
            :replace_endpair(function(opts)
                local row, _ = utils.get_cursor(0)
                local action = vim.regex("^" .. close):match_line(0, row + 1) and "a" or ("0f%sa"):format(opts.char)
                return ("<esc>xj%s"):format(action)
            end)
    end

    npairs.add_rules({
        multiline_close_jump('(', ')'),
        multiline_close_jump('[', ']'),
        multiline_close_jump('{', '}'),
    })
end


local function autopair_insert_space()
    local npairs = require 'nvim-autopairs'
    local rule = require 'nvim-autopairs.rule'
    local cond = require 'nvim-autopairs.conds'

    local brackets = { { '(', ')' }, { '[', ']' }, { '{', '}' } }
    npairs.add_rules {
        rule(' ', ' ')
            :with_pair(function(opts)
                local pair = opts.line:sub(opts.col - 1, opts.col)
                return vim.tbl_contains({
                    brackets[1][1] .. brackets[1][2],
                    brackets[2][1] .. brackets[2][2],
                    brackets[3][1] .. brackets[3][2]
                }, pair)
            end)
            :with_move(cond.none())
            :with_cr(cond.none())
            :with_del(function(opts)
                local col = vim.api.nvim_win_get_cursor(0)[2]
                local context = opts.line:sub(col - 1, col + 2)
                return vim.tbl_contains({
                    brackets[1][1] .. '  ' .. brackets[1][2],
                    brackets[2][1] .. '  ' .. brackets[2][2],
                    brackets[3][1] .. '  ' .. brackets[3][2]
                }, context)
            end)
    }
    for _, bracket in pairs(brackets) do
        rule('', ' ' .. bracket[2])
            :with_pair(cond.none())
            :with_move(function(opts) return opts.char == bracket[2] end)
            :with_cr(cond.none())
            :with_del(cond.none())
            :use_key(bracket[2])
    end
end

local function autopair_pairs()
    local npairs = require('nvim-autopairs')
    local Rule = require('nvim-autopairs.rule')
    local cond = require('nvim-autopairs.conds')
    npairs.add_rules({
        Rule("<", ">", { "rust" })
            :with_pair(cond.not_before_regex(" ", 1))
            :with_move(function(opts)
                if opts.char == "<" then
                    return false
                else
                    return true
                end
            end)
            :with_cr(cond.none())
    }
    )
end

-- 跨行删除后收拢括号：
--   行1: foo(
--   行2: )
-- 按一次 <BS> 期望直接得到 "foo()"，而 autopairs 自带的 <BS> 一次只 join 一行。
-- 这里包装 autopairs 的 <BS>，原生逻辑处理完后再检查是否出现「上一行以未闭合
-- 开括号结尾 + 当前行只剩闭合括号」，命中则把两行真实合并。
local function autopair_bs_join()
    local open_to_close = { ["("] = ")", ["["] = "]", ["{"] = "}" }
    local esc = require("nvim-autopairs.utils").esc

    local function lines(bufnr, first, last)
        return vim.api.nvim_buf_get_lines(bufnr, first, last, false)
    end

    local function closer_after_open(bufnr, row)
        local prev = lines(bufnr, row - 2, row - 1)[1] or ""
        local open = prev:match("(%S)%s*$")
        return open and open_to_close[open] or nil
    end

    local lhs = "<BS>"
    local handler = function()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        -- 只在行首退格、且上一行以开括号结尾时接管
        if row < 2 or col ~= 0 then
            return require("nvim-autopairs").autopairs_bs(0)
        end
        local close = closer_after_open(0, row)
        if not close then
            return require("nvim-autopairs").autopairs_bs(0)
        end
        local cur = lines(0, row - 1, row)[1] or ""
        -- 上一行 foo( / 当前行只有闭括号：直接合并，光标落在括号中间
        if vim.trim(cur) == close then
            return esc("<C-G>u<BS>")
        end
        -- 上一行 foo( / 当前行空白 / 下一行只有闭括号：一次收拢两行
        if cur:match("^%s*$") then
            local next_line = lines(0, row, row + 1)[1]
            if next_line and vim.trim(next_line) == close then
                return esc("<C-G>u<BS><C-G>u<Del>")
            end
        end
        return require("nvim-autopairs").autopairs_bs(0)
    end

    -- autopairs 在 BufEnter 等时机写入自己的 buffer-local <BS>，必须在其之后再覆盖
    vim.api.nvim_create_autocmd({ "InsertEnter", "FileType" }, {
        group = vim.api.nvim_create_augroup("CustomAutopairBs", { clear = true }),
        pattern = "*",
        callback = function(ev)
            vim.keymap.set("i", lhs, handler, {
                expr = true,
                noremap = true,
                replace_keycodes = false,
                buffer = ev.buf,
                desc = "autopairs merge bracket pair across lines",
            })
        end,
    })
end

local function autopair_move_past()
    for _, punct in pairs { ",", ";" } do
        require "nvim-autopairs".add_rules {
            require "nvim-autopairs.rule" ("", punct)
                :with_move(function(opts) return opts.char == punct end)
                :with_pair(function() return false end)
                :with_del(function() return false end)
                :with_cr(function() return false end)
                :use_key(punct)
        }
    end
end

return {
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            local npairs = require("nvim-autopairs")
            npairs.setup {
                disable_filetype = { "TelescopePrompt", "spectre_panel" },
                disable_in_macro = false,       -- disable when recording or executing a macro
                disable_in_visualblock = false, -- disable when insert after visual block mode
                disable_in_replace_mode = true,
                ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
                enable_moveright = true,
                enable_afterquote = true,         -- add bracket pairs after quote
                enable_check_bracket_line = true, --- check bracket in same line
                enable_bracket_in_quote = true,   --
                enable_abbr = false,              -- trigger abbreviation
                break_undo = true,                -- switch for basic rule break undo sequence
                check_ts = true,
                map_cr = true,
                map_bs = true,   -- map the <BS> key
                map_c_h = false, -- Map the <C-h> key to delete a pair
                map_c_w = true,  -- map <c-w> to delete a pair if possible
                fast_wrap = {
                    map = '<M-p>',
                    chars = { '{', '[', '(', '"', "'" },
                    pattern = [=[[%'%"%>%]%)%}%,]]=],
                    end_key = '$',
                    keys = 'qwertyuiopzxcvbnmasdfghjkl',
                    check_comma = true,
                    manual_position = false,
                    highlight = 'Search',
                    highlight_grey = 'Comment'
                },
            }

            autopair_multi_line_jump()
            autopair_insert_space()
            autopair_move_past()
            autopair_pairs()
            autopair_bs_join()
        end,
    },
    {
        'kylechui/nvim-surround',
        keys = {
            { "yx",  "<Plug>(nvim-surround-normal)",          mode = { "n" }, desc = "Add a surrounding pair around a motion (normal mode)" },
            { "yxx", "<Plug>(nvim-surround-normal-cur)",      mode = { "n" }, desc = "Add a surrounding pair around the current line (normal mode)" },
            { "yX",  "<Plug>(nvim-surround-normal-line)",     mode = { "n" }, desc = "Add a surrounding pair around a motion, on new lines (normal mode)" },
            { "yXX", "<Plug>(nvim-surround-normal-cur-line)", mode = { "n" }, desc = "Add a surrounding pair around the current line, on new lines (normal mode)" },
            { "dx",  "<Plug>(nvim-surround-delete)",          mode = { "n" }, desc = "Delete a surrounding pair" },
            { "cx",  "<Plug>(nvim-surround-change)",          mode = { "n" }, desc = "Change a surrounding pair" },
            { "X",   "<Plug>(nvim-surround-visual)",          mode = { "x" }, desc = "Add a surrounding pair around a visual selection" },
            { "gX",  "<Plug>(nvim-surround-visual-line)",     mode = { "x" }, desc = "Add a surrounding pair around a visual selection, on new lines" }
        },
        version = "*",
        config = function()
            g.nvim_surround_no_normal_mappings = true
            require("nvim-surround").setup({})
        end
    },
    {
        'junegunn/vim-easy-align',
        keys = {
            { "ga", "<Plug>(EasyAlign)", { noremap = true, silent = true }, mode = { "n", "x" }, desc = "EasyAlign" }
        },
    },
    {
        'mg979/vim-visual-multi',
        keys = {
            { "<leader>v", nil, mode = { "n", "x" }, desc = "VisualMutil One" },
            { "<leader>V", nil, mode = { "n", "x" }, desc = "VisualMutil All" },
            { "<C-Up>",    nil, mode = { "n" },      desc = "VisualMutil Up" },
            { "<C-Down>",  nil, mode = { "n" },      desc = "VisualMutil Down" },
        },
        init = function()
            g.VM_maps = {
                ['Find Under'] = '<leader>v',
                ['Find Subword Under'] = '<leader>v',
                ["Select All"] = '<leader>V',
                ["Visual All"] = '<leader>V',
            }
        end
    },
}
