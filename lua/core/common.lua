local km           = vim.keymap

local m            = {}

m.glyphs           = {
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

m.lsp_flags        = {
    -- This is the default in Nvim 0.7+
    debounce_text_changes = 150,
}

m.lsp_capabilities = function()
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true

    return capabilities
end


local list_or_jump   = function(action, f, param)
    local tele_action = require("telescope.actions")
    local lspParam = vim.lsp.util.make_position_params(vim.fn.win_getid())
    lspParam.context = { includeDeclaration = false }
    vim.lsp.buf_request(vim.fn.bufnr(), action, lspParam, function(err, result, ctx, _)
        if err then
            vim.api.nvim_err_writeln("Error when executing " .. action .. " : " .. err.message)
            return
        end
        local flattened_results = {}
        if result then
            -- textDocument/definition can return Location or Location[]
            if not vim.tbl_islist(result) then
                flattened_results = { result }
            end

            vim.list_extend(flattened_results, result)
        end

        local offset_encoding = vim.lsp.get_client_by_id(ctx.client_id).offset_encoding

        if #flattened_results == 0 then
            return
            -- definitions will be two result in lua, i think first is pretty goods
        elseif #flattened_results == 1 or action == "textDocument/definition" then
            if type(param) == "table" then
                if param.jump_type == "vsplit" then
                    vim.cmd("vsplit")
                elseif param.jump_type == "tab" then
                    vim.cmd("tab split")
                end
            end
            vim.lsp.util.jump_to_location(flattened_results[1], offset_encoding)
            tele_action.center()
        else
            f(param)
        end
    end)
end

---@diagnostic disable-next-line: unused-local
m.lsp_on_attack      = function(client, bufnr)
    local tele_builtin = require("telescope.builtin")

    require "lsp_signature".on_attach(require("lsp_signature").setup(), bufnr)

    --     -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    --
    --     -- Mappings.
    --     -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    --     km.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    --     km.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    km.set('n', '<c-]>', function()
        list_or_jump("textDocument/definition", tele_builtin.lsp_definitions)
    end, bufopts)

    km.set('n', '<c-w>]', function()
        list_or_jump("textDocument/definition", tele_builtin.lsp_definitions, { jump_type = "vsplit" })
    end, bufopts)

    km.set('n', '<c-w><c-]>', function()
        list_or_jump("textDocument/definition", tele_builtin.lsp_definitions, { jump_type = "tab" })
    end, bufopts)

    km.set('n', '<C-LeftMouse>', function()
        local pos = vim.fn.getmousepos()
        vim.fn.cursor(pos.line, pos.column)
        list_or_jump("textDocument/definition", tele_builtin.lsp_definitions)
    end, bufopts)

    km.set('n', 'gi', function()
        list_or_jump("textDocument/implementation", tele_builtin.lsp_implementations)
    end, bufopts)

    km.set('n', 'g<LeftMouse>', function()
        local pos = vim.fn.getmousepos()
        vim.fn.cursor(pos.line, pos.column)
        list_or_jump("textDocument/implementation", tele_builtin.lsp_implementations)
    end, bufopts)

    km.set('n', 'gr', function()
        list_or_jump("textDocument/references", tele_builtin.lsp_references, { include_declaration = false })
    end, bufopts)

    km.set('n', '<C-RightMouse>', function()
        local pos = vim.fn.getmousepos()
        vim.fn.cursor(pos.line, pos.column)
        list_or_jump("textDocument/references", tele_builtin.lsp_references, { include_declaration = false })
    end, bufopts)

    km.set('n', 'gy', function()
        list_or_jump("textDocument/typeDefinition", tele_builtin.lsp_type_definitions)
    end, bufopts)

    km.set('n', 'g<RightMouse>', function()
        local pos = vim.fn.getmousepos()
        vim.fn.cursor(pos.line, pos.column)
        list_or_jump("textDocument/typeDefinition", tele_builtin.lsp_type_definitions)
    end, bufopts)

    km.set('n', '<space>so', function() tele_builtin.lsp_document_symbols() end, bufopts)
    km.set('n', '<space>sg', function() tele_builtin.lsp_dynamic_workspace_symbols() end, bufopts)
    km.set('n', '<space>a', function() tele_builtin.diagnostics({ root_dir = true }) end, bufopts)
    km.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
    --     km.set('n', '<leader>a', vim.lsp.buf.code_action, bufopts)
    --
    km.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    km.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    km.set('n', '<space>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
end

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
    keymaps_backup[module] = {}
    keymaps[module] = {}
    local setmap = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local old_keymap_list = vim.api.nvim_buf_get_keymap(bufnr, 'n')
        keymaps_backup[module][bufnr] = {}
        for _, v in pairs(old_keymap_list) do
            if keys[v.lhs] ~= nil then
                keymaps_backup[module][bufnr][v.lhs] = v
            end
        end
        keymaps[module][bufnr] = keys
        for k, v in pairs(keys) do
            vim.keymap.set('n', k, v.f, { noremap = true, silent = true, desc = v.desc, buffer = bufnr })
        end
    end
    setmap()
    local ft = vim.api.nvim_buf_get_option(0, 'filetype')

    local custom_auto_cmd = vim.api.nvim_create_augroup("DapDebugKeys", { clear = true })
    vim.api.nvim_create_autocmd(
        { "BufWinEnter" },
        {
            pattern = { "*." .. ft },
            callback = function()
                setmap()
            end,
            group = custom_auto_cmd,
        }
    )
end

m.revert_key_map     = function(module)
    for bufnr, ks in pairs(keymaps[module] or {}) do
        for k in pairs(ks) do
            vim.keymap.del('n', k, { buffer = bufnr })
        end
    end

    for _, buf_backup in pairs(keymaps_backup[module] or {}) do
        for _, v in pairs(buf_backup) do
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
    end
    keymaps_backup[module] = {}
    keymaps[module] = {}
    vim.api.nvim_create_augroup("DapDebugKeys", { clear = true })
end

return m
