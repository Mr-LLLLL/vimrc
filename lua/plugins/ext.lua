local km = vim.keymap
local g = vim.g

return {
    {
        "vinnymeller/swagger-preview.nvim",
        cmd = "SwaggerPreview",
        build = "npm install --localtion=global swagger-ui-watcher",
        config = function()
            require("swagger-preview").setup({
                -- The port to run the preview server on
                port = 8000,
                -- The host to run the preview server on
                host = "0.0.0.0",
            })
        end
    },
    {
        'dpayne/CodeGPT.nvim',
        cmd = "Chat",
        config = function()
            require("codegpt.config")

            -- Override the default chat completions url, this is useful to override when testing custom commands
            -- vim.g["codegpt_chat_completions_url"] = "http://127.0.0.1:800/test"

            vim.g["codegpt_commands"] = {
                ["tests"] = {
                    -- Language specific instructions for java filetype
                    language_instructions = {
                        java = "Use the TestNG framework.",
                    },
                },
                ["doc"] = {
                    -- Language specific instructions for python filetype
                    language_instructions = {
                        python = "Use the Google style docstrings."
                    },

                    -- Overrides the max tokens to be 1024
                    max_tokens = 1024,
                },
                ["code_edit"] = {
                    -- Overrides the system message template
                    system_message_template = "You are {{language}} developer.",

                    -- Overrides the user message template
                    user_message_template =
                    "I have the following {{language}} code: ```{{filetype}}\n{{text_selection}}```\nEdit the above code. {{language_instructions}}",

                    -- Display the response in a popup window. The popup window filetype will be the filetype of the current buffer.
                    callback_type = "code_popup",
                },
                -- Custom command
                ["modernize"] = {
                    user_message_template =
                    "I have the following {{language}} code: ```{{filetype}}\n{{text_selection}}```\nModernize the above code. Use current best practices. Only return the code snippet and comments. {{language_instructions}}",
                    language_instructions = {
                        cpp =
                        "Use modern C++ syntax. Use auto where possible. Do not import std. Use trailing return type. Use the c++11, c++14, c++17, and c++20 standards where applicable.",
                    },
                }
            }
        end
    },
    {
        'uga-rosa/ccc.nvim',
        cmd = "CccHighlighterEnable",
        config = function()
            require('ccc').setup({
                highlighter = {
                    auto_enable = false,
                    lsp = true,
                },
            })
        end
    },
    {
        'iamcco/markdown-preview.nvim',
        ft = "markdown",
        build = 'cd app && ./install.sh'
    },
    {
        'potamides/pantran.nvim',
        keys = {
            { "<space>t", nil, mode = { "n", "v" } }
        },
        config = function()
            local pantran_actions = require("pantran.ui.actions")
            require("pantran").setup {
                -- Default engine to use for translation. To list valid engine names run
                -- `:lua =vim.tbl_keys(require("pantran.engines"))`.
                default_engine = "google",
                -- Configuration for individual engines goes here.
                window = {
                    window_config = {
                        border = "rounded"
                    },
                },
                engines = {
                    google = {
                        -- Default languages can be defined on a per engine basis. In this case
                        -- `:lua vim.pretty_print(require("pantran.engines").google:languages())
                        default_source = "auto",
                        default_target = "zh-CN",
                        fallback = {
                            default_source = "auto",
                            default_target = "zh-CN",
                        }
                    },
                },
                controls = {
                    mappings = {
                        edit = {
                            n = {
                                -- Use this table to add additional mappings for the normal mode in
                                -- the translation window. Either strings or function references are
                                -- supported.
                                ["q"] = pantran_actions.close,
                                ["<C-a>"] = pantran_actions.append_close_translation,
                                ["<C-r>"] = pantran_actions.replace_close_translation,
                                ["<C-s>"] = pantran_actions.select_source,
                                ["<C-t>"] = pantran_actions.select_target,
                                ["<C-e>"] = pantran_actions.select_engine,
                            },
                            i = {
                                -- Similar table but for insert mode. Using 'false' disables
                                -- existing keybindings.
                                ["<esc>"] = function(ui)
                                    pantran_actions.close(ui)
                                    vim.cmd("stopinsert")
                                end,
                                ["<c-o>"] = function()
                                    vim.cmd("stopinsert")
                                end,
                                ["<C-r>"] = pantran_actions.replace_close_translation,
                                ["<C-a>"] = pantran_actions.append_close_translation,
                                ["<C-s>"] = pantran_actions.select_source,
                                ["<C-t>"] = pantran_actions.select_target,
                                ["<C-e>"] = pantran_actions.select_engine,
                            }
                        },
                        -- Keybindings here are used in the selection window.
                        select = {
                            i = {
                                ["<C-s>"] = pantran_actions.select_source,
                                ["<C-t>"] = pantran_actions.select_target,
                                ["<C-e>"] = pantran_actions.select_engine,
                            },
                            n = {
                                ["<C-s>"] = pantran_actions.select_source,
                                ["<C-t>"] = pantran_actions.select_target,
                                ["<C-e>"] = pantran_actions.select_engine,
                            }
                        }
                    }
                },
            }

            vim.api.nvim_set_hl(0, "PantranBorder", { link = 'CustomBorder' })
            km.set('n', "<space>to", "<cmd>Pantran<CR>i", { noremap = true, silent = true, desc = "pantran panel" })
            km.set("n", "<space>tt", function() return require("pantran").motion_translate() .. "iw" end,
                { noremap = true, silent = true, expr = true, desc = "pantran translate" })
            km.set("x", "<space>tt", require("pantran").motion_translate,
                { noremap = true, silent = true, expr = true, desc = "pantran translate" })
        end
    },
    {
        'voldikss/vim-browser-search',
        keys = {
            { "<space>o", "<Plug>SearchVisual", { noremap = true, silent = true }, mode = "v" },
            { "<space>o", "<Plug>SearchNormal", { noremap = true, silent = true }, mode = "n" },
        },
    },
    {
        'rest-nvim/rest.nvim',
        ft = "http",
        config = function()
            require("rest-nvim").setup({
                -- Open request results in a horizontal split
                result_split_horizontal = false,
                -- Keep the http file buffer above|left when split horizontal|vertical
                result_split_in_place = false,
                -- Skip SSL verification, useful for unknown certificates
                skip_ssl_verification = true,
                -- Encode URL before making request
                encode_url = false,
                -- Highlight request on run
                highlight = {
                    enabled = true,
                    timeout = 150,
                },
                result = {
                    -- toggle showing URL, HTTP info, headers at top the of result window
                    show_url = true,
                    show_http_info = true,
                    show_headers = true,
                    -- executables or functions for formatting response body [optional]
                    -- set them to nil if you want to disable them
                    formatters = {
                        json = "jq",
                        html = function(body)
                            return vim.fn.system({ "tidy", "-i", "-q", "-" }, body)
                        end
                    },
                },
                -- Jump to request line on run
                jump_to_request = false,
                env_file = '.env',
                custom_dynamic_variables = {},
                yank_dry_run = true,
            })

            km.set('n', "<leader>cc", "<Plug>RestNvim", { noremap = true, silent = true })
            km.set('n', "<leader>cp", "<Plug>RestNvimPreview", { noremap = true, silent = true })
        end
    },
    {
        'kristijanhusak/vim-dadbod-ui',
        cmd = "DBUI",
        dependencies = {
            'tpope/vim-dadbod',
        },
        init = function()
            g.db_ui_show_database_icon = 1
            g.db_ui_use_nerd_fonts = 1
            g.vim_dadbod_completion_mark = ''
        end,
        config = function()
            local cmp = require("cmp")
            cmp.setup.filetype({ 'mysql', 'sql', 'plsql' }, {
                sources = cmp.config.sources({
                    { name = 'vim-dadbod-completion' }, -- You can specify the `cmp_git` source if you were installed it.
                }, {
                    { name = 'buffer' },
                })
            })

            require("private.private").setup()
        end
    },
    {
        'renerocksai/calendar-vim',
        cmd = "Calendar"
    }
}
