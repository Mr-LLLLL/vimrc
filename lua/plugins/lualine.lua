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
            require("lualine-ext").init_tab_navic()
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
    {
        "Mr-LLLLL/lualine-ext.nvim",
        event = "VeryLazy",
        opts = {
            init_tab_project = {
                disabled = false,
                tabs_color = {
                    inactive = {
                        fg = "#9da9a0",
                        bg = "#4f5b58",
                    },
                }
            },
            init_lsp = {
                disabled = false,
                document_on_click = function()
                    require('lspsaga.hover'):render_hover_doc()
                end,
            },
            init_tab_date = true,
        }
    },
}
