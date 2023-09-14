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
        event = "VeryLazy",
        build = ':TSUpdate',
        dependencies = {
            'p00f/nvim-ts-rainbow',
            'm-demare/hlargs.nvim',
        },
        config = function()
            local parsers = require("nvim-treesitter.parsers")
            local rainbow_enabled_list = { "json" }

            require('nvim-treesitter.configs').setup({
                ensure_installed = "all",
                ignore_install = {},
                highlight = {
                    enable = true,
                    disable = function(lang, buf)
                        local max_filesize = 10 * 1024 -- 100 KB
                        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                        if ok and stats and stats.size > max_filesize then
                            return true
                        end
                    end,
                    additional_vim_regex_highlighting = false
                },
                rainbow = {
                    enable = true,
                    disable = vim.tbl_filter(
                        function(p)
                            local disable = true
                            for _, lang in pairs(rainbow_enabled_list) do
                                if p == lang then disable = false end
                            end
                            return disable
                        end,
                        parsers.available_parsers()
                    ),
                    extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
                    max_file_lines = nil, -- Do not enable for files with more than n lines, int
                    -- colors = {}, -- table of hex strings
                    -- termcolors = {} -- table of colour name strings
                },
                indent = {
                    enable = true
                },
                textobjects = {
                    select = {
                        enable = true,
                        -- Automatically jump forward to textobj, similar to targets.vim
                        lookahead = true,
                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            -- You can optionally set descriptions to the mappings (used in the desc parameter of
                            -- nvim_buf_set_keymap) which plugins like which-key display
                            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
                        },
                        -- You can choose the select mode (default is charwise 'v')
                        --
                        -- Can also be a function which gets passed a table with the keys
                        -- * query_string: eg '@function.inner'
                        -- * method: eg 'v' or 'o'
                        -- and should return the mode ('v', 'V', or '<c-v>') or a table
                        -- mapping query_strings to modes.
                        selection_modes = {
                            ['@parameter.outer'] = 'v', -- charwise
                            ['@function.outer'] = 'V',  -- linewise
                            ['@class.outer'] = '<c-v>', -- blockwise
                        },
                        -- If you set this to `true` (default is `false`) then any textobject is
                        -- extended to include preceding or succeeding whitespace. Succeeding
                        -- whitespace has priority in order to act similarly to eg the built-in
                        -- `ap`.
                        --
                        -- Can also be a function which gets passed a table with the keys
                        -- * query_string: eg '@function.inner'
                        -- * selection_mode: eg 'v'
                        -- and should return true of false
                        include_surrounding_whitespace = true,
                    },
                    move = {
                        enable = true,
                        set_jumps = true, -- whether to set jumps in the jumplist
                        goto_next_start = {
                            ["]]"] = "@function.outer",
                            ["]m"] = { query = "@class.outer", desc = "Next class start" },
                        },
                        goto_next_end = {
                            ["]["] = "@function.outer",
                            ["]M"] = "@class.outer",
                        },
                        goto_previous_start = {
                            ["[["] = "@function.outer",
                            ["[m"] = "@class.outer",
                        },
                        goto_previous_end = {
                            ["[]"] = "@function.outer",
                            ["[M"] = "@class.outer",
                        },
                    },
                    -- swap = {
                    --     enable = false,
                    --     swap_next = {
                    --         ["<leader>s"] = "@parameter.inner",
                    --     },
                    --     swap_previous = {
                    --         ["<leader>S"] = "@parameter.inner",
                    --     },
                    -- },
                    -- NOTE: with neovim builtin lsp
                    -- lsp_interop = {
                    --     enable = true,
                    --     border = 'none',
                    --     floating_preview_opts = {},
                    --     peek_definition_code = {
                    --         ["<leader>x"] = "@function.outer",
                    --     },
                    -- },
                },
                endwise = {
                    enable = true,
                },
            })
        end
    },
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        event = "CursorHold",
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
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
                separator = '-',
                zindex = 20,     -- The Z-index of the context window
                on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
            }

            if vim.g.colors_name == 'gruvbox-material' then
                vim.api.nvim_set_hl(0, "TreesitterContext", { bg = '#282828', blend = 0 })
            elseif vim.g.colors_name == 'everforest' then
                vim.api.nvim_set_hl(0, "TreesitterContext", { bg = '#2d353b', blend = 0 })
            end
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
            { "<leader>s", "<cmd>ISwapWith<CR>",     { noremap = true, silent = true } },
            { "<leader>S", "<cmd>ISwapNodeWith<CR>", { noremap = true, silent = true } },
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
            { "<leader>j", "<cmd>TSJToggle<CR>", { noremap = true, silent = true } },
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
