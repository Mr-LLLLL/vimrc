local km             = vim.keymap
local api            = vim.api
local fn             = vim.fn

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
    left_bracket = "",
    right_bracket = "",
}

m.colors             = {
    VisualBg = '#543a48',
    CustomBorderFg = '#5c6a72',
    CustomBorderBg = '#2d353b',
    NvimTreeCursorLineBg = '#374145',
    NonTextFg = '#4f585e',
    NonTextCtermFg = 239,
}

m.lsp_flags          = {
    -- This is the default in Nvim 0.7+
    debounce_text_changes = 150,
}

m.registers          = {}

m.register           = function(func)
    table.insert(m.registers, func)
end

m.keymap_desc        = function(opts, desc)
    return vim.tbl_extend("keep", opts, { desc = desc })
end

m.lsp_capabilities   = function()
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.preselectSupport = true
    capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = false
    }

    return capabilities
end

m.lsp_attach_mapping = function(bufnr)
    --     -- Mappings.
    --     -- See `:help vim.lsp.*` for documentation on any of the below functions
    local tele_builtin = require("telescope.builtin")
    local util = require("utilities")

    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    --     km.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    --     km.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    km.set('n', '<c-]>', function()
        util.list_or_jump("textDocument/definition", tele_builtin.lsp_definitions)
    end, m.keymap_desc(bufopts, "lsp definition"))

    km.set('n', '<c-w>]', function()
        util.list_or_jump("textDocument/definition", tele_builtin.lsp_definitions, { jump_type = "vsplit" })
    end, m.keymap_desc(bufopts, "lsp definition with vsplit"))

    km.set('n', '<c-w><c-]>', function()
        util.list_or_jump("textDocument/definition", tele_builtin.lsp_definitions, { jump_type = "tab" })
    end, m.keymap_desc(bufopts, "lsp definition with tab"))

    km.set('n', '<C-LeftMouse>', function()
        local pos = fn.getmousepos()
        fn.cursor(pos.line, pos.column)
        util.list_or_jump("textDocument/definition", tele_builtin.lsp_definitions)
    end, m.keymap_desc(bufopts, "lsp definition"))

    km.set('n', 'gi', function()
        util.list_or_jump("textDocument/implementation", tele_builtin.lsp_implementations)
    end, m.keymap_desc(bufopts, "lsp implementation"))

    km.set('n', 'g<LeftMouse>', function()
        local pos = fn.getmousepos()
        fn.cursor(pos.line, pos.column)
        util.list_or_jump("textDocument/implementation", tele_builtin.lsp_implementations)
    end, m.keymap_desc(bufopts, "lsp implementation"))

    km.set('n', 'gr', function()
        util.list_or_jump("textDocument/references", tele_builtin.lsp_references, { include_declaration = false })
    end, m.keymap_desc(bufopts, "lsp references"))

    km.set('n', '<C-RightMouse>', function()
        local pos = fn.getmousepos()
        fn.cursor(pos.line, pos.column)
        util.list_or_jump("textDocument/references", tele_builtin.lsp_references, { include_declaration = false })
    end, m.keymap_desc(bufopts, "lsp references"))

    km.set('n', 'gy', function()
        util.list_or_jump("textDocument/typeDefinition", tele_builtin.lsp_type_definitions)
    end, m.keymap_desc(bufopts, "lsp typeDefinition"))

    km.set('n', 'g<RightMouse>', function()
        local pos = fn.getmousepos()
        fn.cursor(pos.line, pos.column)
        util.list_or_jump("textDocument/typeDefinition", tele_builtin.lsp_type_definitions)
    end, m.keymap_desc(bufopts, "lsp typeDefinition"))

    km.set('n', '<space>so', function() tele_builtin.lsp_document_symbols() end,
        m.keymap_desc(bufopts, "lsp buf symbols"))
    -- km.set('n', '<space>sg', function() tele_builtin.lsp_dynamic_workspace_symbols() end,
    --     m.keymap_desc(bufopts, "lsp workspace symbols"))
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

    for _, func in ipairs(m.registers) do
        func(bufopts)
    end
end

m.lsp_on_attach      = function(client, bufnr)
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

    m.lsp_attach_mapping(bufnr)

    --     -- Enable completion triggered by <c-x><c-o>
    -- api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

m.get_tele_harpoon   = function()
    local smartfile = function()
        require('telescope').extensions.smart_open.smart_open({
            cwd_only = true,
            filename_first = true,
            attach_mappings = function(prompt_bufnr, map)
                map(
                    { 'i' },
                    '<M-s>',
                    function()
                        local cwd = vim.loop.cwd()
                        require("telescope.builtin").oldfiles({ cmd = cwd })
                        vim.fn.chdir(cwd)
                    end
                )
                return true
            end,
        })
        -- require('telescope').extensions.frecency.frecency({
        --     workspace = 'CWD',
        --     attach_mappings = function(prompt_bufnr, map)
        --         map(
        --             { 'i' },
        --             '<M-s>',
        --             function()
        --                 local cwd = vim.loop.cwd()
        --                 require("telescope").extensions.file_browser.file_browser({ cwd = cwd })
        --                 vim.fn.chdir(cwd)
        --             end
        --         )
        --         return true
        --     end,
        -- })
    end

    require('telescope').extensions.harpoon.marks({
        attach_mappings = function(prompt_bufnr, map)
            local actions = require("telescope.actions")
            map(
                { 'i', 'n' },
                '<M-s>',
                function()
                    local cwd = vim.loop.cwd()
                    smartfile()
                    vim.fn.chdir(cwd)
                end
            )
            map({ "i", "n" }, "<c-p>", actions.preview_scrolling_up)
            map({ "i", "n" }, "<c-n>", actions.preview_scrolling_down)
            return true
        end,
    })
end

m.get_tele_smartfile = function()
    require('telescope').extensions.smart_open.smart_open({
        cwd_only = true,
        filename_first = true,
        show_scores = false,
        match_algorithm = "fzf",
        ignore_patterns = { "*.git/*", "*/tmp/*" },
        open_buffer_indicators = {
            previous = "👀",
            others = "🙈",
        },
        attach_mappings = function(prompt_bufnr, map)
            map(
                { 'i' },
                '<M-s>',
                function()
                    local cwd = vim.loop.cwd()
                    require("telescope.builtin").oldfiles({ cmd = cwd })
                    vim.fn.chdir(cwd)
                end
            )
            return true
        end,
    })
    -- require('telescope').extensions.frecency.frecency({
    --     workspace = 'CWD',
    --     attach_mappings = function(prompt_bufnr, map)
    --         map(
    --             { 'i' },
    --             '<M-s>',
    --             function()
    --                 local cwd = vim.loop.cwd()
    --                 require("telescope.builtin").oldfiles({ cmd = cwd })
    --                 vim.fn.chdir(cwd)
    --             end
    --         )
    --         return true
    --     end,
    -- })
end

m.get_tele_project   = function()
    local act = require("telescope._extensions.project.actions")
    require("telescope").extensions.project.project {
        display_type = 'two-segment',
        attach_mappings = function(prompt_bufnr, map)
            map({ 'i', 'n' }, '<cr>', function()
                act.change_working_directory(prompt_bufnr, false)
                m.get_tele_harpoon()
            end)
            map({ 'i', 'n' }, '<c-l>', function()
                act.change_working_directory(prompt_bufnr, false)
                m.get_tele_smartfile()
            end)
            map({ 'n' }, 'e', act.search_in_project_files)
            map({ 'n' }, 'f', act.browse_project_files)
            map({ 'n' }, 'r', function() end)
            map({ 'n' }, 'b', function() end)
            map({ 'n' }, 's', function() end)
            map({ 'n' }, 'o', function() end)

            map({ 'i' }, '<c-e>', act.search_in_project_files)
            map({ 'i' }, '<c-f>', act.browse_project_files)
            map({ 'i' }, '<c-s>', function() end)
            map({ 'i' }, '<c-r>', function() end)
            map({ 'i' }, '<c-v>', function() end)
            map({ 'i' }, '<c-b>', function() end)
            -- map({ 'i' }, '<c-o>', function() vim.cmd("stopinsert") end)
            return true
        end,
    }
end

m.keymaps_backup     = {}
m.keymaps            = {}

m.set_key_map        = function(module, keys)
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

    local ft = api.nvim_get_option_value("filetype", {})
    local custom_auto_cmd = api.nvim_create_augroup("CustomCacheKeys" .. module, { clear = true })
    api.nvim_create_autocmd(
        { "BufWinEnter" },
        {
            pattern = "*",
            callback = function(opt)
                if ft ~= api.nvim_get_option_value("filetype", { buf = opt.buf }) then
                    return
                end
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

m.revert_key_map     = function(module)
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
