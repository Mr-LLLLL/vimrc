local km = vim.keymap
local g = vim.g

return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "helix",
            keys = {
                scroll_down = '<c-n>', -- binding to scroll down inside the popup
                scroll_up = '<c-p>',   -- binding to scroll up inside the popup
            },
            layout = {
                width = { min = 20, max = 50 }, -- min and max width of the columns
                spacing = 3,                    -- spacing between columns
                align = "left",                 -- align columns left, center or right
            },
            win = {
                -- border = "rounded", -- none, single, double, shadow
                padding = { 2, 2 }, -- extra window padding [top, right, bottom, left]
                wo = {
                    winblend = vim.g.custom_blend
                }
            },
            disable = {
                buftypes = {},
                filetypes = { "TelescopePrompt" },
            },
        }
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

            require("telescope").load_extension("todo-comments")
        end
    },
    {
        'tpope/vim-repeat',
        event = "VeryLazy",
    },
    {
        "Mr-LLLLL/flash.nvim",
        event = "VeryLazy",
        branch = "dev",
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
    -- {
    --     "danymat/neogen",
    --     version = "*",
    --     cmd = "Neogen",
    --     dependencies = "nvim-treesitter/nvim-treesitter",
    --     config = function()
    --         require('neogen').setup {
    --             snippet_engine = "nvim"
    --         }
    --     end,
    -- },
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
    },
    {
        'Mr-LLLLL/utilities.nvim',
        event = "VeryLazy",
        opts = {
            -- always use `q` to quit preview windows
            quit_with_q = true,

            no_match_paren_in_insert_mode = false,
            -- in qf window, use <cr> jump to
            jump_quickfix_item = true,
            -- define some useful keymap for generic. details see init_keymap function
            map_with_useful = true,
            -- when hit <ctrl-t> will pop stack and centerize
            -- if want to centerize for jump definition, implementation, references, you can used like:
            -- ``` lua
            -- vim.keymap.set('n', '<c-]>', function() require("utilities.nvim").list_or_jump("textDocument/definition", require("telescope.builtin").lsp_definitions) end, {})
            -- ```
            -- but this is need telescope when result is greater one
            ctrl_t_with_center = true,

            auto_change_cwd_to_project = true,

            auto_change_conceallevel = true,

            auto_disable_inlayhint = true,

            smart_move_textobj = {
                disabled = false,
                -- disabled filetype, default support all language just like treesitter-textobj behavior
                -- disabled_filetypes = { "git" },
                -- if you want to support some filetypes, uncomment it and fill your language
                -- enabled_filetypes = {},
                mapping = {
                    prev_func_start = "[[",
                    next_func_start = "]]",
                    prev_func_end = "[]",
                    next_func_end = "][",

                    prev_class_start = "[m",
                    next_class_start = "]m",
                    prev_class_end = "[M",
                    next_class_end = "]M",
                }
            }
        }
    },
    {
        "cshuaimin/ssr.nvim",
        module = "ssr",
        keys = {
            { "sr", function() require("ssr").open() end, mode = { "n", "x" }, desc = "Structural Search And Replace" }
        },
        -- Calling setup is optional.
        config = function()
            require("ssr").setup {
                border = "rounded",
                min_width = 50,
                min_height = 5,
                max_width = 120,
                max_height = 25,
                adjust_window = true,
                keymaps = {
                    close = "q",
                    next_match = "n",
                    prev_match = "N",
                    replace_confirm = "<leader>r",
                    replace_all = "<leader>R",
                },
            }
            vim.keymap.set({ "n", "x" }, "sr", function() require("ssr").open() end)
        end
    },
    {
        -- "ThePrimeagen/harpoon",
        "Mr-LLLLL/harpoon",
        -- keep use this commit.after the commit will be bug cause can't save marks to fs
        branch = 'dev',
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
        keys = {
            {
                "<space>sm",
                require("common").get_tele_harpoon,
                { noremap = true, silent = true, },
                desc = "Telescope harpoon marks",
            },
            {
                "<leader>f",
                function()
                    require("harpoon"):list():add()
                end,
                { noremap = true, silent = true },
                desc = "Add file to harpoon"
            }
        },
        config = function()
            local harpoon = require("harpoon")
            -- local extensions = require("harpoon.extensions");

            harpoon:setup({
                settings = {
                    save_on_toggle = true,
                    sync_on_ui_close = true,
                    key = function()
                        local root = vim.fs.root(vim.loop.cwd(), { ".git", ".svn", "Makefile", "mvnw" })
                        if root and root ~= "." then
                            return root
                        end
                        return vim.loop.cwd()
                    end
                },
                default = {
                    get_root_dir = function()
                        local root = vim.fs.root(vim.loop.cwd(), { ".git", ".svn", "Makefile", "mvnw" })
                        if root and root ~= "." then
                            return root
                        end
                        return vim.loop.cwd()
                    end,
                }
            })

            require("lualine-ext").init_harpoon()
            require("telescope").load_extension('harpoon')
        end
    },
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        keys = {
            {
                "<a-n>",
                mode = { "n", "o", "x" },
                function()
                    Snacks.words.jump(1, true)
                end,
                desc = "Jump To Next Word"
            },
            {
                "<a-p>",
                mode = { "n", "o", "x" },
                function()
                    Snacks.words.jump(-1, true)
                end,
                desc = "Jump To Previous Word"
            },
            { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse",            mode = { "n", "v" } },

            { "<a-f>",      function() Snacks.scratch() end,   desc = "Toggle Scratch Buffer", mode = { "n", "i" } },
        },
        config = function()
            local snacks = require("snacks")
            snacks.setup({
                -- your configurasdftion comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
                bigfile = { enabled = true },
                quickfile = { enabled = true },
                statuscolumn = { enabled = false },
                notifier = { enabled = false },
                words = {
                    enabled = true,
                    modes = { "n", "v" }, -- modes to show references
                },
                scratch = {
                    enabled = true,
                    win = {
                        keys = {
                            { "<c-s>",   function() vim.cmd("%d") end,           mode = { "n", "i", "v" }, desc = "Clear" },
                            { "q",       "close",                                mode = "n",               desc = "<Close>" },
                            { "<space>", function() Snacks.scratch.select() end, mode = "n",               desc = "Select Scratch Buffer" },
                            {
                                "<a-f>",
                                function()
                                    vim.cmd("stopinsert")
                                    vim.cmd("close")
                                end,
                                mode = { "n", "i", "v" },
                                desc = "<Close>"
                            },
                        }
                    },
                },
                dashboard = { enabled = false },
                gitbrowse = {
                    enabled = true,
                    ---@type "repo" | "branch" | "file" | "commit"
                    what = "file", -- what to open. not all remotes support all types
                },
                input = { enabled = false },
                styles = {
                    scratch = {
                        width = 0.8,
                        height = 0.8,
                        backdrop = 100,
                        bo = { buftype = "", buflisted = false, bufhidden = "hide", swapfile = false },
                        minimal = false,
                        noautocmd = false,
                        -- position = "right",
                        zindex = 20,
                        wo = { winhighlight = "NormalFloat:NormalFloat" },
                        border = "rounded",
                        title_pos = "center",
                        footer_pos = "center",
                    }

                }
            })
        end,
    }
}
