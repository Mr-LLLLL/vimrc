local km = vim.keymap

local function load_saga_keymap(opts)
    -- Lsp finder find the symbol definition implement reference
    -- if there is no implement it will hide
    -- when you use action in finder like open vsplit then you can
    -- use <C-t> to jump back
    km.set("n", "gD", "<cmd>Lspsaga finder<CR>", require("common").keymap_desc(opts, "Lspsaga Finder"))

    -- Code action
    km.set({ "n", "v" }, "<leader>q", "<cmd>Lspsaga code_action<CR>",
        require("common").keymap_desc(opts, "Lspsaga CodeAction"))

    -- Rename
    -- km.set("n", "<space>r", "<cmd>Lspsaga rename<CR>", { silent = true })

    -- Peek Definition
    -- you can edit the definition file in this flaotwindow
    -- also support open/vsplit/etc operation check definition_action_keys
    -- support tagstack C-t jump back
    km.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", require("common").keymap_desc(opts, "Lspsaga Peek Definition"))

    -- Show line diagnostics
    -- km.set("n", "<space>a", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true })

    -- Show cursor diagnostics
    -- km.set("n", "<leader>cd", "<cmd>Lspsaga show_cursor_diagnostics<CR>", { silent = true })

    -- Diagnostic jump can use `<c-o>` to jump back
    km.set("n", "[D", "<cmd>Lspsaga diagnostic_jump_prev<CR>",
        require("common").keymap_desc(opts, "Lspsaga Diagnostic Backward"))
    km.set("n", "]D", "<cmd>Lspsaga diagnostic_jump_next<CR>",
        require("common").keymap_desc(opts, "Lspsaga Diagnostic Forward"))

    -- Only jump to error
    km.set("n", "[d", function()
        require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
    end, require("common").keymap_desc(opts, "Lspsaga Error Diagnostic Backward"))
    km.set("n", "]d", function()
        require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
    end, require("common").keymap_desc(opts, "Lspsaga Error Diagnostic Forward"))

    -- Outline
    km.set("n", "<space>p", "<cmd>Lspsaga outline<CR>", require("common").keymap_desc(opts, "Lspsaga Outline"))

    -- Hover Doc
    km.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", require("common").keymap_desc(opts, "Lspsaga HoverDoc"))

    -- Float terminal
    -- km.set("n", "<A-d>", "<cmd>Lspsaga open_floaterm<CR>", { silent = true })
    -- if you want to pass some cli command into a terminal you can do it like this
    -- open lazygit in lspsaga float terminal
    -- km.set("n", "<A-d>", "<cmd>Lspsaga open_floaterm lazygit<CR>", { silent = true })
    -- close floaterm
    -- km.set("t", "<A-d>", [[<C-\><C-n><cmd>Lspsaga close_floaterm<CR>]], { silent = true })
end

return {
    -- {
    --     'ray-x/lsp_signature.nvim',
    --     event = "VeryLazy",
    --     opts = {
    --         debug = false,                                              -- set to true to enable debug logging
    --         log_path = vim.fn.stdpath("cache") .. "/lsp_signature.log", -- log dir when debug is on
    --         -- default is  ~/.cache/nvim/lsp_signature.log
    --         verbose = false,                                            -- show debug line number
    --         bind = false,                                               -- This is mandatory, otherwise border config won't get registered.
    --         -- If you want to hook lspsaga or other signature handler, pls set to false
    --         doc_lines = 0,                                              -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
    --         -- set to 0 if you DO NOT want any API comments be shown
    --         -- This setting only take effect in insert mode, it does not affect signature help in normal
    --         -- mode, 10 by default
    --
    --         max_height = 12,                       -- max height of signature floating_window
    --         max_width = 80,                        -- max_width of signature floating_window
    --         noice = false,                         -- set to true if you using noice to render markdown
    --         wrap = true,                           -- allow doc/signature text wrap inside floating_window, useful if your lsp return doc/sig is too long
    --         floating_window = true,                -- show hint in a floating window, set to false for virtual text only mode
    --         floating_window_above_cur_line = true, -- try to place the floating above the current line when possible Note:
    --         -- will set to true when fully tested, set to false will use whichever side has more space
    --         -- this setting will be helpful if you do not want the PUM and floating win overlap
    --
    --         floating_window_off_x = 1, -- adjust float windows x position.
    --         -- can be either a number or function
    --         floating_window_off_y = 0, -- adjust float windows y position. e.g -2 move window up 2 lines; 2 move down 2 lines
    --         -- can be either number or function, see examples
    --
    --         close_timeout = 4000, -- close floating window after ms when laster parameter is entered
    --         fix_pos = false, -- set to true, the floating window will not auto-close until finish all parameters
    --         hint_enable = false, -- virtual hint enable
    --         hint_prefix = "🐼 ", -- Panda for parameter, NOTE: for the terminal not support emoji, might crash
    --         hint_scheme = "String",
    --         hi_parameter = "DiffAdd", -- how your parameter will be highlight
    --         handler_opts = {
    --             border = "rounded" -- double, rounded, single, shadow, none, or a table of borders
    --         },
    --         cursorhold_update = false, -- if cursorhold slows down the completion, set to false to disable it
    --         always_trigger = false, -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58
    --         auto_close_after = nil, -- autoclose signature float win after x sec, disabled if nil.
    --         extra_trigger_chars = {}, -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
    --         zindex = 200, -- by default it will be on top of all floating windows, set to <= 50 send it to bottom
    --         padding = '', -- character to pad on left and right of signature can be ' ', or '|'  etc
    --         transparency = 10, -- disabled by default, allow floating win transparent value 1~100
    --         shadow_blend = vim.g.custom_blend, -- if you using shadow as border use this set the opacity
    --         shadow_guibg = 'Black', -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
    --         timer_interval = 200, -- default timer check interval set to lower value if you want to reduce latency
    --         toggle_key = nil, -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'
    --         select_signature_key = nil, -- cycle to next signature, e.g. '<M-n>' function overloading
    --         move_cursor_key = nil, -- imap, use nvim_set_current_win to move cursor between current win and floating
    --     },
    -- },
    {
        "glepnir/lspsaga.nvim",
        event = "VeryLazy",
        branch = "main",
        config = function()
            require("lspsaga").setup({
                preview = {
                    lines_above = 0,
                    lines_below = 10,
                },
                scroll_preview = {
                    scroll_down = '<C-n>',
                    scroll_up = '<C-p>',
                },
                request_timeout = 2000,
                finder = {
                    --percentage
                    max_height = 0.5,
                    keys = {
                        shuttle = 'p',
                        toggle_or_open = 'o',
                        vsplit = 'v',
                        split = 's',
                        tabe = 't',
                        tabnew = 'r',
                        quit = { 'q', '<ESC>' },
                        close = '<ESC>',
                    },
                },
                definition = {
                    keys = {
                        edit = '<cr>',
                        vsplit = '<C-c>v',
                        split = '<C-c>i',
                        tabe = '<C-c>t',
                        quit = 'q',
                    }
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
                        quit = "<space>p",
                    },
                },
                callhierarchy = {
                    layout = 'float',
                    left_width = 0.2,
                    keys = {
                        edit = 'e',
                        vsplit = 'v',
                        split = 's',
                        tabe = 't',
                        close = '<esc>',
                        quit = 'q',
                        shuttle = 'p',
                        toggle_or_req = 'o',
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
                    button = { '(', ')' },
                    lines = { '└', '├', '│', '─', '┌' },
                    winblend = vim.g.custom_blend,
                    kind = {},
                },
            })

            require("common").register(load_saga_keymap)
        end
    },
    {
        'mfussenegger/nvim-jdtls',
        ft = "java",
        config = function()
            local on_attach = function(client, bufnr)
                require("common").lsp_on_attach(client, bufnr)
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
        -- 'Mr-LLLLL/go.nvim',
        ft = { "go", 'gomod' },
        dependencies = { 'ray-x/guihua.lua' },
        build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
        opts = {
            disable_defaults = false, -- true|false when true set false to all boolean settings and replace all table
            -- settings with {}
            go = 'go', -- go command, can be go[default] or go1.18beta1
            goimports = 'gopls', -- goimport command, can be gopls[default] or goimport
            fillstruct = 'gopls', -- can be nil (use fillstruct, slower) and gopls
            gofmt = 'gopls', --gofmt cmd,
            -- max_line_len = 128, -- max line length in golines format, Target maximum line length for golines
            tag_transform = "camelcase", -- can be transform option("snakecase", "camelcase", etc) check gomodifytags for details and more options
            tag_options = "json=", -- sets options sent to gomodifytags, i.e., json=omitempty
            gotests_template = "", -- sets gotests -template parameter (check gotests for details)
            gotests_template_dir = "", -- sets gotests -template_dir parameter (check gotests for details)
            comment_placeholder = '', -- comment_placeholder your cool placeholder e.g. ﳑ       
            icons = { breakpoint = '🧘', currentpos = '🏃' }, -- setup to `false` to disable icons setup
            verbose = false, -- output loginf in messages
            lsp_cfg = {
                on_attach = require("common").lsp_on_attach,
                capabilities = require("common").lsp_capabilities(),
                flags = require("common").lsp_flags,
                settings = {
                    gopls = {
                        usePlaceholders = false,
                        analyses = {
                            shadow = false,
                            ST1003 = false,
                            fieldalignment = false,
                        },
                        codelenses = {
                            generate = true,   -- show the `go generate` lens.
                            gc_details = true, -- Show a code lens toggling the display of gc's choices.
                            test = true,
                            tidy = true,
                            vendor = true,
                            regenerate_cgo = true,
                            upgrade_dependency = true,
                            run_govulncheck = true,
                        },
                        diagnosticsTrigger = "Edit",
                    }
                }
            },
            lsp_gofumpt = true,  -- true: set default gofmt in gopls format to gofumpt
            lsp_on_attach = nil, -- nil: do nothing if lsp_on_attach is a function: use this function as on_attach function for gopls, when lsp_cfg is true
            lsp_keymaps = false, -- true: use default keymaps defined in go/lsp.lua
            lsp_codelens = false,
            -- virtual text setup
            diagnostic = {},
            lsp_document_formatting = false,
            -- set to true: use gopls to format
            -- false if you want to use other formatter tool(e.g. efm, nulls)
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
            luasnip = false,          -- enable included luasnip snippets. you can also disable while add lua/snips folder to luasnip load
            --  Do not enable this if you already added the path, that will duplicate the entries
        }
    },
    {
        "mrcjkb/rustaceanvim",
        version = '^4', -- Recommended
        ft = "rust",
        init = function()
            vim.g.rustaceanvim = {
                tools = {
                    -- how to execute terminal commands
                    -- options right now: termopen / quickfix / toggleterm / vimux
                    executor = require('rustaceanvim.executors').toggleterm,
                },
                server = {
                    on_attach = require("common").lsp_on_attach,
                    capabilities = require("common").lsp_capabilities(),
                    flags = require("common").lsp_flags,
                    cmd = { "rust-analyzer" },
                    filetypes = { "rust" },
                    root_dir = require("lspconfig").util.root_pattern("Cargo.toml", "rust-project.json"),
                    settings = {
                        ['rust-analyzer'] = {
                            cargo = {
                                autoReload = true
                            },
                            completion = {
                                callable = {
                                    snippets = "add_parentheses"
                                }
                            },
                            lens = {
                                enable = true,
                                references = {
                                    adt = {
                                        enable = true,
                                    },
                                    enumVariant = {
                                        enable = true,
                                    },
                                    method = {
                                        enable = true,
                                    },
                                    trait = {
                                        enable = true,
                                    }
                                },
                            },
                        }
                    },
                },
            }

            local group = vim.api.nvim_create_augroup("RustaceanvimCustomGroup", { clear = true })
            vim.api.nvim_create_autocmd(
                { "Filetype" },
                {
                    pattern = { "rust" },
                    callback = function()
                        vim.keymap.set(
                            'n',
                            '<space>r',
                            "<cmd>RustLsp runnables<cr>",
                            { noremap = true, silent = true, buffer = true }
                        )
                    end,
                    group = group,
                }
            )
        end
    },
}
