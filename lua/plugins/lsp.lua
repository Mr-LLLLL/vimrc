local api = vim.api
local km = vim.keymap

local m = {}

local function load_saga_keymap()
    -- Lsp finder find the symbol definition implement reference
    -- if there is no implement it will hide
    -- when you use action in finder like open vsplit then you can
    -- use <C-t> to jump back
    km.set("n", "gD", "<cmd>Lspsaga finder<CR>", { silent = true })

    -- Code action
    km.set({ "n", "v" }, "<leader>a", "<cmd>Lspsaga code_action<CR>", { silent = true })

    -- Rename
    -- km.set("n", "<space>r", "<cmd>Lspsaga rename<CR>", { silent = true })

    -- Peek Definition
    -- you can edit the definition file in this flaotwindow
    -- also support open/vsplit/etc operation check definition_action_keys
    -- support tagstack C-t jump back
    km.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", { silent = true })

    -- Show line diagnostics
    -- km.set("n", "<space>a", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true })

    -- Show cursor diagnostics
    -- km.set("n", "<leader>cd", "<cmd>Lspsaga show_cursor_diagnostics<CR>", { silent = true })

    -- Diagnostic jump can use `<c-o>` to jump back
    km.set("n", "[D", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { silent = true, desc = "Lspsaga diagnostic backward" })
    km.set("n", "]D", "<cmd>Lspsaga diagnostic_jump_next<CR>", { silent = true, desc = "Lspsaga diagnostic forward" })

    -- Only jump to error
    km.set("n", "[d", function()
        require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
    end, { silent = true, desc = "Lspsaga error diagnostic backward" })
    km.set("n", "]d", function()
        require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
    end, { silent = true, desc = "lspsaga error diagnostic forward" })

    -- Outline
    km.set("n", "<space>p", "<cmd>Lspsaga outline<CR>", { silent = true })

    -- Hover Doc
    km.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", { silent = true })

    -- Float terminal
    -- km.set("n", "<A-d>", "<cmd>Lspsaga open_floaterm<CR>", { silent = true })
    -- if you want to pass some cli command into a terminal you can do it like this
    -- open lazygit in lspsaga float terminal
    -- km.set("n", "<A-d>", "<cmd>Lspsaga open_floaterm lazygit<CR>", { silent = true })
    -- close floaterm
    -- km.set("t", "<A-d>", [[<C-\><C-n><cmd>Lspsaga close_floaterm<CR>]], { silent = true })
end

local function set_lsp()
    local on_attach = require("common").lsp_on_attack
    local lsp_flags = require("common").lsp_flags
    local capabilities = require("common").lsp_capabilities()

    local lspconfig = require("lspconfig")
    lspconfig.gopls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = { allow_incremental_sync = true, debounce_text_changes = 500 },
        filetypes = { 'go', 'gomod', 'gowork', 'gosum', 'gotmpl', 'gohtmltmpl', 'gotexttmpl' },
        root_dir = function(fname)
            return lspconfig.util.root_pattern 'go.work' (fname) or lspconfig.util.root_pattern('go.mod', '.git')(fname)
        end,
        single_file_support = true,
        cmd = { 'gopls' },
        settings = {
            gopls = {
                allExperiments = true,
                analyses = {
                    unusedvariable = true,
                    unreachable = true,
                    nilness = true,
                    unusedparams = true,
                    useany = true,
                    unusedwrite = true,
                    ST1003 = false,
                    undeclaredname = true,
                    fillreturns = true,
                    nonewvars = true,
                    fieldalignment = false,
                    shadow = false,
                },
                hints = {
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    compositeLiteralTypes = true,
                    constantValues = true,
                    functionTypeParameters = true,
                    parameterNames = true,
                    rangeVariableTypes = true,
                },
                codelenses = {
                    generate = true,
                    gc_details = false,
                    test = true,
                    tidy = true,
                    vendor = true,
                    regenerate_cgo = true,
                    upgrade_dependency = true,
                },
                staticcheck = true,
                allowModfileModifications = true,
                diagnosticsDelay = '500ms',
                usePlaceholders = false,
                completeUnimported = true,
                experimentalPostfixCompletions = true,
                expandWorkspaceToModule = true,
            },
        },
    }

    lspconfig.lua_ls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        log_level = 2,
        root_dir = lspconfig.util.root_pattern(".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml",
            "stylua.toml", "selene.toml", "selene.yml", ".git"),
        single_file_support = true,
        settings = {
            Lua = {
                runtime = {
                    -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                    version = 'LuaJIT',
                },
                diagnostics = {
                    -- Get the language server to recognize the `vim` global
                    globals = { 'vim' },
                },
                workspace = {
                    -- Make the server aware of Neovim runtime files
                    -- library = vim.api.nvim_get_runtime_file("", true),
                },
                -- Do not send telemetry data containing a randomized but unique identifier
                telemetry = {
                    enable = false,
                },
            },
        },
    }

    lspconfig.bufls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        cmd = { "bufls", "serve" },
        filetypes = { "proto" },
        root_dir = lspconfig.util.root_pattern("buf.work.yaml", ".git"),
        single_file_support = true,
    }

    lspconfig.jsonls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        cmd = { "vscode-json-language-server", "--stdio" },
        filetypes = { "json", "jsonc" },
        init_options = { provideFormatter = true },
        root_dir = lspconfig.util.find_git_ancestor,
        single_file_support = true,
    }

    lspconfig.yamlls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        cmd = { "yaml-language-server", "--stdio" },
        filetypes = { "yaml", "yaml.docker-compose" },
        root_dir = lspconfig.util.find_git_ancestor,
        single_file_support = true,
        setting = {
            redhat = {
                telemetry = {
                    enabled = false
                }
            }
        }
    }

    lspconfig.taplo.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        cmd = { "taplo", "lsp", "stdio" },
        filetypes = { "toml" },
        root_dir = lspconfig.util.find_git_ancestor,
        single_file_support = true,
    }

    lspconfig.pyright.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        single_file_support = true,
        root_dir = lspconfig.util.find_git_ancestor,
        settings = {
            {
                python = {
                    analysis = {
                        autoSearchPaths = true,
                        diagnosticMode = "workspace",
                        useLibraryCodeForTypes = true
                    }
                }
            }
        }
    }

    lspconfig.clangd.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        cmd = { "clangd" },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", --[[ "proto" ]] },
        single_file_support = true,
        root_dir = lspconfig.util.root_pattern(
            '.clangd',
            '.clang-tidy',
            '.clang-format',
            'compile_commands.json',
            'compile_flags.txt',
            'configure.ac',
            '.git'
        )
    }

    lspconfig.bashls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        cmd = { "bash-language-server", "start" },
        cmd_env = { GLOB_PATTERN = "*@(.sh|.inc|.bash|.command)" },
        filetypes = { "sh" },
        single_file_support = true,
        root_dir = lspconfig.util.find_git_ancestor
    }

    lspconfig.vimls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        cmd = { "vim-language-server", "--stdio" },
        filetypes = { "vim" },
        init_options = {
            diagnostic = {
                enable = true
            },
            indexes = {
                count = 3,
                gap = 100,
                projectRootPatterns = { "runtime", "nvim", ".git", "autoload", "plugin" },
                runtimepath = true
            },
            isNeovim = true,
            iskeyword = "@,48-57,_,192-255,-#",
            runtimepath = "",
            suggest = {
                fromRuntimepath = true,
                fromVimruntime = true
            },
            vimruntime = ""
        },
        root_dir = lspconfig.util.find_git_ancestor,
        single_file_support = true,
    }

    lspconfig.gradle_ls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        cmd = { "gradle-language-server" },
        filetypes = { "groovy" },
        init_options = {
            settings = {
                gradleWrapperEnabled = true
            }
        },
        root_dir = lspconfig.util.root_pattern("settings.gradle"),
        single_file_support = true,
    }
end

local function set_lsp_cmd()
    local custom_auto_format = api.nvim_create_augroup("CustomAutoFormat", { clear = true })
    api.nvim_create_autocmd(
        { 'BufWritePre' },
        {
            pattern = { "*" },
            callback = function()
                if m.format_disable then
                    return
                end

                local clients = vim.lsp.get_clients({ bufnr = vim.fn.bufnr() })
                if #clients == 0 then
                    return
                end

                for _, client in ipairs(clients) do
                    if not client.supports_method("textDocument/formatting") then
                        return
                    end
                end

                local ft = api.nvim_buf_get_option(0, 'filetype')
                if ft == "go" then
                    require('go.format').goimport()
                else
                    vim.lsp.buf.format({ async = false })
                end
            end,
            group = custom_auto_format,
        }
    )
    api.nvim_create_user_command("Format", function()
        if api.nvim_buf_get_option(0, 'filetype') == "go" then
            require('go.format').goimport()
        else
            vim.lsp.buf.format({ async = false })
        end
    end, {})
    api.nvim_create_user_command("FormatEnable", function()
        m.format_disable = false
    end, {})
    api.nvim_create_user_command("FormatDisable", function()
        m.format_disable = true
    end, {})
    -- LspRestart have supported
    -- api.nvim_create_user_command("LspReattach", function()
    --     local matching_configs = require('lspconfig.util').get_config_by_ft(vim.bo.filetype)
    --     for _, config in ipairs(matching_configs) do
    --         config.launch()
    --     end
    --     vim.lsp.buf.add_workspace_folder(vim.fn.getcwd())
    -- end, {})
end

return {
    {
        'neovim/nvim-lspconfig',
        event = "VeryLazy",
        config = function()
            local glyphs = require("common").glyphs
            local signs = {
                [vim.diagnostic.severity.ERROR] = { name = "DiagnosticSignError", text = glyphs["sign_error"] },
                [vim.diagnostic.severity.WARN] = { name = "DiagnosticSignWarn", text = glyphs["sign_warn"] },
                [vim.diagnostic.severity.HINT] = { name = "DiagnosticSignHint", text = glyphs["sign_hint"] },
                [vim.diagnostic.severity.INFO] = { name = "DiagnosticSignInfo", text = glyphs["sign_info"] },
            }

            for _, sign in pairs(signs) do
                vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
            end

            local config = {
                virtual_text = {
                    prefix = "",
                    spacing = 0,
                    format = function(diagnostic)
                        local sign = signs[diagnostic.severity]
                        if diagnostic.severity == vim.diagnostic.severity.ERROR then
                            return string.format("%s %s", sign.text, diagnostic.message)
                        elseif diagnostic.severity == vim.diagnostic.severity.WARN then
                            return string.format("%s %s", sign.text, diagnostic.message)
                        elseif diagnostic.severity == vim.diagnostic.severity.HINT then
                            return string.format("%s %s", sign.text, diagnostic.message)
                        elseif diagnostic.severity == vim.diagnostic.severity.INFO then
                            return string.format("%s %s", sign.text, diagnostic.message)
                        end
                        return diagnostic.message
                    end
                },
                signs = {
                    severity = vim.diagnostic.severity.ERROR,
                },
                update_in_insert = false,
                underline = true,
                severity_sort = true,
                float = {
                    border = "rounded"
                }
            }

            vim.diagnostic.config(config)
            require('lspconfig.ui.windows').default_options.border = 'rounded'
            api.nvim_set_hl(0, "LspInfoBorder", { link = 'CustomBorder' })

            set_lsp_cmd()
            set_lsp()
        end
    },
    {
        'jose-elias-alvarez/null-ls.nvim',
        event = "VeryLazy",
        config = function()
            local null_ls = require("null-ls")

            null_ls.setup({
                sources = {
                    -- proto
                    null_ls.builtins.formatting.protolint,
                    null_ls.builtins.diagnostics.protolint,

                    -- sql
                    null_ls.builtins.formatting.sql_formatter.with({
                        extra_filetypes = { "mysql" },
                    }),

                    -- shell
                    null_ls.builtins.formatting.shfmt,
                    null_ls.builtins.code_actions.shellcheck,
                    -- null_ls.builtins.diagnostics.shellcheck, // bashls will call shellcheck to diagnostics

                    -- yaml
                    null_ls.builtins.formatting.yamlfmt,

                    -- python
                    null_ls.builtins.formatting.black,
                }
            })
        end
    },
    {
        'ray-x/lsp_signature.nvim',
        event = "VeryLazy",
        opts = {
            debug = false,                                              -- set to true to enable debug logging
            log_path = vim.fn.stdpath("cache") .. "/lsp_signature.log", -- log dir when debug is on
            -- default is  ~/.cache/nvim/lsp_signature.log
            verbose = false,                                            -- show debug line number
            bind = true,                                                -- This is mandatory, otherwise border config won't get registered.
            -- If you want to hook lspsaga or other signature handler, pls set to false
            doc_lines = 0,                                              -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
            -- set to 0 if you DO NOT want any API comments be shown
            -- This setting only take effect in insert mode, it does not affect signature help in normal
            -- mode, 10 by default

            max_height = 12,                       -- max height of signature floating_window
            max_width = 80,                        -- max_width of signature floating_window
            noice = false,                         -- set to true if you using noice to render markdown
            wrap = true,                           -- allow doc/signature text wrap inside floating_window, useful if your lsp return doc/sig is too long
            floating_window = true,                -- show hint in a floating window, set to false for virtual text only mode
            floating_window_above_cur_line = true, -- try to place the floating above the current line when possible Note:
            -- will set to true when fully tested, set to false will use whichever side has more space
            -- this setting will be helpful if you do not want the PUM and floating win overlap

            floating_window_off_x = 1, -- adjust float windows x position.
            -- can be either a number or function
            floating_window_off_y = 0, -- adjust float windows y position. e.g -2 move window up 2 lines; 2 move down 2 lines
            -- can be either number or function, see examples

            close_timeout = 4000, -- close floating window after ms when laster parameter is entered
            fix_pos = false, -- set to true, the floating window will not auto-close until finish all parameters
            hint_enable = false, -- virtual hint enable
            hint_prefix = "🐼 ", -- Panda for parameter, NOTE: for the terminal not support emoji, might crash
            hint_scheme = "String",
            hi_parameter = "DiffAdd", -- how your parameter will be highlight
            handler_opts = {
                border = "rounded" -- double, rounded, single, shadow, none, or a table of borders
            },
            cursorhold_update = false, -- if cursorhold slows down the completion, set to false to disable it
            always_trigger = false, -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58
            auto_close_after = nil, -- autoclose signature float win after x sec, disabled if nil.
            extra_trigger_chars = {}, -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
            zindex = 200, -- by default it will be on top of all floating windows, set to <= 50 send it to bottom
            padding = '', -- character to pad on left and right of signature can be ' ', or '|'  etc
            transparency = 10, -- disabled by default, allow floating win transparent value 1~100
            shadow_blend = vim.g.custom_blend, -- if you using shadow as border use this set the opacity
            shadow_guibg = 'Black', -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
            timer_interval = 200, -- default timer check interval set to lower value if you want to reduce latency
            toggle_key = nil, -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'
            select_signature_key = nil, -- cycle to next signature, e.g. '<M-n>' function overloading
            move_cursor_key = nil, -- imap, use nvim_set_current_win to move cursor between current win and floating
        },
    },
    {
        "glepnir/lspsaga.nvim",
        event = "LspAttach",
        branch = "main",
        config = function()
            require("lspsaga").setup({
                preview = {
                    lines_above = 0,
                    lines_below = 10,
                },
                scroll_preview = {
                    scroll_down = '<C-f>',
                    scroll_up = '<C-b>',
                },
                request_timeout = 2000,
                finder = {
                    --percentage
                    max_height = 0.5,
                    keys = {
                        jump_to = 'p',
                        expand_or_jump = 'o',
                        vsplit = 'v',
                        split = 's',
                        tabe = 't',
                        tabnew = 'r',
                        quit = { 'q', '<ESC>' },
                        close_in_preview = '<ESC>',
                    },
                },
                definition = {
                    edit = '<cr>',
                    vsplit = '<C-c>v',
                    split = '<C-c>i',
                    tabe = '<C-c>t',
                    quit = 'q',
                },
                code_action = {
                    num_shortcut = true,
                    keys = {
                        quit = 'q',
                        exec = '<CR>',
                    },
                },
                lightbulb = {
                    enable = false,
                    enable_in_insert = false,
                    sign = false,
                    sign_priority = 40,
                    virtual_text = true,
                },
                diagnostic = {
                    on_insert = false,
                    jump_num_shortcut = true,
                    show_code_action = true,
                    border_follow = false,
                    text_hl_follow = false,
                    show_source = true,
                    keys = {
                        exec_action = 'o',
                        quit = 'q',
                        expand_or_jump = '<CR>',
                        quit_in_show = { 'q', '<ESC>' },
                    },
                },
                rename = {
                    quit = '<C-c>',
                    exec = '<CR>',
                    confirm = '<CR>',
                    in_select = false,
                },
                outline = {
                    win_position = 'right',
                    win_with = '',
                    win_width = 30,
                    layout = 'normal',
                    auto_preview = true,
                    auto_refresh = true,
                    auto_close = true,
                    custom_sort = nil,
                    close_after_jump = false,
                    keys = {
                        expand_or_jump = 'o',
                        jump = '<cr>',
                        quit = "q",
                    },
                },
                callhierarchy = {
                    show_detail = false,
                    keys = {
                        edit = 'e',
                        vsplit = 's',
                        split = 'i',
                        tabe = 't',
                        jump = '<cr>',
                        quit = 'q',
                        expand_collaspe = 'o',
                    },
                },
                symbol_in_winbar = {
                    enable = false,
                    separator = '',
                    hide_keyword = true,
                    show_file = false,
                    folder_level = 2,
                    respect_root = false,
                    color_mode = true,
                },
                ui = {
                    theme = 'round',
                    border = 'rounded',
                    winblend = vim.g.custom_blend,
                    kind = {},
                },
            })
            api.nvim_set_hl(0, "SagaBorder", { link = 'CustomBorder' })
            api.nvim_set_hl(0, "SagaVirtLine", { link = 'CustomVirtualText' })

            load_saga_keymap()
        end
    },
    {
        'mfussenegger/nvim-jdtls',
        ft = "java",
        config = function()
            local on_attach = function(client, bufnr)
                require("common").lsp_on_attack(client, bufnr)
                require('jdtls').setup_dap({ hotcodereplace = 'auto' })
                require("jdtls.setup"):add_commands()
            end

            -- This bundles definition is the same as in the previous section (java-debug installation)
            local bundles = {
                vim.fn.glob(
                    "/home/ubuntu/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
                    1),
            };

            -- This is the new part
            vim.list_extend(
                bundles,
                vim.split(
                    vim.fn.glob("/home/ubuntu/.local/share/nvim/mason/packages/java-test/extension/server/*.jar", 1),
                    "\n")
            )
            require('jdtls').start_or_attach({
                on_attach = on_attach,
                capabilities = require("common").lsp_capabilities(),
                flags = require("common").lsp_flags,
                -- The command that starts the language server
                -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
                cmd = {

                    -- 💀
                    'java', -- or '/path/to/java17_or_newer/bin/java'
                    -- depends on if `java` is in your $PATH env variable and if it points to the right version.

                    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
                    '-Dosgi.bundles.defaultStartLevel=4',
                    '-Declipse.product=org.eclipse.jdt.ls.core.product',
                    '-Dlog.protocol=true',
                    '-Dlog.level=ALL',
                    '-Xms1g',
                    '--add-modules=ALL-SYSTEM',
                    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
                    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',

                    -- 💀
                    '-jar',
                    '/home/ubuntu/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar',
                    -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
                    -- Must point to the                                                     Change this to
                    -- eclipse.jdt.ls installation                                           the actual version


                    -- 💀
                    '-configuration', '/home/ubuntu/.local/share/nvim/mason/packages/jdtls/config_linux',
                    -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
                    -- Must point to the                      Change to one of `linux`, `win` or `mac`
                    -- eclipse.jdt.ls installation            Depending on your system.


                    -- 💀
                    -- See `data directory configuration` section in the README
                    '-data', '/home/ubuntu/.cache/jdtls/workspace'
                },
                -- 💀
                -- This is the default if not provided, you can remove it. Or adjust as needed.
                -- One dedicated LSP server & client will be started per unique root_dir
                root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew' }),
                -- Here you can configure eclipse.jdt.ls specific settings
                -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
                -- for a list of options
                settings = {
                    java = {
                    }
                },
                -- Language server `initializationOptions`
                -- You need to extend the `bundles` with paths to jar files
                -- if you want to use additional eclipse.jdt.ls plugins.
                --
                -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
                --
                -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
                init_options = {
                    bundles = bundles,
                },
            })
        end
    },
    {
        'ray-x/guihua.lua',
        lazy = true,
        opts = {
            maps = {
                close_view = '<esc>',
                send_qf = '<C-q>',
                save = '<C-s>',
                jump_to_list = '<C-w>k',
                jump_to_preview = '<C-w>j',
                prev = '<C-k>',
                next = '<C-j>',
                pageup = '<C-b>',
                pagedown = '<C-f>',
                confirm = '<cr>',
                split = '<C-s>',
                vsplit = '<C-v>',
                tabnew = '<C-t>',
            },
        }
    },
    {
        'ray-x/go.nvim',
        ft = "go",
        dependencies = { 'ray-x/guihua.lua' },
        opts = {
            disable_defaults = false, -- true|false when true set false to all boolean settings and replace all table
            -- settings with {}
            go = 'go', -- go command, can be go[default] or go1.18beta1
            goimport = 'gopls', -- goimport command, can be gopls[default] or goimport
            fillstruct = 'gopls', -- can be nil (use fillstruct, slower) and gopls
            gofmt = 'gopls', --gofmt cmd,
            max_line_len = 128, -- max line length in golines format, Target maximum line length for golines
            tag_transform = "camelcase", -- can be transform option("snakecase", "camelcase", etc) check gomodifytags for details and more options
            tag_options = "json=", -- sets options sent to gomodifytags, i.e., json=omitempty
            gotests_template = "", -- sets gotests -template parameter (check gotests for details)
            gotests_template_dir = "", -- sets gotests -template_dir parameter (check gotests for details)
            comment_placeholder = '', -- comment_placeholder your cool placeholder e.g. ﳑ       
            icons = { breakpoint = '🧘', currentpos = '🏃' }, -- setup to `false` to disable icons setup
            verbose = false, -- output loginf in messages
            lsp_cfg = false, --[[ true: use non-default gopls setup specified in go/lsp.lua
                              false: do nothing if lsp_cfg is a table, merge table with with non-default gopls setup in go/lsp.lua, e.g.
                              lsp_cfg = {settings={gopls={matcher='CaseInsensitive', ['local'] = 'your_local_module_path', gofumpt = true }}} ]]
            lsp_gofumpt = false, -- true: set default gofmt in gopls format to gofumpt
            lsp_on_attach = nil, -- nil: do nothing if lsp_on_attach is a function: use this function as on_attach function for gopls, when lsp_cfg is true
            lsp_keymaps = false, -- true: use default keymaps defined in go/lsp.lua
            lsp_codelens = false,
            lsp_diag_hdlr = nil, -- hook lsp diag handler
            lsp_diag_underline = false,
            -- virtual text setup
            lsp_diag_virtual_text = nil,
            lsp_diag_signs = false,
            lsp_diag_update_in_insert = false,
            lsp_document_formatting = false,
            -- set to true: use gopls to format
            -- false if you want to use other formatter tool(e.g. efm, nulls)
            lsp_inlay_hints = {
                enable = false,
                -- Only show inlay hints for the current line
                only_current_line = false,
                -- Event which triggers a refersh of the inlay hints.
                -- You can make this "CursorMoved" or "CursorMoved,CursorMovedI" but
                -- not that this may cause higher CPU usage.
                -- This option is only respected when only_current_line and
                -- autoSetHints both are true.
                only_current_line_autocmd = "CursorHold",
                -- whether to show variable name before type hints with the inlay hints or not
                -- default: false
                show_variable_name = true,
                -- prefix for parameter hints
                parameter_hints_prefix = " ",
                show_parameter_hints = true,
                -- prefix for all the other hints (type, chaining)
                other_hints_prefix = "=> ",
                -- whether to align to the lenght of the longest line in the file
                max_len_align = false,
                -- padding from the left if max_len_align is true
                max_len_align_padding = 1,
                -- whether to align to the extreme right or not
                right_align = false,
                -- padding from the right if right_align is true
                right_align_padding = 6,
                -- The color of the hints
                highlight = "CustomVirtualText",
            },
            gopls_cmd = nil,           -- if you need to specify gopls path and cmd, e.g {"/home/user/lsp/gopls", "-logfile","/var/log/gopls.log" }
            gopls_remote_auto = false, -- add -remote=auto to gopls
            gocoverage_sign = "█",
            sign_priority = 5,         -- change to a higher number to override other signs
            dap_debug = true,          -- set to false to disable dap
            dap_debug_keymap = false, --[[ true: use keymap for debugger defined in go/dap.lua
                                      false: do not use keymap in go/dap.lua.  you must define your own.
                                      windows: use visual studio keymap ]]
            dap_debug_gui = false,    -- bool|table put your dap-ui setup here set to false to disable
            dap_debug_vt = false,     -- bool|table put your dap-virtual-text setup here set to false to disable
            dap_port = -1,            -- can be set to a number, if set to -1 go.nvim will pickup a random port
            dap_timeout = 15,         --  see dap option initialize_timeout_sec = 15,
            dap_retries = 20,         -- see dap option max_retries
            build_tags = "",          -- set default build tags
            textobjects = false,      -- enable default text jobects through treesittter-text-objects
            test_runner = 'go',       -- one of {`go`, `richgo`, `dlv`, `ginkgo`, `gotestsum`}
            verbose_tests = true,     -- set to add verbose flag to tests deprecated, see '-v' option
            run_in_floaterm = true,   -- set to true to run in float window. :GoTermClose closes the floatterm
            floaterm = {
                posititon = 'center', -- one of {`top`, `bottom`, `left`, `right`, `center`, `auto`}
                width = 0.50,         -- width of float window if not auto
                height = 0.50,        -- height of float window if not auto
            },
            trouble = false,          -- true: use trouble to open quickfix
            test_efm = false,         -- errorfomat for quickfix, default mix mode, set to true will be efm only
            luasnip = true,           -- enable included luasnip snippets. you can also disable while add lua/snips folder to luasnip load
            --  Do not enable this if you already added the path, that will duplicate the entries
        }
    },
    {
        'simrat39/rust-tools.nvim',
        ft = "rust",
        config = function()
            local rt = require("rust-tools")
            local lspconfig = require("lspconfig")

            rt.setup({
                tools = {
                    -- how to execute terminal commands
                    -- options right now: termopen / quickfix / toggleterm / vimux
                    executor = require("rust-tools.executors").toggleterm,
                    -- These apply to the default RustSetInlayHints command
                    inlay_hints = {
                        -- automatically set inlay hints (type hints)
                        -- default: true
                        auto = true,

                        -- Only show inlay hints for the current line
                        only_current_line = false,

                        -- whether to show parameter hints with the inlay hints or not
                        -- default: true
                        show_parameter_hints = true,

                        -- prefix for parameter hints
                        -- default: "<-"
                        parameter_hints_prefix = "<- ",

                        -- prefix for all the other hints (type, chaining)
                        -- default: "=>"
                        other_hints_prefix = "=> ",

                        -- whether to align to the length of the longest line in the file
                        max_len_align = false,

                        -- padding from the left if max_len_align is true
                        max_len_align_padding = 1,

                        -- whether to align to the extreme right or not
                        right_align = false,

                        -- padding from the right if right_align is true
                        right_align_padding = 7,

                        -- The color of the hints
                        highlight = "CustomVirtualText",
                    },
                },
                server = {
                    on_attach = require("common").lsp_on_attack,
                    capabilities = require("common").lsp_capabilities(),
                    flags = require("common").lsp_flags,
                    cmd = { "rust-analyzer" },
                    filetypes = { "rust" },
                    root_dir = lspconfig.util.root_pattern("Cargo.toml", "rust-project.json"),
                    settings = {
                        ['rust-analyzer'] = {
                            cargo = {
                                autoReload = true
                            },
                            completion = {
                                callable = {
                                    snippets = "add_parentheses"
                                }
                            }
                        }
                    },
                },
            })
        end
    },
}
