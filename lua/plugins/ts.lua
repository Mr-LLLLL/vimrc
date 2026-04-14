return {
    {
        'RRethy/nvim-treesitter-endwise',
        event = "InsertEnter",
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
        }
    },
    {
        'nvim-treesitter/nvim-treesitter',
        branch = "main",
        build = ':TSUpdate',
        dependencies = {
            'm-demare/hlargs.nvim',
        },
        config = function()
            local nvim_treesitter = require("nvim-treesitter")
            local ensure_installed = {
                "cpp",
                "diff",
                "go",
                "gomod",
                "gosum",
                "javascript",
                "json",
                "lua",
                "markdown",
                "python",
                "sh",
                "toml",
                "typescript",
                "vim",
                "yaml",
                "zsh",
                "http",
            }

            vim.api.nvim_create_autocmd("FileType", {
                pattern = ensure_installed,

                callback = function(args)
                    local ft = vim.bo[args.buf].filetype
                    local lang = vim.treesitter.language.get_lang(ft)
                    if lang == nil then
                        return
                    end

                    -- check if parser is available
                    local is_parser_available = vim.treesitter.language.add(lang)
                    if not is_parser_available then
                        local available_langs = vim.g.ts_available or nvim_treesitter.get_available()
                        if not vim.g.ts_available then
                            vim.g.ts_available = available_langs
                        end

                        if vim.tbl_contains(available_langs, lang) then
                            -- install treesitter parsers and queries
                            local install_msg = string.format("Installing parsers and queries for %s", lang)
                            vim.print(install_msg)
                            require("nvim-treesitter").install(lang)
                        end
                    end

                    if vim.treesitter.language.add(lang) then
                        -- start treesitter highlighting
                        vim.treesitter.start(args.buf, lang)

                        -- the following two statements will enable treesitter folding
                        -- vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
                        -- vim.wo[0][0].foldmethod = "expr"

                        -- enable treesitter-based indentation
                        -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end
    },
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = "main",
        init = function()
            -- Disable entire built-in ftplugin mappings to avoid conflicts.
            -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
            vim.g.no_plugin_maps = true

            -- Or, disable per filetype (add as you like)
            -- vim.g.no_python_maps = true
            -- vim.g.no_ruby_maps = true
            -- vim.g.no_rust_maps = true
            -- vim.g.no_go_maps = true
        end,
        config = function()
            require("nvim-treesitter-textobjects").setup {
                select = {
                    enable = true,
                    lookahead = true,
                    include_surrounding_whitespace = true,
                },
                move = {
                    enable = false,
                }
            }
        end,
        keys = {
            {
                'af',
                function()
                    require "nvim-treesitter-textobjects.select".select_textobject("@function.outer", "textobjects")
                end,
                mode = { 'x', 'o' },
                desc = 'a function region',
            },
            {
                'if',
                function()
                    require "nvim-treesitter-textobjects.select".select_textobject("@function.inner", "textobjects")
                end,
                mode = { 'x', 'o' },
                desc = 'inner part of a function region',
            },
            {
                'ac',
                function()
                    require "nvim-treesitter-textobjects.select".select_textobject("@class.outer", "textobjects")
                    ts.select.select_textobject '@class.outer'
                end,
                mode = { 'x', 'o' },
                desc = 'a of a class',
            },
            {
                'ic',
                function()
                    require "nvim-treesitter-textobjects.select".select_textobject("@class.inner", "textobjects")
                end,
                mode = { 'x', 'o' },
                desc = 'inner part of a class region',
            },
        },
    },
    {
        'nvim-treesitter/nvim-treesitter-context',
        event = "CursorHold",
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
        },
        config = function()
            require 'treesitter-context'.setup {
                enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
                max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
                min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
                line_numbers = true,
                multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
                trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
                mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
                -- Separator between context and content. Should be a single character string, like '-'.
                -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
                separator = '',
                zindex = 20,     -- The Z-index of the context window
                on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
            }

            vim.api.nvim_set_hl(0, "TreesitterContext", { bg = require("common").colors.CustomBorderBg, blend = 0 })
            vim.api.nvim_set_hl(0, "TreesitterContextBottom", { fg = "grey" })
            vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { fg = "grey" })

            vim.keymap.set("n", "[q", function()
                require("treesitter-context").go_to_context(10000)
            end, { silent = true, desc = "Goto contenxt top" })
            vim.keymap.set("n", "[w", function()
                require("treesitter-context").go_to_context()
            end, { silent = true, desc = "Goto contenxt outer" })
        end
    },
    {
        'm-demare/hlargs.nvim',
        lazy = true,
        config = function()
            require('hlargs').setup({
                hl_priority = 1000,
            })
        end
    },
    {
        'mizlan/iswap.nvim',
        keys = {
            { "<leader>ss", "<cmd>ISwapWith<CR>",     { noremap = true, silent = true }, desc = "ISwap" },
            { "<leader>sm", "<cmd>IMoveWith<CR>",     { noremap = true, silent = true }, desc = "ISwap" },
            { "<leader>S",  "<cmd>ISwapNodeWith<CR>", { noremap = true, silent = true }, desc = "ISwapNode" },
        },
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
        },
        opts = {
            -- The keys that will be used as a selection, in order
            -- ('asdfghjklqwertyuiopzxcvbnm' by default)
            keys = 'qwertyuiop',

            -- Grey out the rest of the text when making a selection
            -- (enabled by default)
            grey = "disable",

            -- Highlight group for the sniping value (asdf etc.)
            -- default 'Search'
            hl_snipe = 'ErrorMsg',

            -- Highlight group for the visual selection of terms
            -- default 'Visual'
            hl_selection = 'WarningMsg',

            -- Highlight group for the greyed background
            -- default 'Comment'
            hl_grey = 'LineNr',

            -- Post-operation flashing highlight style,
            -- either 'simultaneous' or 'sequential', or false to disable
            -- default 'sequential'
            flash_style = 'sequential',

            -- Highlight group for flashing highlight afterward
            -- default 'IncSearch'
            hl_flash = 'Substitute',

            -- Move cursor to the other element in ISwap*With commands
            -- default false
            move_cursor = true,

            -- Automatically swap with only two arguments
            -- default nil
            autoswap = true,

            -- Other default options you probably should not change:
            debug = nil,
            hl_grey_priority = '1000',
        }
    },
    {
        'Wansmer/treesj',
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
        },
        keys = {
            { "<leader>j", "<cmd>TSJToggle<CR>", { noremap = true, silent = true }, desc = "TSJoinToggle" },
        },
        config = function()
            require('treesj').setup({
                -- Use default keymaps
                -- (<space>m - toggle, <space>j - join, <space>s - split)
                use_default_keymaps = false,
                -- Node with syntax error will not be formatted
                check_syntax_error = true,
                -- If line after join will be longer than max value,
                -- node will not be formatted
                max_join_length = 10000,
                -- hold|start|end:
                -- hold - cursor follows the node/place on which it was called
                -- start - cursor jumps to the first symbol of the node being formatted
                -- end - cursor jumps to the last symbol of the node being formatted
                cursor_behavior = 'hold',
                -- Notify about possible problems or not
                notify = true,
            })
        end
    }
}
