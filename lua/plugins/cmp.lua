return {
    {
        'saghen/blink.compat',
        -- use the latest release, via version = '*', if you also use the latest release for blink.cmp
        version = '*',
        -- lazy.nvim will automatically load the plugin when it's required by blink.cmp
        lazy = true,
        -- make sure to set opts so that lazy.nvim calls blink.compat's setup
        opts = {},
    },
    {
        'saghen/blink.cmp',
        -- optional: provides snippets for the snippet source
        dependencies = {
            'rafamadriz/friendly-snippets',
            'kristijanhusak/vim-dadbod-completion',
            "mikavilpas/blink-ripgrep.nvim",
            "moyiz/blink-emoji.nvim",
            'hrsh7th/cmp-calc',
            'chrisgrieser/cmp-nerdfont',
            'hrsh7th/cmp-nvim-lua',
        },
        event = "InsertEnter",
        -- use a release tag to download pre-built binaries
        version = '*',
        -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
        -- build = 'cargo build --release',
        -- If you use nix, you can build from source using latest nightly rust with:
        -- build = 'nix run .#build-plugin',

        config = function()
            require("blink.cmp").setup({
                enabled = function()
                    return not vim.tbl_contains({ "DressingInput" }, vim.bo.filetype)
                        and not vim.tbl_contains({ "prompt" }, vim.bo.buftype)
                        and vim.b.completion ~= false
                end,
                completion = {
                    -- 'prefix' will fuzzy match on the text before the cursor
                    -- 'full' will fuzzy match on the text before *and* after the cursor
                    -- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'
                    keyword = { range = 'prefix' },

                    -- Disable auto brackets
                    -- NOTE: some LSPs may add auto brackets themselves anyway
                    accept = { auto_brackets = { enabled = true }, },

                    -- Insert completion item on selection, don't select by default
                    -- list = { selection = 'auto_insert' },
                    -- or set per mode
                    list = {
                        selection = {
                            preselect = function(ctx)
                                return ctx.mode ~= 'cmdline'
                            end,
                            auto_insert = function(ctx)
                                return ctx.mode == "cmdline"
                            end,
                        },
                    },

                    menu = {
                        -- Don't automatically show the completion menu
                        auto_show = true,

                        -- nvim-cmp style menu
                        draw = {
                            components = {
                                kind_icon = {
                                    ellipsis = true,
                                },
                                source_name = {
                                    width = { max = 30 },
                                    text = function(ctx)
                                        local t = {
                                            Buffer = "[B]",
                                            LSP = "[LSP]",
                                            Snippets = "[Snip]",
                                            Dadbod = "[Db]",
                                            Ripgrep = "[Rg]",
                                            Emoji = "[Emo]",
                                            Path = "[Path]",
                                            nvim_lua = "[Lua]",
                                            calc = "[Cal]",
                                            nerdfont = "[Font]",
                                        }
                                        return t[ctx.source_name]
                                    end,
                                    highlight = 'BlinkCmpSource',
                                },

                            },
                            columns = {
                                { 'kind_icon' },
                                { 'label',      'label_description', gap = 1 },
                                { 'source_name' },
                            },
                            treesitter = { "lsp", "buffer", "snippets" }
                        },
                        border = "rounded",
                        winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:DiffAdd,Search:None',
                        winblend = vim.g.custom_blend,
                    },
                    -- Show documentation when selecting a completion item
                    documentation = {
                        auto_show = true,
                        auto_show_delay_ms = 250,
                        window = {
                            border = "rounded",
                            winblend = vim.g.custom_blend,
                            winhighlight = 'FloatBorder:FloatBorder',
                        },
                    },

                    -- Display a preview of the selected item on the current line
                    ghost_text = { enabled = true },
                },
                -- 'default' for mappings similar to built-in completion
                -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
                -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
                -- See the full "keymap" documentation for information on defining your own keymap.
                keymap = {
                    -- set to 'none' to disable the 'default' preset
                    preset = 'none',

                    ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
                    ['<C-e>'] = { 'hide' },
                    ['<c-y>'] = { 'select_and_accept' },
                    ['<CR>'] = { 'select_and_accept', 'fallback' },

                    ['<C-k>'] = { 'select_prev', 'fallback' },
                    ['<C-j>'] = { 'select_next', 'fallback' },
                    ['<up>'] = { 'select_prev', 'fallback' },
                    ['<down>'] = { 'select_next', 'fallback' },
                    ['<Tab>'] = { 'select_next', 'fallback' },
                    ['<S-Tab>'] = { 'select_prev', 'fallback' },

                    ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
                    ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

                    ['<c-n>'] = { 'snippet_forward', 'fallback' },
                    ['<c-p>'] = { 'snippet_backward', 'fallback' },
                    cmdline = {
                        preset = 'none',
                        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
                        ['<C-e>'] = { 'hide' },
                        ['<c-y>'] = { 'select_and_accept' },

                        ['<C-k>'] = { 'select_prev', 'fallback' },
                        ['<C-j>'] = { 'select_next', 'fallback' },
                        ['<up>'] = { 'select_prev', 'fallback' },
                        ['<down>'] = { 'select_next', 'fallback' },
                        ['<Tab>'] = { 'select_next', 'fallback' },
                        ['<S-Tab>'] = { 'select_prev', 'fallback' },

                        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
                        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
                    }
                },

                appearance = {
                    -- Sets the fallback highlight groups to nvim-cmp's highlight groups
                    -- Useful for when your theme doesn't support blink.cmp
                    -- Will be removed in a future release
                    use_nvim_cmp_as_default = false,
                    -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                    -- Adjusts spacing to ensure icons are aligned
                    nerd_font_variant = 'mono'
                },

                sources = {
                    default = function()
                        local success, node = pcall(vim.treesitter.get_node)
                        if success and node and vim.tbl_contains({ 'comment', 'line_comment', 'block_comment' }, node:type()) then
                            return { 'buffer', 'ripgrep', 'emoji', 'nerdfont' }
                        else
                            return { 'nvim_lua', 'lsp', 'path', 'buffer', "ripgrep", 'dadbod', "emoji", "calc",
                                "nerdfont", 'snippets' }
                        end
                    end,
                    min_keyword_length = function()
                        return vim.bo.filetype == 'markdown' and 2 or 0
                    end,
                    cmdline = function()
                        local type = vim.fn.getcmdtype()
                        -- Search forward and backward
                        if type == '/' or type == '?' then return { 'buffer' } end
                        -- Commands
                        if type == ':' or type == '@' then return { 'cmdline', 'path' } end
                        return {}
                    end,
                    providers = {
                        nvim_lua = {
                            name = 'nvim_lua', -- IMPORTANT: use the same name as you would for nvim-cmp
                            module = 'blink.compat.source',

                            -- all blink.cmp source config options work as normal:
                            score_offset = 5,

                            -- this table is passed directly to the proxied completion source
                            -- as the `option` field in nvim-cmp's source config
                            --
                            -- this is NOT the same as the opts in a plugin's lazy.nvim spec
                            opts = {
                                -- this is an option from cmp-digraphs
                                -- cache_digraphs_on_start = true,
                            },
                        },
                        nerdfont = {
                            name = 'nerdfont', -- IMPORTANT: use the same name as you would for nvim-cmp
                            module = 'blink.compat.source',

                            -- all blink.cmp source config options work as normal:
                            score_offset = 14,

                            -- this table is passed directly to the proxied completion source
                            -- as the `option` field in nvim-cmp's source config
                            --
                            -- this is NOT the same as the opts in a plugin's lazy.nvim spec
                            opts = {
                                -- this is an option from cmp-digraphs
                                -- cache_digraphs_on_start = true,
                            },
                        },
                        calc = {
                            name = 'calc', -- IMPORTANT: use the same name as you would for nvim-cmp
                            module = 'blink.compat.source',

                            -- all blink.cmp source config options work as normal:
                            score_offset = -3,

                            -- this table is passed directly to the proxied completion source
                            -- as the `option` field in nvim-cmp's source config
                            --
                            -- this is NOT the same as the opts in a plugin's lazy.nvim spec
                            opts = {
                                -- this is an option from cmp-digraphs
                                -- cache_digraphs_on_start = true,
                            },
                        },
                        emoji = {
                            module = "blink-emoji",
                            name = "Emoji",
                            score_offset = 15, -- Tune by preference
                        },
                        ripgrep = {
                            module = "blink-ripgrep",
                            name = "Ripgrep",

                            score_offset = -5,
                            -- the options below are optional, some default values are shown
                            ---@module "blink-ripgrep"
                            ---@type blink-ripgrep.Options
                            opts = {
                                -- For many options, see `rg --help` for an exact description of
                                -- the values that ripgrep expects.

                                -- the minimum length of the current word to start searching
                                -- (if the word is shorter than this, the search will not start)
                                prefix_min_len = 3,

                                -- The number of lines to show around each match in the preview
                                -- (documentation) window. For example, 5 means to show 5 lines
                                -- before, then the match, and another 5 lines after the match.
                                context_size = 5,

                                -- The maximum file size of a file that ripgrep should include in
                                -- its search. Useful when your project contains large files that
                                -- might cause performance issues.
                                -- Examples:
                                -- "1024" (bytes by default), "200K", "1M", "1G", which will
                                -- exclude files larger than that size.
                                max_filesize = "1M",

                                -- Specifies how to find the root of the project where the ripgrep
                                -- search will start from. Accepts the same options as the marker
                                -- given to `:h vim.fs.root()` which offers many possibilities for
                                -- configuration. If none can be found, defaults to Neovim's cwd.
                                --
                                -- Examples:
                                -- - ".git" (default)
                                -- - { ".git", "package.json", ".root" }
                                project_root_marker = ".git",

                                -- The casing to use for the search in a format that ripgrep
                                -- accepts. Defaults to "--ignore-case". See `rg --help` for all the
                                -- available options ripgrep supports, but you can try
                                -- "--case-sensitive" or "--smart-case".
                                search_casing = "--ignore-case",

                                -- (advanced) Any additional options you want to give to ripgrep.
                                -- See `rg -h` for a list of all available options. Might be
                                -- helpful in adjusting performance in specific situations.
                                -- If you have an idea for a default, please open an issue!
                                --
                                -- Not everything will work (obviously).
                                additional_rg_options = {},

                                -- When a result is found for a file whose filetype does not have a
                                -- treesitter parser installed, fall back to regex based highlighting
                                -- that is bundled in Neovim.
                                fallback_to_regex_highlighting = true,

                                -- Show debug information in `:messages` that can help in
                                -- diagnosing issues with the plugin.
                                debug = false,
                            },
                            -- (optional) customize how the results are displayed. Many options
                            -- are available - make sure your lua LSP is set up so you get
                            -- autocompletion help
                            transform_items = function(_, items)
                                for _, item in ipairs(items) do
                                    -- example: append a description to easily distinguish rg results
                                    item.labelDetails = {
                                        -- description = "(rg)",
                                        description = "",
                                    }
                                end
                                return items
                            end,
                        },
                        dadbod = {
                            name = "Dadbod",
                            module = "vim_dadbod_completion.blink",
                        },
                    },
                },
                -- Experimental signature help support
                signature = {
                    enabled = true,
                    window = {
                        border = "rounded",
                        max_height = 1,
                        winblend = vim.g.custom_blend,
                        winhighlight = 'FloatBorder:FloatBorder',
                    }
                }
            })

            vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelpActiveParameter", { link = "DiffAdd" })
        end,
        opts_extend = { "sources.default" }
    }
    -- {
    --     "garymjr/nvim-snippets",
    --     lazy = true,
    --     opts = {
    --         friendly_snippets = true,
    --         create_cmp_source = true,
    --         highlight_preview = true,
    --     }
    -- },
    -- {
    --     'hrsh7th/nvim-cmp',
    --     event = { "InsertEnter", "CmdlineEnter" },
    --     dependencies = {
    --         'hrsh7th/cmp-nvim-lsp',
    --         'hrsh7th/cmp-buffer',
    --         'hrsh7th/cmp-path',
    --         'hrsh7th/cmp-cmdline',
    --         "rafamadriz/friendly-snippets",
    --         "garymjr/nvim-snippets",
    --
    --         'hrsh7th/cmp-emoji',
    --         'chrisgrieser/cmp-nerdfont',
    --         'hrsh7th/cmp-calc',
    --         'kristijanhusak/vim-dadbod-completion',
    --         'hrsh7th/cmp-nvim-lua',
    --         'onsails/lspkind.nvim',
    --         -- "sourcegraph/sg.nvim",
    --         -- "Exafunction/codeium.nvim",
    --     },
    --     config = function()
    --         local cmp = require 'cmp'
    --
    --         ---@diagnostic disable-next-line: unused-function, unused-local
    --         local has_words_before = function()
    --             unpack = unpack or table.unpack
    --             local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    --             return col ~= 0 and
    --                 vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    --         end
    --
    --         cmp.setup({
    --             snippet = {
    --                 -- REQUIRED - you must specify a snippet engine
    --                 expand = function(args)
    --                     -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
    --                     -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    --                     -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
    --                     -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    --                     vim.snippet.expand(args.body)
    --                 end,
    --             },
    --             window = {
    --                 completion = {
    --                     border = 'rounded',
    --                     winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:DiffAdd,Search:None',
    --                     col_offset = -3,
    --                     side_padding = 0,
    --                 },
    --                 documentation = {
    --                     border = 'rounded',
    --                     winhighlight = 'FloatBorder:FloatBorder',
    --                 },
    --             },
    --             preselect = cmp.PreselectMode.Item,
    --             view = {
    --                 entries = "custom",
    --             },
    --             experimental = {
    --                 ghost_text = {}
    --             },
    --             mapping = cmp.mapping.preset.insert({
    --                 ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    --                 ['<C-f>'] = cmp.mapping.scroll_docs(4),
    --                 ['<C-e>'] = cmp.mapping.abort(),
    --                 ['<C-Space>'] = cmp.mapping.complete(),
    --                 ['<CR>'] = cmp.mapping.confirm {
    --                     behavior = cmp.ConfirmBehavior.Replace,
    --                     select = false,
    --                 },
    --                 ["<Tab>"] = cmp.mapping(function(fallback)
    --                     if cmp.visible() then
    --                         cmp.select_next_item()
    --                         -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
    --                         -- they way you will only jump inside the snippet region
    --                         -- elseif luasnip.expand_or_jumpable() then
    --                         --     luasnip.expand_or_jump()
    --                         -- elseif has_words_before() then
    --                         --   cmp.complete()
    --                     else
    --                         fallback()
    --                     end
    --                 end, { "i", "s" }),
    --                 ["<S-Tab>"] = cmp.mapping(function(fallback)
    --                     if cmp.visible() then
    --                         cmp.select_prev_item()
    --                         -- elseif luasnip.jumpable( -1) then
    --                         --     luasnip.jump( -1)
    --                     else
    --                         fallback()
    --                     end
    --                 end, { "i", "s" }),
    --                 ["<c-j>"] = {
    --                     c = function(fallback)
    --                         if cmp.visible() then
    --                             cmp.select_next_item()
    --                         else
    --                             fallback()
    --                         end
    --                     end,
    --                     i = cmp.mapping.select_next_item({ behavior = require("cmp.types").cmp.SelectBehavior.Select }),
    --                 },
    --                 ["<c-k>"] = {
    --                     c = function(fallback)
    --                         if cmp.visible() then
    --                             cmp.select_prev_item()
    --                         else
    --                             fallback()
    --                         end
    --                     end,
    --                     i = cmp.mapping.select_prev_item({ behavior = require("cmp.types").cmp.SelectBehavior.Select }),
    --                 },
    --                 ["<c-n>"] = cmp.mapping(function(fallback)
    --                     if vim.snippet.active({ direction = 1 }) then
    --                         vim.schedule(function()
    --                             vim.snippet.jump(1)
    --                         end)
    --                         return
    --                     end
    --                     return fallback()
    --                 end, { "i", "s" }),
    --                 ["<c-p>"] = cmp.mapping(function(fallback)
    --                     if vim.snippet.active({ direction = -1 }) then
    --                         vim.schedule(function()
    --                             vim.snippet.jump(-1)
    --                         end)
    --                         return
    --                     end
    --                     return fallback()
    --                 end, { "i", "s" }),
    --             }),
    --             sources = cmp.config.sources({
    --                 -- { name = 'codeium' },
    --                 -- { name = 'cody' },
    --                 { name = 'nvim_lsp' },
    --                 { name = "snippets" },
    --
    --                 -- { name = 'vsnip' }, -- For vsnip users.
    --                 -- { name = 'luasnip' }, -- For luasnip users.
    --                 -- { name = 'ultisnips' }, -- For ultisnips users.
    --                 -- { name = 'snippy' }, -- For snippy users.
    --
    --                 { name = 'emoji' },
    --                 { name = 'nerdfont' },
    --                 { name = 'calc' },
    --                 { name = 'nvim_lua' },
    --                 { name = 'path' },
    --             }, {
    --                 { name = 'buffer' },
    --             }),
    --             formatting = {
    --                 fields = { "kind", "abbr", "menu" },
    --                 format = function(entry, vim_item)
    --                     local kind = require("lspkind").cmp_format({
    --                         -- defines how annotations are shown
    --                         -- default: symbol
    --                         -- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
    --                         mode = 'symbol',
    --                         maxwidth = 50,         -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
    --                         ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
    --                         -- The function below will be called before any actual modifications from lspkind
    --                         -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
    --                         -- before = function (entry, vim_item)
    --                         --     vim_item.menu = entry.source.name
    --                         --     return vim_item
    --                         -- end,
    --                         symbol_map = {
    --                             -- Codeium = "",
    --                             -- Cody = ""
    --                         },
    --                         menu = ({
    --                             buffer = "[B]",
    --                             nvim_lsp = "[LSP]",
    --                             snippets = "[Snip]",
    --                             nvim_lua = "[Lua]",
    --                             latex_symbols = "[Latex]",
    --                             calc = "[Cal]",
    --                             emoji = "[Emoj]",
    --                             nerdfont = "[Font]",
    --                             cmdline = "[Cmd]",
    --                             path = "[Path]",
    --                             -- codeium = "[AI]",
    --                             -- cody = "[AI]",
    --                         })
    --                     })(entry, vim_item)
    --                     local strings = vim.split(kind.kind, "%s", { trimempty = true })
    --                     kind.kind = " " .. (strings[1] or "") .. " "
    --                     -- kind.menu = "    (" .. (strings[2] or "") .. ")"
    --
    --                     return kind
    --                 end,
    --             }
    --         })
    --
    --         -- Set configuration for specific filetype.
    --         cmp.setup.filetype('gitcommit', {
    --             sources = cmp.config.sources({
    --                 { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    --             }, {
    --                 { name = 'buffer' },
    --             })
    --         })
    --
    --         -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
    --         -- cmp.setup.cmdline({ '/', '?' }, {
    --         --     mapping = cmp.mapping.preset.cmdline(),
    --         --     sources = {
    --         --         { name = 'buffer' }
    --         --     }
    --         -- }
    --         -- )
    --
    --         -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    --         cmp.setup.cmdline(':', {
    --             mapping = cmp.mapping.preset.cmdline(),
    --             sources = cmp.config.sources({
    --                 { name = 'path' }
    --             }, {
    --                 { name = 'cmdline' }
    --             })
    --         })
    --     end
    -- },
}
