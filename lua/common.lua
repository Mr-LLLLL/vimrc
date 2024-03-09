local km           = vim.keymap
local api          = vim.api
local fn           = vim.fn

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
    locked = "",
    lua = "",
    debug = "",
    error = "",
    info = "",
    trace = "✎",
    warn = "",
    sign_error = "",
    sign_warn = "",
    sign_hint = "",
    sign_info = "",
}

m.colors           = {
    CustomBorderFg = '#5c6a72',
    CustomBorderBg = '#2d353b',
    NvimTreeCursorLineBg = '#374145',
    NonTextFg = '#4f585e',
    NonTextCtermFg = 239,
}

m.weeks            = {
    ["0"] = "Sun",
    ['1'] = "Mon",
    ["2"] = "Tue",
    ["3"] = "Wed",
    ["4"] = "Thu",
    ["5"] = "Fri",
    ["6"] = "Sat",
}

m.treesiter_symbol = {
    File = { ' ', 'Tag' },
    Module = { ' ', 'Exception' },
    Namespace = { ' ', 'Include' },
    Package = { ' ', 'Label' },
    Class = { ' ', 'Include' },
    Method = { ' ', 'Function' },
    Property = { ' ', '@property' },
    Field = { ' ', '@field' },
    Constructor = { ' ', '@constructor' },
    Enum = { ' ', '@number' },
    Interface = { ' ', 'Type' },
    Function = { '󰡱 ', 'Function' },
    Variable = { ' ', '@variable' },
    Constant = { ' ', 'Constant' },
    String = { '󰅳 ', 'String' },
    Number = { '󰎠 ', 'Number' },
    Boolean = { ' ', 'Boolean' },
    Array = { '󰅨 ', 'Type' },
    Object = { ' ', 'Type' },
    Key = { ' ', 'Constant' },
    Null = { '󰟢 ', 'Constant' },
    EnumMember = { ' ', 'Number' },
    Struct = { ' ', 'Type' },
    Event = { ' ', 'Constant' },
    Operator = { ' ', 'Operator' },
    TypeParameter = { ' ', 'Type' },
    -- ccls
    TypeAlias = { ' ', 'Type' },
    Parameter = { ' ', '@parameter' },
    StaticMethod = { ' ', 'Function' },
    Macro = { ' ', 'Macro' },
    -- for completio sb microsoft!!!
    Text = { '󰭷 ', 'String' },
    Snippet = { ' ', '@variable' },
    Folder = { ' ', 'Title' },
    Unit = { '󰊱 ', 'Number' },
    Value = { ' ', '@variable' },
}

m.lsp_flags        = {
    -- This is the default in Nvim 0.7+
    debounce_text_changes = 150,
}

m.keymap_desc      = function(opts, desc)
    return vim.tbl_extend("keep", opts, { desc = desc })
end

m.lsp_capabilities = function()
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.preselectSupport = true
    capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = false
    }

    return capabilities
end


m.list_or_jump     = function(action, f, param)
    local tele_action = require("telescope.actions")
    local lspParam = vim.lsp.util.make_position_params(fn.win_getid())
    lspParam.context = { includeDeclaration = false }
    vim.lsp.buf_request(api.nvim_get_current_buf(), action, lspParam, function(err, result, ctx, _)
        if err then
            api.nvim_err_writeln("Error when executing " .. action .. " : " .. err.message)
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
m.lsp_on_attack    = function(client, bufnr)
    vim.lsp.inlay_hint.enable(bufnr)

    local tele_builtin = require("telescope.builtin")

    --     -- Enable completion triggered by <c-x><c-o>
    api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    --
    --     -- Mappings.
    --     -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    --     km.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    --     km.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    km.set('n', '<c-]>', function()
        m.list_or_jump("textDocument/definition", tele_builtin.lsp_definitions)
    end, m.keymap_desc(bufopts, "lsp definition"))

    km.set('n', '<c-w>]', function()
        m.list_or_jump("textDocument/definition", tele_builtin.lsp_definitions, { jump_type = "vsplit" })
    end, m.keymap_desc(bufopts, "lsp definition with vsplit"))

    km.set('n', '<c-w><c-]>', function()
        m.list_or_jump("textDocument/definition", tele_builtin.lsp_definitions, { jump_type = "tab" })
    end, m.keymap_desc(bufopts, "lsp definition with tab"))

    km.set('n', '<C-LeftMouse>', function()
        local pos = fn.getmousepos()
        fn.cursor(pos.line, pos.column)
        m.list_or_jump("textDocument/definition", tele_builtin.lsp_definitions)
    end, m.keymap_desc(bufopts, "lsp definition"))

    km.set('n', 'gi', function()
        m.list_or_jump("textDocument/implementation", tele_builtin.lsp_implementations)
    end, m.keymap_desc(bufopts, "lsp implementation"))

    km.set('n', 'g<LeftMouse>', function()
        local pos = fn.getmousepos()
        fn.cursor(pos.line, pos.column)
        m.list_or_jump("textDocument/implementation", tele_builtin.lsp_implementations)
    end, m.keymap_desc(bufopts, "lsp implementation"))

    km.set('n', 'gr', function()
        m.list_or_jump("textDocument/references", tele_builtin.lsp_references, { include_declaration = false })
    end, m.keymap_desc(bufopts, "lsp references"))

    km.set('n', '<C-RightMouse>', function()
        local pos = fn.getmousepos()
        fn.cursor(pos.line, pos.column)
        m.list_or_jump("textDocument/references", tele_builtin.lsp_references, { include_declaration = false })
    end, m.keymap_desc(bufopts, "lsp references"))

    km.set('n', 'gy', function()
        m.list_or_jump("textDocument/typeDefinition", tele_builtin.lsp_type_definitions)
    end, m.keymap_desc(bufopts, "lsp typeDefinition"))

    km.set('n', 'g<RightMouse>', function()
        local pos = fn.getmousepos()
        fn.cursor(pos.line, pos.column)
        m.list_or_jump("textDocument/typeDefinition", tele_builtin.lsp_type_definitions)
    end, m.keymap_desc(bufopts, "lsp typeDefinition"))

    km.set('n', '<space>so', function() tele_builtin.lsp_document_symbols() end,
        m.keymap_desc(bufopts, "lsp buf symbols"))
    km.set('n', '<space>sg', function() tele_builtin.lsp_dynamic_workspace_symbols() end,
        m.keymap_desc(bufopts, "lsp workspace symbols"))
    km.set('n', '<space>a', function() tele_builtin.diagnostics({ root_dir = true }) end,
        m.keymap_desc(bufopts, "lsp diagnostics"))
    km.set('n', '<leader>rn', vim.lsp.buf.rename, m.keymap_desc(bufopts, "lsp rename"))
    --     km.set('n', '<leader>a', vim.lsp.buf.code_action, bufopts)
    --
    km.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, m.keymap_desc(bufopts, "add lsp workspace"))
    km.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, m.keymap_desc(bufopts, "remove lsp workspace"))
    km.set('n', '<space>wl', function()
        vim.print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, m.keymap_desc(bufopts, "show lsp workspaces"))
end

m.get_tele_project = function()
    local act = require("telescope._extensions.project.actions")
    require("telescope").extensions.project.project {
        display_type = 'two-segment',
        attach_mappings = function(prompt_bufnr, map)
            map({ 'i', 'n' }, '<cr>', function()
                act.change_working_directory(prompt_bufnr
                , false)
                require('telescope').extensions.frecency.frecency({ workspace = 'CWD' })
            end)
            map({ 'n' }, 'e', act.search_in_project_files)
            map({ 'n' }, 'f', act.browse_project_files)
            map({ 'n' }, 'r', act.recent_project_files)
            map({ 'n' }, 'b', function() end)
            map({ 'n' }, 's', function() end)
            map({ 'n' }, 'o', function() end)

            map({ 'i' }, '<c-e>', act.search_in_project_files)
            map({ 'i' }, '<c-f>', act.browse_project_files)
            map({ 'i' }, '<c-s>', function() end)
            map({ 'i' }, '<c-v>', function() end)
            map({ 'i' }, '<c-b>', function() end)
            map({ 'i' }, '<c-o>', function() vim.cmd("stopinsert") end)
            return true
        end,
    }
end

m.keymaps_backup   = {}
m.keymaps          = {}

m.set_key_map      = function(module, keys)
    if not module or module == "" or not keys or m.keymaps[module] then
        return
    end

    if m.keymaps[module] then
        return
    end

    m.keymaps_backup[module] = {}
    m.keymaps[module] = {}
    local setmap = function()
        local bufnr = api.nvim_get_current_buf()
        if m.keymaps[module][bufnr] then
            return
        end

        local old_keymap_list = api.nvim_buf_get_keymap(bufnr, 'n')
        for _, v in pairs(old_keymap_list) do
            if keys[v.lhs] then
                table.insert(m.keymaps_backup[module], v)
            end
        end
        m.keymaps[module][bufnr] = keys
        for k, v in pairs(keys) do
            vim.keymap.set('n', k, v.f, { noremap = true, silent = true, desc = v.desc, buffer = bufnr })
        end
    end
    setmap()

    local ft = api.nvim_buf_get_option(0, 'filetype')
    local custom_auto_cmd = api.nvim_create_augroup("CustomCacheKeys" .. module, { clear = true })
    api.nvim_create_autocmd(
        { "BufWinEnter" },
        {
            pattern = { "*." .. ft },
            callback = function()
                setmap()
            end,
            group = custom_auto_cmd,
        }
    )

    api.nvim_create_user_command("RevertKeyMap",
        function(opts)
            m.revert_key_map(opts.args)
        end,
        {
            nargs = "*",
            complete = function()
                local cmd = {}
                for k in pairs(m.keymaps) do
                    table.insert(cmd, k)
                end
                return cmd
            end,
        })
end

m.revert_key_map   = function(module)
    if not module or module == "" or not m.keymaps[module] then
        return
    end

    for bufnr, ks in pairs(m.keymaps[module] or {}) do
        for k in pairs(ks) do
            vim.keymap.del('n', k, { buffer = bufnr })
        end
    end

    for _, v in pairs(m.keymaps_backup[module] or {}) do
        local opt = {
            noremap = v.noremap == 1,
            silent = v.slient == 1,
            expr = v.expr == 1,
            nowait = v.nowait == 1,
            desc = v.desc,
            script = v.script == 1,
            buffer = v.buffer,
        }

        vim.keymap.set(
            'n',
            v.lhs,
            v.rhs or v.callback,
            opt
        )
    end

    m.keymaps_backup[module] = nil
    m.keymaps[module] = nil
    api.nvim_create_augroup("CustomCacheKeys" .. module, { clear = true })
    api.nvim_del_user_command("RevertKeyMap")

    if #m.keymaps ~= 0 then
        api.nvim_create_user_command("RevertKeyMap",
            function(opts)
                m.revert_key_map(opts.args)
            end,
            {
                nargs = "*",
                complete = function()
                    local cmd = {}
                    for k in pairs(m.keymaps) do
                        table.insert(cmd, k)
                    end
                    return cmd
                end,
            })
    end
end

return m
