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
            { "<space>t", nil, mode = { "n", "v" }, desc = "Pantran" }
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
            { "<space>o", "<Plug>SearchVisual", { noremap = true, silent = true }, mode = "v", desc = "BrowserSearch" },
            { "<space>o", "<Plug>SearchNormal", { noremap = true, silent = true }, mode = "n", desc = "BrowserSearch" },
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
    },
    {
        'eandrju/cellular-automaton.nvim',
        cmd = "CellularAutomaton",
    },
    {
        'windwp/nvim-spectre',
        cmd = "Spectre",
        opts = {
            live_update = true, -- auto execute search again when you write any file in vim
        }
    },
    {
        '3rd/image.nvim',
        enabled = false,
        config = function()
            require("image").setup({
                backend = "ueberzug",
                integrations = {
                    markdown = {
                        enabled = true,
                        clear_in_insert_mode = false,
                        download_remote_images = true,
                        only_render_image_at_cursor = false,
                        filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
                    },
                    neorg = {
                        enabled = true,
                        clear_in_insert_mode = false,
                        download_remote_images = true,
                        only_render_image_at_cursor = false,
                        filetypes = { "norg" },
                    },
                },
                max_width = nil,
                max_height = nil,
                max_width_window_percentage = nil,
                max_height_window_percentage = 50,
                window_overlap_clear_enabled = false,                                     -- toggles images when windows are overlapped
                window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
                editor_only_render_when_focused = false,                                  -- auto show/hide images when the editor gains/looses focus
                tmux_show_only_in_active_window = false,                                  -- auto show/hide images in the correct Tmux window (needs visual-activity off)
                hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" }, -- render image files as images when opened
            })
        end
    },
}
