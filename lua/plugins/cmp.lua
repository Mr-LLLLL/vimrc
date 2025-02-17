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
            'milanglacier/minuet-ai.nvim',
            -- "Exafunction/codeium.nvim",
            -- "supermaven-inc/supermaven-nvim",

            'rafamadriz/friendly-snippets',
            'kristijanhusak/vim-dadbod-completion',
            "mikavilpas/blink-ripgrep.nvim",
            "moyiz/blink-emoji.nvim",
            'hrsh7th/cmp-calc',
            'chrisgrieser/cmp-nerdfont',
        },
        event = "InsertEnter",
        -- use a release tag to download pre-built binaries
        version = '*',
        -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
        -- build = 'cargo build --release',
        -- If you use nix, you can build from source using latest nightly rust with:
        -- build = 'nix run .#build-plugin',

        config = function()
            local default_source = {
                "avante_commands",
                "avante_mentions",
                "avante_files",
                'lazydev',
                'lsp',
                'path',
                'buffer',
                "ripgrep",
                'dadbod',
                "emoji",
                "calc",
                "nerdfont",
                'snippets',
                -- 'codeium',
                -- 'supermaven',
                'codecompanion',
            }
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
                                            Dadbod = "[DB]",
                                            Ripgrep = "[RG]",
                                            Emoji = "[Emo]",
                                            Path = "[Path]",
                                            calc = "[Cal]",
                                            nerdfont = "[Font]",
                                            minuet = "[Deep]",
                                            avante_commands = "[Ava]",
                                            avante_mentions = "[Ava]",
                                            avante_files = "[Ava]",
                                            codeium = "[Cod]",
                                            supermaven = "[Sup]",
                                            CodeCompanion = "[Comp]",
                                            LazyDev = "[Lua]",
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
                    ['<c-/>'] = {
                        function(cmp)
                            local t = {
                                "minuet",
                            }
                            for _, v in ipairs(default_source) do
                                table.insert(t, v)
                            end
                            cmp.show { providers = t }
                        end,
                    },

                    ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
                    ['<C-e>'] = { 'hide', "fallback" },
                    ['<CR>'] = { 'select_and_accept', 'fallback' },
                    ['<c-y>'] = { 'select_and_accept', 'fallback' },

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
                },
                cmdline = {
                    enabled = true,
                    keymap = {
                        preset = 'none',
                        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
                        ['<C-e>'] = { 'hide', "fallback" },
                        ['<c-y>'] = { 'select_and_accept', 'fallback' },

                        ['<C-k>'] = { 'select_prev', 'fallback' },
                        ['<C-j>'] = { 'select_next', 'fallback' },
                        ['<up>'] = { 'select_prev', 'fallback' },
                        ['<down>'] = { 'select_next', 'fallback' },
                        ['<Tab>'] = { 'select_next', 'fallback' },
                        ['<S-Tab>'] = { 'select_prev', 'fallback' },

                        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
                        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
                    },
                    sources = function()
                        local type = vim.fn.getcmdtype()
                        -- Search forward and backward
                        if type == '/' or type == '?' then return { 'buffer' } end
                        -- Commands
                        if type == ':' or type == '@' then return { 'cmdline', 'path' } end

                        return {}
                    end,
                    completion = {
                        menu = {
                            draw = {
                                columns = {
                                    { 'kind_icon' },
                                    { 'label',      'label_description', gap = 1 },
                                    { 'source_name' },
                                },
                            },
                        },
                    },
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
                        return default_source
                    end,
                    providers = {
                        lazydev = {
                            name = "LazyDev",
                            module = "lazydev.integrations.blink",
                            -- make lazydev completions top priority (see `:h blink.cmp`)
                            score_offset = 100,
                        },
                        -- supermaven = {
                        --     name = "supermaven",
                        --     module = "blink.compat.source",
                        --     score_offset = 6, -- show at a higher priority than lsp
                        --     async = true,
                        --     opts = {},
                        -- },
                        -- codeium = {
                        --     name = "codeium",
                        --     module = "blink.compat.source",
                        --     score_offset = 6, -- show at a higher priority than lsp
                        --     async = true,
                        --     opts = {},
                        -- },
                        minuet = {
                            name = 'minuet',
                            module = 'minuet.blink',
                            score_offset = 6, -- Gives minuet higher priority among suggestions
                        },
                        avante_commands = {
                            name = "avante_commands",
                            module = "blink.compat.source",
                            score_offset = 10, -- show at a higher priority than lsp
                            opts = {},
                        },
                        avante_files = {
                            name = "avante_files",
                            module = "blink.compat.source",
                            score_offset = 10, -- show at a higher priority than lsp
                            opts = {},
                        },
                        avante_mentions = {
                            name = "avante_mentions",
                            module = "blink.compat.source",
                            score_offset = 10, -- show at a higher priority than lsp
                            opts = {},
                        },
                        nerdfont = {
                            name = 'nerdfont', -- IMPORTANT: use the same name as you would for nvim-cmp
                            module = 'blink.compat.source',

                            -- all blink.cmp source config options work as normal:
                            score_offset = 4,

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
                            score_offset = 5, -- Tune by preference
                        },
                        ripgrep = {
                            module = "blink-ripgrep",
                            name = "Ripgrep",
                            async = true,

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
                            score_offset = 5,
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
}
