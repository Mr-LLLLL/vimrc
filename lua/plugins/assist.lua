local km = vim.keymap
local g = vim.g
local api = vim.api

return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            popup_mappings = {
                scroll_down = '<c-f>', -- binding to scroll down inside the popup
                scroll_up = '<c-b>',   -- binding to scroll up inside the popup
            },
            layout = {
                height = { min = 4, max = 25 }, -- min and max height of the columns
                width = { min = 20, max = 50 }, -- min and max width of the columns
                spacing = 3,                    -- spacing between columns
                align = "left",                 -- align columns left, center or right
            },
            window = {
                border = "rounded",       -- none, single, double, shadow
                position = "bottom",      -- bottom, top
                margin = { 1, 0, 1, 0 },  -- extra window margin [top, right, bottom, left]
                padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
                winblend = vim.g.custom_blend
            },
            disable = {
                buftypes = {},
                filetypes = { "TelescopePrompt" },
            },
        }
    },
    {
        'numToStr/Comment.nvim',
        keys = {
            { "<leader>/", nil, mode = { "n", "v" }, desc = "Comment" }
        },
        config = function()
            require('Comment').setup({
                -- -Add a space b/w comment and the line
                padding = true,
                ---Whether the cursor should stay at its position
                sticky = true,
                ---Lines to be ignored while (un)comment
                ignore = nil,
                ---LHS of toggle mappings in NORMAL mode
                toggler = {
                    ---Line-comment toggle keymap
                    line = 'gcc',
                    ---Block-comment toggle keymap
                    block = 'gbc',
                },
                ---LHS of operator-pending mappings in NORMAL and VISUAL mode
                opleader = {
                    ---Line-comment keymap
                    line = 'gc',
                    ---Block-comment keymap
                    block = 'gb',
                },
                ---LHS of extra mappings
                extra = {
                    ---Add comment on the line above
                    above = 'gcO',
                    ---Add comment on the line below
                    below = 'gco',
                    ---Add comment at the end of line
                    eol = 'gcA',
                },
                ---Enable keybindings
                ---NOTE: If given `false` then the plugin won't create any mappings
                mappings = {
                    ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
                    basic = false,
                    ---Extra mapping; `gco`, `gcO`, `gcA`
                    extra = false,
                },
                ---Function to call before (un)comment
                pre_hook = nil,
                ---Function to call after (un)comment
                post_hook = nil,
            })

            -- forbid default mapping, customer my key mapping
            km.set("n", "<leader>/", '<Plug>(comment_toggle_linewise)', { desc = 'Comment toggle linewise' })
            km.set("n",
                "<leader>//",
                function()
                    return api.nvim_get_vvar('count') == 0 and '<Plug>(comment_toggle_linewise_current)'
                        or '<Plug>(comment_toggle_linewise_count)'
                end,
                { expr = true, desc = 'Comment toggle current line' })
            km.set(
                "x",
                "<leader>/",
                '<Plug>(comment_toggle_linewise_visual)',
                { desc = 'Comment toggle linewise (visual)' })
        end
    },
    {
        "folke/todo-comments.nvim",
        event = "VeryLazy",
        config = function()
            require("todo-comments").setup({})

            vim.keymap.set(
                "n",
                "]t",
                function() require("todo-comments").jump_next() end,
                { desc = "Next todo comment" }
            )

            vim.keymap.set(
                "n",
                "[t",
                function() require("todo-comments").jump_prev() end,
                { desc = "Previous todo comment" }
            )
        end
    },
    {
        'tpope/vim-repeat',
        event = "VeryLazy",
    },
    {
        "folke/flash.nvim",
        dev = true,
        event = "VeryLazy",
        opts = {
            use_upper_select_visual_line = true,
            search = {
                multi_window = true,
                wrap = true,
            },
            modes = {
                search = {
                    -- when `true`, flash will be activated during regular search by default.
                    -- You can always toggle when searching with `require("flash").toggle()`
                    enabled = false,
                    highlight = { backdrop = false },
                    jump = { history = true, register = true, nohlsearch = true },
                    search = {
                        -- `forward` will be automatically set to the search direction
                        -- `mode` is always set to `search`
                        -- `incremental` is set to `true` when `incsearch` is enabled
                    },
                },
                char = {
                    enabled = true,
                    highlight = { backdrop = false },
                    multi_line = false,
                },
                treesitter = {
                    labels = "abefhijklmnopqrstuwz",
                    jump = { pos = "range" },
                    search = { incremental = false },
                    label = {
                        before = true,
                        after = true,
                        style = "inline",
                    },
                    highlight = {
                        backdrop = false,
                        matches = false,
                    },
                },
            },
            highlight = {
                backdrop = false,
            },
            label = {
                -- allow uppercase labels
                uppercase = false,
                after = true,
                current = false,
            },
        },
        keys = {
            {
                "/",
                mode = { "n", "o", "x" },
                function()
                    require("flash").jump({
                        search = { multi_window = true },
                    })
                end,
                desc = "Flash"
            },
            {
                "ss",
                mode = { "n", "x", "o" },
                function()
                    require("flash").treesitter()
                end,
                desc =
                "Flash Treesitter Range"
            },
            {
                "S",
                mode = { "n", "o", "x" },
                function() require("flash").treesitter_search() end,
                desc = "Treesitter Search",
            },
            {
                "s[",
                mode = { "n", "x", "o" },
                function()
                    require("flash").treesitter(
                        {
                            labels = "abefhijklmnopqrstuwz",
                            jump = { pos = "start" },
                            search = { incremental = false },
                            label = {
                                before = true,
                                after = false,
                                style = "inline",
                            },
                            highlight = {
                                backdrop = false,
                                matches = false,
                            },
                        }
                    )
                end,
                desc =
                "Flash Treesitter Start"
            },
            {
                "s]",
                mode = { "n", "x", "o" },
                function()
                    require("flash").treesitter(
                        {
                            labels = "abefhijklmnopqrstuwz",
                            jump = { pos = "end" },
                            search = { incremental = false },
                            label = {
                                before = false,
                                after = true,
                                style = "inline",
                            },
                            highlight = {
                                backdrop = false,
                                matches = false,
                            },
                        }
                    )
                end,
                desc =
                "Flash Treesitter End"
            },
            {
                "r",
                mode = "o",
                function() require("flash").remote() end,
                desc =
                "Remote Flash"
            },
            -- {
            --     "<c-s>",
            --     mode = { "c" },
            --     function() require("flash").toggle_current_search() end,
            --     desc = "Toggle Current Flash Search",
            -- },
        },
    },
    {
        'ThePrimeagen/refactoring.nvim',
        dependencies = {
            'nvim-telescope/telescope.nvim',
        },
        keys = {
            { "<leader>rf", nil, mode = { "n", "v" }, desc = "Refactor" }
        },
        config = function()
            require('refactoring').setup({
                -- prompt for return type
                prompt_func_return_type = {
                    go = true,
                    cpp = true,
                    c = true,
                    java = true,
                },
                -- prompt for function parameters
                prompt_func_param_type = {
                    go = true,
                    cpp = true,
                    c = true,
                    java = true,
                },
            })

            -- remap to open the Telescope refactoring menu in visual mode
            km.set(
                { 'v', 'n' },
                "<leader>rf",
                "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>",
                { noremap = true }
            )

            require("telescope").load_extension("refactoring")
        end
    },
    {
        'Abstract-IDE/penvim',
        event = "VeryLazy",
        config = function()
            require("penvim").setup({
                rooter = {
                    enable = true, -- enable/disable rooter
                    patterns = { '.git' }
                },
                indentor = {
                    enable = false,    -- enable/disable indentor
                    indent_length = 4, -- tab indent width
                    accuracy = 5,      -- positive integer. higher the number, the more accurate result (but affects the startup time)
                    disable_types = {
                        'help', 'dashboard', 'dashpreview', 'NvimTree', 'vista', 'sagahover', 'terminal',
                    },
                },
                project_env = {
                    enable = false,               -- enable/disable project_env
                    config_name = '.__nvim__.lua' -- config file name
                },
            })
        end
    },
    {
        'Mr-LLLLL/treesitter-outer',
        ft = { "lua", "python" },
        opts = {
            filetypes = { "lua", "python" }
        },
    },
    {
        "danymat/neogen",
        version = "*",
        cmd = "Neogen",
        dependencies = "nvim-treesitter/nvim-treesitter",
        config = function()
            require('neogen').setup {
                snippet_engine = "luasnip"
            }
        end,
    },
    {
        'monaqa/dial.nvim',
        keys = {
            {
                "<c-a>",
                function()
                    require("dial.map").manipulate("increment", "normal")
                end,
                desc = "Increment",
                mode = { "n" }
            },
            {
                "<c-x>",
                function()
                    require("dial.map").manipulate("decrement", "normal")
                end,
                desc = "Decrement",
                mode = { "n" }
            },
            {
                "g<c-a>",
                function()
                    require("dial.map").manipulate("increment", "gnormal")
                end,
                desc = "Increment",
                mode = { "n" }
            },
            {
                "g<c-x>",
                function()
                    require("dial.map").manipulate("decrement", "gnormal")
                end,
                desc = "Decrement",
                mode = { "n" }
            },
            {
                "<c-a>",
                function()
                    require("dial.map").manipulate("increment", "visual")
                end,
                desc = "Increment",
                mode = { "v" }
            },
            {
                "<c-x>",
                function()
                    require("dial.map").manipulate("decrement", "visual")
                end,
                desc = "Decrement",
                mode = { "v" }
            },
            {
                "g<c-a>",
                function()
                    require("dial.map").manipulate("increment", "gvisual")
                end,
                desc = "Increment",
                mode = { "v" }
            },
            {
                "g<c-x>",
                function()
                    require("dial.map").manipulate("decrement", "gvisual")
                end,
                desc = "Decrement",
                mode = { "v" }
            },
        },
        config = function()
            local augend = require("dial.augend")
            require("dial.config").augends:register_group {
                default = {
                    augend.constant.new {
                        elements = { "and", "or" },
                        word = true,   -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
                        cyclic = true, -- "or" is incremented into "and".
                    },
                    augend.constant.new {
                        elements = { "&&", "||" },
                        word = false,
                        cyclic = true,
                    },
                    -- uppercase hex number (0x1A1A, 0xEEFE, etc.)
                    augend.hexcolor.new {
                        case = "lower",
                    },
                    -- uppercase hex number (0x1A1A, 0xEEFE, etc.)
                    augend.user.new {
                        find = require("dial.augend.common").find_pattern("%d+"),
                        add = function(text, addend, cursor)
                            local n = tonumber(text)
                            n = math.floor(n * (2 ^ addend))
                            text = tostring(n)
                            cursor = #text
                            return { text = text, cursor = cursor }
                        end
                    },
                    augend.integer.alias.decimal,
                    augend.integer.alias.decimal_int,
                    augend.integer.alias.hex,
                    augend.integer.alias.octal,
                    augend.integer.alias.binary,
                    augend.date.alias["%Y/%m/%d"],
                    augend.date.alias["%m/%d/%Y"],
                    augend.date.alias["%d/%m/%Y"],
                    augend.date.alias["%m/%d/%y"],
                    augend.date.alias["%d/%m/%y"],
                    augend.date.alias["%m/%d"],
                    augend.date.alias["%-m/%-d"],
                    augend.date.alias["%Y-%m-%d"],
                    augend.date.alias["%d.%m.%Y"],
                    augend.date.alias["%d.%m.%y"],
                    augend.date.alias["%d.%m."],
                    augend.date.alias["%-d.%-m."],
                    augend.date.alias["%Y年%-m月%-d日"],
                    augend.date.alias["%Y年%-m月%-d日(%ja)"],
                    augend.date.alias["%H:%M:%S"],
                    augend.date.alias["%H:%M"],
                    augend.constant.alias.de_weekday,
                    augend.constant.alias.de_weekday_full,
                    augend.constant.alias.ja_weekday,
                    augend.constant.alias.ja_weekday_full,
                    augend.constant.alias.bool,
                    augend.constant.alias.alpha,
                    augend.constant.alias.Alpha,
                    augend.semver.alias.semver,
                },
            }
        end,
    },
    {
        'sbdchd/neoformat',
        cmd = "NeoFormat",
        config = function()
            g.neoformat_only_msg_on_error = 1
            g.neoformat_basic_format_align = 1
            g.neoformat_basic_format_retab = 1
            g.neoformat_basic_format_trim = 1

            g.neoformat_enabled_json = { "jq" }
        end
    }
}
