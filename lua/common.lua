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

m.get_tele_frecency  = function()
    require('telescope').extensions.frecency.frecency({
        workspace = 'CWD',
        attach_mappings = function(prompt_bufnr, map)
            map(
                { 'i' },
                '<M-s>',
                function() require("telescope.builtin").oldfiles() end
            )
            return true
        end,
    })
end

local function filter_empty_string(list)
    local next = {}
    for idx = 1, #list do
        if list[idx].value ~= "" then
            table.insert(next, list[idx])
        end
    end

    return next
end

local generate_new_finder = function()
    local finders = require("telescope.finders")
    local harpoon = require("harpoon")
    local entry_display = require("telescope.pickers.entry_display")
    local utils = require "telescope.utils"
    local strings = require "plenary.strings"
    return finders.new_table({
        results = filter_empty_string(harpoon:list().items),
        entry_maker = function(entry)
            local line = entry.value
                .. ":"
                .. entry.context.row
                .. ":"
                .. entry.context.col

            local display_array = {}
            local widths = {}

            local icon, icon_hl = utils.get_devicons(entry.value)
            icon = icon ~= "" and icon or " "
            table.insert(display_array, { icon, icon_hl })
            table.insert(widths, { width = strings.strdisplaywidth(icon) })

            local path_display, path_style = utils.transform_path({}, line)
            if path_style and type(path_style) == "table" then
                local filename = path_display:sub(1, path_style[1][1][1])
                table.insert(display_array, filename)
                table.insert(widths, { width = #filename })

                local hl = path_style[1][2]
                local parent_path = path_display:sub(path_style[1][1][1] + 2, path_style[1][1][2])
                table.insert(display_array, { parent_path, hl })
                table.insert(widths, { width = #parent_path })
            else
                table.insert(widths, { width = #path_display })
                table.insert(display_array, path_display)
            end

            local displayer = entry_display.create {
                separator = " ",
                items = widths,
            }
            local make_display = function()
                return displayer(display_array)
            end
            return {
                value = entry,
                ordinal = line,
                display = make_display,
                lnum = entry.row,
                col = entry.col,
                filename = entry.value,
            }
        end,
    })
end

local delete_harpoon_mark = function(prompt_bufnr)
    local action_state = require("telescope.actions.state")
    local harpoon = require("harpoon")
    local action_utils = require("telescope.actions.utils")

    local selection = action_state.get_selected_entry()
    harpoon:list():remove(selection.value)

    local function get_selections()
        local results = {}
        action_utils.map_selections(prompt_bufnr, function(entry)
            table.insert(results, entry)
        end)
        return results
    end

    local selections = get_selections()
    for _, current_selection in ipairs(selections) do
        harpoon:list():remove(current_selection.value)
    end

    local current_picker = action_state.get_current_picker(prompt_bufnr)
    current_picker:refresh(generate_new_finder(), { reset_prompt = true })
end

m.get_tele_harpoon        = function()
    require('telescope').extensions.harpoon.marks({
        finder = generate_new_finder(),
        attach_mappings = function(prompt_bufnr, map)
            local actions = require("telescope.actions")
            map(
                { 'i' },
                '<M-s>',
                function() require("telescope").extensions.file_browser.file_browser() end
            )
            map({ "i", "n" }, "<c-d>", delete_harpoon_mark)
            map({ "i", "n" }, "<c-p>", actions.preview_scrolling_up)
            map({ "i", "n" }, "<c-n>", actions.preview_scrolling_down)
            return true
        end,
    })
end

m.get_tele_project        = function()
    local act = require("telescope._extensions.project.actions")
    require("telescope").extensions.project.project {
        display_type = 'two-segment',
        attach_mappings = function(prompt_bufnr, map)
            map({ 'i', 'n' }, '<cr>', function()
                act.change_working_directory(prompt_bufnr, false)
                m.get_tele_harpoon()
            end)
            map({ 'i', 'n' }, '<c-r>', function()
                act.change_working_directory(prompt_bufnr, false)
                require('telescope').extensions.frecency.frecency({ workspace = 'CWD' })
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
            map({ 'i' }, '<c-v>', function() end)
            map({ 'i' }, '<c-b>', function() end)
            -- map({ 'i' }, '<c-o>', function() vim.cmd("stopinsert") end)
            return true
        end,
    }
end

m.keymaps_backup          = {}
m.keymaps                 = {}

m.set_key_map             = function(module, keys)
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

m.revert_key_map          = function(module)
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
