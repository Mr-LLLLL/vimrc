return {
    {
        'milanglacier/minuet-ai.nvim',
        lazy = true,
        dependencies = {
            { 'nvim-lua/plenary.nvim' },
        },
        config = function()
            require('minuet').setup({
                notify = "error",
                provider = "openai_fim_compatible",
                provider_options = {
                    openai_fim_compatible = {
                        model = 'deepseek-coder',
                        end_point = 'https://api.deepseek.com/beta/completions',
                        name = 'Deepseek',
                        api_key = "OPENAI_API_KEY",
                        stream = true,
                        optional = {
                            stop = nil,
                            max_tokens = nil,
                        },
                    },
                },
            })
        end
    },
    {
        "olimorris/codecompanion.nvim",
        enabled = true,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        event = "VeryLazy",
        keys = {
            {
                "<space>/",
                "<cmd>CodeCompanionChat Toggle<cr>",
                mode = { "n", "v" },
                { noremap = true, silent = true },
                desc = "CodeCompanion Toggle"
            },
            {
                "<leader>aa",
                ":CodeCompanion ",
                mode = { "n", "v" },
                { noremap = true, silent = true },
                desc = "CodeCompanion"
            },
            {
                "<leader>ac",
                ":CodeCompanionCmd ",
                mode = { "n" },
                { noremap = true, silent = true },
                desc = "CodeCompanion Commands"
            },
            {
                "<leader>ap",
                "<cmd>CodeCompanionChat Add<cr>",
                mode = { "v" },
                { noremap = true, silent = true },
                desc = "CodeCompanionChat Add"
            },
        },
        config = function()
            require("codecompanion").setup({
                opts = {
                    language = "English" -- Default is "English"
                },

                display = {
                    action_palette = {
                        width = 95,
                        height = 10,
                        prompt = "Prompt ",                     -- Prompt used for interactive LLM calls
                        provider = "telescope",                 -- default|telescope|mini_pick
                        opts = {
                            show_default_actions = true,        -- Show the default actions in the action palette?
                            show_default_prompt_library = true, -- Show the default prompt library in the action palette?
                        },
                    },
                    chat = {
                        window = {
                            layout = "vertical", -- float|vertical|horizontal|buffer
                            position = "right",  -- left|right|top|bottom (nil will default depending on vim.opt.splitright|vim.opt.splitbelow)
                            border = "rounded",
                        },
                    }
                },
                strategies = {
                    inline = {
                        adapter = "deepseek",
                        keymaps = {
                            accept_change = {
                                modes = {
                                    n = "ct",
                                },
                                index = 1,
                                callback = "keymaps.accept_change",
                                description = "Accept change",
                            },
                            reject_change = {
                                modes = {
                                    n = "co",
                                },
                                index = 2,
                                callback = "keymaps.reject_change",
                                description = "Reject change",
                            },
                        },
                    },
                    cmd = {
                        adapter = "deepseek",
                    },
                    chat = {
                        adapter = "deepseek",
                        keymaps = {
                            options = {
                                modes = {
                                    n = "g?",
                                },
                                callback = "keymaps.options",
                                description = "Options",
                                hide = true,
                            },
                            close = {
                                modes = {
                                    n = { "<C-q>" },
                                    i = "<C-q>",
                                },
                                index = 4,
                                callback = "keymaps.close",
                                description = "Close Chat",
                            },
                            send = {
                                modes = {
                                    n = { "<cr>" },
                                    i = "<C-cr>",
                                },
                                index = 2,
                                callback = "keymaps.send",
                                description = "Send",
                            },
                            stop = {
                                modes = {
                                    n = "s",
                                    i = "<c-s>",
                                },
                                index = 5,
                                callback = "keymaps.stop",
                                description = "Stop Request",
                            },
                        }
                    }
                },
                adapters = {
                    ollama = function()
                        return require("codecompanion.adapters").extend("ollama", {
                            env = {
                                url = "http://127.0.0.1:11434",
                                api_key = "",
                            },
                            schema = {
                                model = {
                                    default = "llama3.1",
                                }
                            },
                            parameters = {
                                sync = true,
                            },
                        })
                    end,
                    deepseek = function()
                        return require("codecompanion.adapters").extend("openai_compatible", {
                            env = {
                                url = "https://api.deepseek.com",
                                api_key = "OPENAI_API_KEY",
                                caht_url = "/chat/completions",
                            },
                            schema = {
                                model = {
                                    default = "deepseek-coder",
                                }
                            },
                            headers = {
                                ["Content-Type"] = "application/json",
                                ["Authorization"] = "Bearer ${api_key}",
                            },
                            parameters = {
                                sync = true,
                            },
                        })
                    end,
                },
            })

            local tmp = {
                processing = false,
                spinner_index = 1,
                spinner_symbols = {
                    "⠋",
                    "⠙",
                    "⠹",
                    "⠸",
                    "⠼",
                    "⠴",
                    "⠦",
                    "⠧",
                    "⠇",
                    "⠏",
                }
            }


            local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})
            vim.api.nvim_create_autocmd({ "User" }, {
                pattern = "CodeCompanionRequest*",
                group = group,
                callback = function(request)
                    if request.match == "CodeCompanionRequestStarted" then
                        tmp.processing = true
                    elseif request.match == "CodeCompanionRequestFinished" then
                        tmp.processing = false
                    end
                end,
            })

            -- Function that runs every time statusline is updated
            local get_info = function()
                if tmp.processing then
                    tmp.spinner_index = (tmp.spinner_index % 10) + 1
                    return tmp.spinner_symbols[tmp.spinner_index]
                else
                    return nil
                end
            end

            local old = require("lualine").get_config()
            table.insert(old.sections.lualine_x, #old.sections.lualine_x, {
                get_info,
                cond = function() return tmp.processing end,
                color = { fg = "#cf9f7f" },
            })
            require("lualine").setup(old)

            vim.api.nvim_create_autocmd(
                { "Filetype" },
                {
                    pattern = { "codecompanion" },
                    callback = function(opts)
                        vim.keymap.set({ 'i', 'n' }, "<c-c>", function()
                            -- in case occur error
                            require('blink.cmp.completion.list').hide()
                            vim.cmd("stopinsert")
                            vim.cmd("CodeCompanionChat Toggle")
                        end, { noremap = true, silent = true, buffer = opts.buf })
                    end,
                    group = group,
                }
            )
        end
    },
    {
        "yetone/avante.nvim",
        enabled = false,
        event = "VeryLazy",
        keys = {
            {
                "<space>/",
                function()
                    require("avante").toggle()
                end,
                mode = { "n" },
                { noremap = true, silent = true },
                desc = "Avante Toggle"
            },
        },
        version = false, -- set this to "*" if you want to always pull the latest change, false to update on release
        build = "make",
        dependencies = {
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
            'MeanderingProgrammer/render-markdown.nvim',
        },
        config = function()
            require('avante').setup({
                -- provider = "ollama",
                provider = "openai",
                auto_suggestions_provider = "openai", -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
                openai = {
                    endpoint = "https://api.deepseek.com/v1",
                    model = "deepseek-coder",
                    timeout = 30000, -- Timeout in milliseconds
                    temperature = 0,
                    max_tokens = 4096,
                },
                vendors = {
                    ollama = {
                        __inherited_from = "openai",
                        api_key_name = "",
                        endpoint = "http://127.0.0.1:11434/v1",
                        model = "llama3.1",
                    },
                },
                behaviour = {
                    auto_suggestions = false, -- Experimental stage
                    auto_set_highlight_group = true,
                    auto_set_keymaps = true,
                    auto_apply_diff_after_generation = false,
                    support_paste_from_clipboard = false,
                    minimize_diff = true,
                },
                mappings = {
                    --- @class AvanteConflictMappings
                    diff = {
                        ours = "co",
                        theirs = "ct",
                        all_theirs = "ca",
                        both = "cb",
                        cursor = "cc",
                        next = "]x",
                        prev = "[x",
                    },
                    suggestion = {
                        accept = "<c-y>",
                        next = "<M-]>",
                        prev = "<M-[>",
                        dismiss = "<C-]>",
                    },
                    jump = {
                        next = "]]",
                        prev = "[[",
                    },
                    submit = {
                        normal = "<CR>",
                        insert = "<C-CR>",
                    },
                    ask = "<leader>aa",
                    edit = "<leader>ae",
                    refresh = "<leader>ar",
                    focus = "<leader>af",
                    toggle = {
                        default = "<space>/",
                        debug = "<leader>ad",
                        hint = "<leader>ah",
                        suggestion = "<leader>as",
                        repomap = "<leader>aR",
                    },
                    sidebar = {
                        apply_all = "A",
                        apply_cursor = "a",
                        switch_windows = "<Tab>",
                        reverse_switch_windows = "<S-Tab>",
                    },
                    files = {
                        add_current = "<leader>ac", -- Add current buffer to selected files
                    },
                },
                windows = {
                    ask = {
                        floating = true,         -- Open the 'AvanteAsk' prompt in a floating window
                        border = "rounded",
                        start_insert = true,     -- Start insert mode when opening the ask window
                        ---@alias AvanteInitialDiff "ours" | "theirs"
                        focus_on_apply = "ours", -- which diff to focus after applying
                    },
                }

            })

            vim.api.nvim_set_hl(0, "AvanteInlineHint", { link = 'NonText' })
            vim.api.nvim_create_autocmd(
                { "Filetype" },
                {
                    pattern = { "AvanteInput", "Avante" },
                    callback = function(opts)
                        vim.keymap.set('i', "<c-c>", function()
                            -- in case occur error
                            require('blink.cmp.completion.list').hide()
                            vim.cmd("stopinsert")
                            require("avante").toggle()
                        end, { noremap = true, silent = true, buffer = opts.buf })
                    end,
                    group = vim.api.nvim_create_augroup("AvanteAutocmd", { clear = true }),
                }
            )
        end
    },
    -- {
    --     "sourcegraph/sg.nvim",
    --     cmd = { "Cody", "Sourcegraph" },
    --     dependencies = { "nvim-lua/plenary.nvim", --[[ "nvim-telescope/telescope.nvim ]] },
    --     config = function()
    --         require("sg").setup {
    --             on_attach = require("common").lsp_on_attach,
    --         }
    --     end
    -- },
    {
        "Exafunction/codeium.nvim",
        enabled = false,
        lazy = true,
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("codeium").setup({
                enable_cmp_source = true,
                virtual_text = {
                    enabled = false,
                    -- filetypes = true,
                    manual = false,
                    -- map_keys = false,
                    key_bindings = {
                        -- Accept the current completion.
                        accept = "<c-y>",
                        -- Accept the next word.
                        accept_word = "<a-y>",
                        -- Accept the next line.
                        accept_line = false,
                        -- Clear the virtual text.
                        clear = "<c-]>",
                        -- Cycle to the next completion.
                        next = "<M-]>",
                        -- Cycle to the previous completion.
                        prev = "<M-[>",
                    }
                },

            })

            vim.api.nvim_set_hl(0, "CodeiumSuggestion", { link = 'NonText' })
        end
    },
    {
        "supermaven-inc/supermaven-nvim",
        lazy = true,
        enabled = true,
        config = function()
            require("supermaven-nvim").setup({
                disable_inline_completion = true,
                disable_keymaps = true,
                keymaps = {
                    accept_suggestion = "<c-y>",
                    clear_suggestion = "<C-]>",
                    accept_word = "<A-y>",
                },
            })
        end,
    },
}
