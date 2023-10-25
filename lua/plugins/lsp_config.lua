local api = vim.api

local m = {}

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

                local clients = vim.lsp.get_active_clients({ bufnr = api.nvim_get_current_buf() })
                if not vim.tbl_islist(clients) or #clients == 0 then
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
        dependencies = {
            'glepnir/lspsaga.nvim',
        },
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
        'nvimtools/none-ls.nvim',
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
}
