local m              = {}

m.glyphs             = {
    modified = "",
    added = "",
    unmerged = "",
    renamed = "",
    untracked = "ﲉ",
    copied = "",
    deleted = "",
    ignored = "",
    locked = "",
    lua = "",
    debug = "",
    error = "",
    info = "",
    trace = "✎",
    warn = "",
    sign_error = "",
    sign_warn = "",
    sign_hint = "",
    sign_info = "",
}

m.get_tele_project   = function()
    require("telescope").extensions.project.project {
        display_type = 'two-segment',
        attach_mappings = function(prompt_bufnr, map)
            map('i', '<cr>', function()
                require("telescope._extensions.project.actions").change_working_directory(prompt_bufnr
                , false)
                require('telescope').extensions.frecency.frecency({ workspace = 'CWD' })
            end)
            return true
        end,
    }
end

m.skip_next_char     = function(char)
    local pos = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    pos[2] = pos[2] + 1
    local next_char = string.sub(line, pos[2], pos[2])
    if vim.v.char == char and next_char == char then
        vim.v.char = ''
        vim.api.nvim_win_set_cursor(0, pos)
    end
end

local keymaps_backup = {}
local keymaps        = {}

m.set_key_map        = function(module, keys)
    local old_keymap_list = vim.api.nvim_get_keymap('n')
    keymaps_backup[module] = {}
    for _, v in pairs(old_keymap_list) do
        if keys[v.lhs] ~= nil then
            keymaps_backup[module][v.lhs] = v
        end
    end
    keymaps[module] = keys
    for k, v in pairs(keys) do
        vim.keymap.set('n', k, v.f, { noremap = true, silent = true, desc = v.desc })
    end
end

m.revert_key_map     = function(module)
    for k in pairs(keymaps[module] or {}) do
        local cmd = 'silent! nunmap ' .. k
        vim.cmd(cmd)
    end

    for _, v in pairs(keymaps_backup[module] or {}) do
        local opt = {
            noremap = v.noremap == 1,
            silent = v.slient == 1,
            expr = v.expr == 1,
            nowait = v.nowait == 1,
            desc = v.desc,
        }
        if v.buffer ~= 0 then
            opt["buffer"] = v.buffer
        end

        vim.keymap.set(
            'n',
            v.lhs,
            v.rhs or v.callback,
            opt
        )
    end
    keymaps_backup[module] = {}
    keymaps[module] = {}
end

return m
