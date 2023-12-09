local api = vim.api
local g = vim.g
local o = vim.o
local fn = vim.fn

return {
    {
        'nvim-lualine/lualine.nvim',
        event = "VeryLazy",
        config = function()
            local glyphs = require("common").glyphs
            local lsp_info = {
                ["textDocument/references"] = "",
                ["textDocument/implementation"] = "",
                ["textDocument/hover"] = "",
            }

            local custom_auto_cmd = api.nvim_create_augroup("LualineLsp", { clear = true })
            api.nvim_create_autocmd(
                { "CursorHold" },
                {

                    pattern = { "*.*" },
                    callback = function()
                        local lspParam = vim.lsp.util.make_position_params(fn.win_getid())
                        lspParam.context = { includeDeclaration = false }
                        for k in pairs(lsp_info) do
                            lsp_info[k] = ""
                            local clients = vim.lsp.get_active_clients({ bufnr = api.nvim_get_current_buf() })
                            if not vim.tbl_islist(clients) or #clients == 0 then
                                goto continue
                            end

                            for _, client in ipairs(clients) do
                                if not client.supports_method(k) then
                                    goto continue
                                end
                            end

                            vim.lsp.buf_request(api.nvim_get_current_buf(), k, lspParam, function(err, result, _, _)
                                if err then
                                    return
                                end

                                if not result then
                                    return
                                end

                                if k == "textDocument/hover" then
                                    if not result.contents then
                                        return
                                    end

                                    local value
                                    if type(result.contents) == 'string' then   -- MarkedString
                                        value = result.contents
                                    elseif result.contents.language then        -- MarkedString
                                        value = result.contents.value
                                    elseif vim.tbl_islist(result.contents) then -- MarkedString[]
                                        if vim.tbl_isempty(result.contents) then
                                            return
                                        end
                                        local values = {}
                                        for _, ms in ipairs(result.contents) do
                                            table.insert(values, type(ms) == 'string' and ms or ms.value)
                                        end
                                        value = table.concat(values, '\n')
                                    elseif result.contents.kind then -- MarkupContent
                                        value = result.contents.value
                                    end

                                    if not value or #value == 0 then
                                        return
                                    end
                                    local content = vim.split(value, '\n', { trimempty = true })
                                    if clients[1].name == "rust_analyzer" then
                                        if #content > 2 then
                                            lsp_info[k] = content[2]
                                            if #content > 6 and content[5] == "```rust" then
                                                lsp_info[k] = lsp_info[k] .. "  "
                                            else
                                                return
                                            end
                                            for i = 6, #content, 1 do
                                                if content[i] == "```" then
                                                    break
                                                end
                                                lsp_info[k] = lsp_info[k] ..
                                                    string.match(vim.trim(content[i]), ".*[^,]$*") .. " "
                                            end
                                        end
                                    else
                                        if #content > 1 then
                                            lsp_info[k] = string.match(content[2], ".*[^{ ]$*")
                                        end
                                    end
                                elseif vim.tbl_islist(result) then
                                    lsp_info[k] = tostring(#result)
                                    return
                                end
                            end)
                            ::continue::
                        end
                    end,
                    group = custom_auto_cmd,
                }
            )
            require('lualine').setup({
                options = {
                    icons_enabled = true,
                    theme = 'auto',
                    component_separators = '|',
                    section_separators = { left = '', right = '' },
                    disabled_filetypes = {
                        statusline = {},
                        winbar = {},
                    },
                    ignore_focus = {},
                    always_divide_middle = true,
                    globalstatus = true,
                    refresh = {
                        statusline = 1000,
                        tabline = 1000,
                        winbar = 1000,
                    }
                },
                sections = {
                    lualine_a = {
                        { 'mode', separator = { left = '' }, right_padding = 2 },
                    },
                    lualine_b = {
                        'branch',
                        {
                            'diff',
                            symbols = {
                                added = glyphs["added"] .. ' ',
                                modified = glyphs["modified"] .. ' ',
                                removed = glyphs["deleted"] .. ' '
                            }
                        },
                        {
                            'diagnostics',
                            symbols = {
                                error = glyphs["sign_error"],
                                warn = glyphs["sign_warn"],
                                info = glyphs["sign_info"],
                                hint = glyphs["sign_hint"],
                            },
                        },
                        { 'fileformat', separator = { right = '' } }
                    },
                    lualine_c = {
                        {
                            'filename',
                            file_status = true,    -- Displays file status (readonly status, modified status)
                            newfile_status = true, -- Display new file status (new file means no write after created)
                            path = 1,              -- 0: Just the filename
                            -- 1: Relative path
                            -- 2: Absolute path
                            -- 3: Absolute path, with tilde as the home directory

                            shorting_target = 40, -- Shortens path to leave 40 spaces in the window
                            -- for other components. (terrible name, any suggestions?)
                            symbols = {
                                modified = glyphs["modified"], -- Text to show when the file is modified.
                                readonly = glyphs["locked"],   -- Text to show when the file is non-modifiable or readonly.
                                unnamed = '[No Name]',         -- Text to show for unnamed buffers.
                                newfile = '[New]',             -- Text to show for newly created file before first write
                            }
                        },
                        {
                            function()
                                return "󰁞 " .. lsp_info["textDocument/references"]
                            end,
                            cond = function()
                                return lsp_info["textDocument/references"] ~= ""
                            end,
                            on_click = function()
                                local tele_builtin = require("telescope.builtin")
                                require("common").list_or_jump("textDocument/references", tele_builtin.lsp_references,
                                    { include_declaration = false })
                            end
                        },
                        {
                            function()
                                return " " .. lsp_info["textDocument/implementation"]
                            end,
                            cond = function()
                                return lsp_info["textDocument/implementation"] ~= ""
                            end,
                            on_click = function()
                                local tele_builtin = require("telescope.builtin")
                                require("common").list_or_jump("textDocument/implementation",
                                    tele_builtin.lsp_implementations)
                            end
                        },
                        {
                            function()
                                return " " .. lsp_info["textDocument/hover"]
                            end,
                            cond = function()
                                return lsp_info["textDocument/hover"] ~= ""
                            end,
                            on_click = function()
                                require('lspsaga.hover'):render_hover_doc()
                            end
                        },
                    },
                    lualine_x = {
                        -- {
                        --     require("noice").api.status.message.get_hl,
                        --     cond = require("noice").api.status.message.has,
                        -- },
                        {
                            require("noice").api.status.command.get,
                            cond = require("noice").api.status.command.has,
                            color = { fg = "#ff9e64" },
                        },
                        {
                            require("noice").api.status.mode.get,
                            cond = function()
                                local msg = require("noice").api.status.mode.get()
                                if msg == nil then
                                    return false
                                end
                                if string.match(msg, "recording") == "recording" then
                                    return true
                                else
                                    return false
                                end
                            end,
                            color = { fg = "#ff9e64" },
                        },
                        'encoding',
                    },
                    lualine_y = {
                        { 'filetype', separator = { left = '' }, right_padding = 2 },
                    },
                    lualine_z = {
                        { '%3l/%L:%2v', separator = { right = '' } },
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = {},
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {}
                },
                tabline = {
                    lualine_a = { {
                        "tabs",
                        max_length = o.columns * 2 / 3,
                        mode = 2,
                        fmt = function(name, context)
                            local emptyName = '[No Name]'
                            local buflist = fn.tabpagebuflist(context.tabnr)
                            local winnr = fn.tabpagewinnr(context.tabnr)
                            local bufnr = buflist[winnr]
                            local winid = fn.win_getid(winnr, context.tabnr)
                            local bufferPath = fn.bufname(bufnr)
                            local project_icon = fn.tabpagenr() == context.tabnr and " " or " "
                            local file_icon = fn.tabpagenr() == context.tabnr and " " or " "
                            if bufferPath == "" then
                                return emptyName .. file_icon
                            end
                            if api.nvim_buf_get_option(bufnr, 'buftype') == "nofile" then
                                return bufferPath .. file_icon
                            end

                            if bufferPath:sub(1, 1) ~= '/' then
                                bufferPath = fn.getcwd() .. "/" .. bufferPath

                                local title = fn.findfile('.git', bufferPath .. ';')
                                if title == "" then
                                    title = fn.finddir('.git', bufferPath .. ';')
                                end
                                title = fn.getcwd() .. "/" .. title
                                return fn.fnamemodify(title, ':h:t') .. project_icon
                            end

                            local title = fn.findfile('.git', bufferPath .. ';')
                            if title == "" then
                                title = fn.finddir('.git', bufferPath .. ';')
                            end

                            if title == "" then
                                if fn.getqflist({ ['qfbufnr'] = 0 }).qfbufnr == bufnr then
                                    return '[Quickfix List]'
                                elseif winid and fn.getloclist(winid, { ['qfbufnr'] = 0 }).qfbufnr == bufnr then
                                    return '[Location List]'
                                end
                                return fn.fnamemodify(bufferPath, ':p:t') .. file_icon
                            end

                            return fn.fnamemodify(title, ':h:t') .. project_icon
                        end,
                        separator = { left = '', right = '' },
                        tabs_color = {
                            -- Same values as the general color option can be used here.
                            -- active = { fg = colors.black, bg = colors.grey },
                            inactive = { fg = require("common").colors.LualineTabInactiveFg, bg = require("common").colors.LualineTabInactiveBg }, -- Color for inactive tab.
                        },
                    } },
                    lualine_b = {},
                    lualine_c = {},
                    lualine_x = {},
                    lualine_y = { {
                        function() return "󰕶 " .. require("common").weeks[os.date('%w')] .. "  " .. os.date('%y-%m-%d') end,
                        separator = { left = '' },
                    } },
                    lualine_z = { {
                        function() return "󰔛 " .. os.date('%H:%M:%S') end,
                        separator = { right = '' }
                    } },
                },
                winbar = {},
                inactive_winbar = {},
                extensions = {
                    'aerial',
                    'chadtree',
                    'fern',
                    'fugitive',
                    'fzf',
                    'man',
                    'mundo',
                    'neo-tree',
                    'nerdtree',
                    'nvim-dap-ui',
                    'nvim-tree',
                    'quickfix',
                    'symbols-outline',
                    'toggleterm',
                }
            })
        end,
    },
    {
        'linrongbin16/lsp-progress.nvim',
        event = "LspAttach",
        dependencies = {
            "nvim-lualine/lualine.nvim",
        },
        config = function()
            require("lsp-progress").setup {
                format = function(client_messages)
                    return #client_messages > 0
                        and (" LSP " .. table.concat(client_messages, " "))
                        or ""
                end,
                decay = 3000,
            }

            local old = require("lualine").get_config()
            table.insert(old.sections.lualine_x, 1, require("lsp-progress").progress)
            require("lualine").setup(old)

            local lualine_augroup = api.nvim_create_augroup("LualineAugroup", { clear = true })
            api.nvim_create_autocmd(
                { "User" },
                {
                    pattern = "LspProgressStatusUpdated",
                    callback = function()
                        require("lualine").refresh({
                            scope = 'tabpage',
                            place = { 'statusline' }
                        })
                    end,
                    group = lualine_augroup,
                }
            )
        end
    },
    {
        "SmiteshP/nvim-navic",
        event = "VeryLazy",
        dependencies = {
            "nvim-lualine/lualine.nvim",
        },
        config = function()
            local navic = require("nvim-navic")
            navic.setup({
                icons = {
                    File          = "󰈙 ",
                    Module        = " ",
                    Namespace     = "󰌗 ",
                    Package       = " ",
                    Class         = "󰌗 ",
                    Method        = "󰆧 ",
                    Property      = " ",
                    Field         = " ",
                    Constructor   = " ",
                    Enum          = "󰕘",
                    Interface     = "󰕘",
                    Function      = "󰊕 ",
                    Variable      = "󰆧 ",
                    Constant      = "󰏿 ",
                    String        = "󰀬 ",
                    Number        = "󰎠 ",
                    Boolean       = "◩ ",
                    Array         = "󰅪 ",
                    Object        = "󰅩 ",
                    Key           = "󰌋 ",
                    Null          = "󰟢 ",
                    EnumMember    = " ",
                    Struct        = "󰌗 ",
                    Event         = " ",
                    Operator      = "󰆕 ",
                    TypeParameter = "󰊄 ",
                },
                lsp = {
                    auto_attach = true,
                    preference = nil,
                },
                highlight = false,
                separator = "",
                depth_limit = 0,
                depth_limit_indicator = "..",
                safe_output = true,
                lazy_update_context = false,
                click = true
            })

            local old = require("lualine").get_config()
            table.insert(old.tabline.lualine_c, #old.tabline.lualine_c + 1, {
                function()
                    return navic.get_location({ click = true })
                end,
                cond = function()
                    return navic.is_available()
                end,
                on_click = function()
                    _G.navic_click_handler(api.nvim_get_current_win())
                end
            })
            require("lualine").setup(old)
        end
    },
    {
        "b0o/incline.nvim",
        event = "VeryLazy",
        opts = {
            debounce_threshold = {
                falling = 50,
                rising = 10
            },
            hide = {
                cursorline = false,
                focused_win = true,
                only_win = false
            },
            highlight = {
                groups = {
                    InclineNormal = {
                        default = true,
                        group = "FloatBorder"
                    },
                    InclineNormalNC = {
                        default = true,
                        group = "FloatBorder"
                    }
                }
            },
            ignore = {
                buftypes = "special",
                filetypes = {},
                floating_wins = true,
                unlisted_buffers = true,
                wintypes = "special"
            },
            render = function(props)
                local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
                local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)
                local modified = vim.api.nvim_buf_get_option(props.buf, "modified") and
                    " " .. require("common").glyphs.modified or ""

                local buffer = {
                    { "[",      guifg = require("common").colors.CustomBorderFg },
                    { ft_icon,  guifg = require("common").colors.CustomBorderFg },
                    { " " },
                    { filename, guifg = require("common").colors.CustomBorderFg },
                    { modified, guifg = require("common").colors.CustomBorderFg },
                    { "]",      guifg = require("common").colors.CustomBorderFg },
                }
                return buffer
            end,
            window = {
                margin = {
                    horizontal = 0,
                    vertical = 0
                },
                options = {
                    signcolumn = "no",
                    wrap = false
                },
                padding = 0,
                padding_char = " ",
                placement = {
                    horizontal = "right",
                    vertical = "top"
                },
                width = "fit",
                winhighlight = {
                    active = {
                        EndOfBuffer = "None",
                        Normal = "InclineNormal",
                        Search = "None"
                    },
                    inactive = {
                        EndOfBuffer = "FloatBorder",
                        Normal = "NormalFloat",
                        Search = "FloatBorder"
                    }
                },
                zindex = 50
            },
        }
    },
}
