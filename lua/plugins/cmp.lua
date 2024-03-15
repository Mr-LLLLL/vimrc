return {
    {
        'L3MON4D3/LuaSnip',
        lazy = true,
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end
    },
    {
        'hrsh7th/nvim-cmp',
        event = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            --  For luasnip users.
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            "rafamadriz/friendly-snippets",

            'hrsh7th/cmp-emoji',
            'chrisgrieser/cmp-nerdfont',
            'hrsh7th/cmp-calc',
            'kristijanhusak/vim-dadbod-completion',
            'hrsh7th/cmp-nvim-lua',
            'onsails/lspkind.nvim',
            "sourcegraph/sg.nvim",
            -- "Exafunction/codeium.nvim",
        },
        config = function()
            local cmp = require 'cmp'
            local luasnip = require 'luasnip'

            ---@diagnostic disable-next-line: unused-function, unused-local
            local has_words_before = function()
                unpack = unpack or table.unpack
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and
                    vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
            end

            cmp.setup({
                snippet = {
                    -- REQUIRED - you must specify a snippet engine
                    expand = function(args)
                        -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
                        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
                    end,
                },
                window = {
                    completion = {
                        border = 'rounded',
                        winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:DiffAdd,Search:None',
                        col_offset = -3,
                        side_padding = 0,
                    },
                    documentation = {
                        border = 'rounded',
                        winhighlight = 'FloatBorder:FloatBorder',
                    },
                },
                preselect = cmp.PreselectMode.Item,
                view = {
                    entries = "custom",
                },
                experimental = {
                    ghost_text = {}
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<CR>'] = cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = false,
                    },
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                            -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
                            -- they way you will only jump inside the snippet region
                            -- elseif luasnip.expand_or_jumpable() then
                            --     luasnip.expand_or_jump()
                            -- elseif has_words_before() then
                            --   cmp.complete()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                            -- elseif luasnip.jumpable( -1) then
                            --     luasnip.jump( -1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<c-j>"] = {
                        c = function(fallback)
                            if cmp.visible() then
                                cmp.select_next_item()
                            else
                                fallback()
                            end
                        end,
                        i = cmp.mapping.select_next_item({ behavior = require("cmp.types").cmp.SelectBehavior.Select }),
                    },
                    ["<c-k>"] = {
                        c = function(fallback)
                            if cmp.visible() then
                                cmp.select_prev_item()
                            else
                                fallback()
                            end
                        end,
                        i = cmp.mapping.select_prev_item({ behavior = require("cmp.types").cmp.SelectBehavior.Select }),
                    },
                    ["<c-n>"] = {
                        i = function(fallback)
                            if luasnip.locally_jumpable(1) then
                                -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
                                -- they way you will only jump inside the snippet region
                                luasnip.jump(1)
                            else
                                fallback()
                            end
                        end
                    },
                    ["<c-p>"] = {
                        i = function(fallback)
                            if luasnip.locally_jumpable(-1) then
                                -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
                                -- they way you will only jump inside the snippet region
                                luasnip.jump(-1)
                            else
                                fallback()
                            end
                        end
                    },
                }),
                sources = cmp.config.sources({
                    -- { name = 'codeium' },
                    { name = 'cody' },
                    { name = 'nvim_lsp' },

                    -- { name = 'vsnip' }, -- For vsnip users.
                    { name = 'luasnip' }, -- For luasnip users.
                    -- { name = 'ultisnips' }, -- For ultisnips users.
                    -- { name = 'snippy' }, -- For snippy users.

                    { name = 'emoji' },
                    { name = 'nerdfont' },
                    { name = 'calc' },
                    { name = 'nvim_lua' },
                    { name = 'path' },
                }, {
                    { name = 'buffer' },
                }),
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = function(entry, vim_item)
                        local kind = require("lspkind").cmp_format({
                            -- defines how annotations are shown
                            -- default: symbol
                            -- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
                            mode = 'symbol',
                            maxwidth = 50,         -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                            ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
                            -- The function below will be called before any actual modifications from lspkind
                            -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
                            -- before = function (entry, vim_item)
                            --     vim_item.menu = entry.source.name
                            --     return vim_item
                            -- end,
                            symbol_map = {
                                -- Codeium = "",
                                Cody = ""
                            },
                            menu = ({
                                buffer = "[B]",
                                nvim_lsp = "[LSP]",
                                luasnip = "[Snip]",
                                nvim_lua = "[Lua]",
                                latex_symbols = "[Latex]",
                                calc = "[Cal]",
                                emoji = "[Emoj]",
                                nerdfont = "[Font]",
                                cmdline = "[Cmd]",
                                path = "[Path]",
                                -- codeium = "[Cod]",
                                cody = "[AI]",
                            })
                        })(entry, vim_item)
                        local strings = vim.split(kind.kind, "%s", { trimempty = true })
                        kind.kind = " " .. (strings[1] or "") .. " "
                        -- kind.menu = "    (" .. (strings[2] or "") .. ")"

                        return kind
                    end,
                }
            })

            -- Set configuration for specific filetype.
            cmp.setup.filetype('gitcommit', {
                sources = cmp.config.sources({
                    { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
                }, {
                    { name = 'buffer' },
                })
            })

            -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
            -- cmp.setup.cmdline({ '/', '?' }, {
            --     mapping = cmp.mapping.preset.cmdline(),
            --     sources = {
            --         { name = 'buffer' }
            --     }
            -- }
            -- )

            -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' }
                }, {
                    { name = 'cmdline' }
                })
            })
        end
    },
}
