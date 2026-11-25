local api = vim.api

local m = {}

local function set_lsp()
    local on_attach = require("common").lsp_on_attach
    local lsp_flags = require("common").lsp_flags
    local capabilities = require("common").lsp_capabilities()

    vim.lsp.config('lua_ls', {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        log_level = 2,
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
    })
    vim.lsp.enable("lua_ls")


    vim.lsp.config('buf_ls', {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        cmd = { "buf", "beta", "lsp", "--timeout=0", "--log-format=text" },
        filetypes = { "proto" },
        single_file_support = true,
    })
    vim.lsp.enable("buf_ls")

    vim.lsp.config('jsonls', {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        cmd = { "vscode-json-language-server", "--stdio" },
        filetypes = { "json", "jsonc" },
        init_options = { provideFormatter = true },
        single_file_support = true,
    })
    vim.lsp.enable("jsonls")

    vim.lsp.config('yamlls', {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        cmd = { "yaml-language-server", "--stdio" },
        filetypes = { "yaml", "yaml.docker-compose" },
        single_file_support = true,
        setting = {
            redhat = {
                telemetry = {
                    enabled = false
                }
            }
        }
    })
    vim.lsp.enable("yamlls")

    vim.lsp.config('taplo', {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        cmd = { "taplo", "lsp", "stdio" },
        filetypes = { "toml" },
        single_file_support = true,
    })
    vim.lsp.enable("taplo")

    vim.lsp.config('pyright', {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        single_file_support = true,
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
    })
    vim.lsp.enable("pyright")

    vim.lsp.config('clangd', {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        cmd = { "clangd" },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", --[[ "proto" ]] },
        single_file_support = true,
    })
    vim.lsp.enable("clangd")

    vim.lsp.config('bashls', {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        cmd = { "bash-language-server", "start" },
        cmd_env = { GLOB_PATTERN = "*@(.sh|.inc|.bash|.command)" },
        filetypes = { "sh" },
        single_file_support = true,
    })
    vim.lsp.enable("bashls")

    vim.lsp.config('vimls', {
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
        single_file_support = true,
    })
    vim.lsp.enable("vimls")

    vim.lsp.config('gradle_ls', {
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
        single_file_support = true,
    })
    vim.lsp.enable("gradle_ls")
end

local function set_lsp_autocmd()
    local custom_lsp_autocmd = api.nvim_create_augroup("CustomLspAutocmd", { clear = true })
    api.nvim_create_autocmd(
        { 'BufWritePre' },
        {
            pattern = { "*" },
            callback = function(opt)
                if m.format_disable then
                    return
                end

                local clients = vim.lsp.get_clients({
                    bufnr = opt.buf,
                    method = "textDocument/formatting"
                })
                if #clients == 0 then
                    return
                end

                local format = function()
                    local ft = api.nvim_buf_get_option(0, 'filetype')
                    if ft == "go" then
                        require('go.format').goimports()
                    else
                        vim.lsp.buf.format({ async = false })
                    end
                end

                for _, client in ipairs(clients) do
                    if not client:is_stopped() then
                        format()
                        return
                    end
                end
            end,
            group = custom_lsp_autocmd,
        }
    )
    api.nvim_create_autocmd(
        { "BufEnter", "InsertLeave" },
        {
            pattern = { "*" },
            callback = function(opt)
                local clients = vim.lsp.get_clients({
                    bufnr = opt.buf,
                    method = "textDocument/codeLens"
                })
                if #clients == 0 then
                    return
                end

                for _, client in ipairs(clients) do
                    if not client:is_stopped() then
                        vim.lsp.codelens.enable(true, { bufnr = opt.buf })
                        return
                    end
                end
            end,
            group = custom_lsp_autocmd,
        }
    )
    api.nvim_create_user_command("Format", function()
        if api.nvim_buf_get_option(0, 'filetype') == "go" then
            require('go.format').goimports()
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
    api.nvim_create_user_command("ToggleInlayHint", function()
        local ft = api.nvim_buf_get_option(0, 'filetype')
        if ft == "go" then
            require('go.inlay').toggle_inlay_hints()
        else
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
        end
    end, {})
    -- nvim 0.12 自带 `:lsp stop [name]`，但它只停「当前 buffer 的」client；
    -- 按名字停、带补全的写法自己补上：
    --   :LspStop                停当前 buffer 上的 client
    --   :LspStop gopls          停所有叫 gopls 的 client（同名多 view 一起停）
    --   :LspStop gop            名字不用写全，子串匹配
    --   :LspStop 3              同名多 client 时按 id 精确停一个
    --   :LspStop! gopls         强制（kill）而不是优雅退出
    api.nvim_create_user_command("LspStop", function(opts)
        local seen, targets = {}, {}
        local function add(client)
            if client and not seen[client.id] and not client:is_stopped() then
                seen[client.id] = true
                targets[#targets + 1] = client
            end
        end
        local clients = vim.lsp.get_clients()

        if #opts.fargs == 0 then
            for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
                add(client)
            end
        end
        for _, arg in ipairs(opts.fargs) do
            local id, matched = tonumber(arg), false
            if id then
                for _, client in ipairs(clients) do
                    if client.id == id then
                        add(client)
                        matched = true
                    end
                end
            else
                for _, client in ipairs(clients) do
                    if client.name == arg then
                        add(client)
                        matched = true
                    end
                end
                if not matched then
                    for _, client in ipairs(clients) do
                        if client.name:lower():find(arg:lower(), 1, true) then
                            add(client)
                            matched = true
                        end
                    end
                end
            end
            if not matched then
                vim.notify("LspStop: no running client matches '" .. arg .. "'", vim.log.levels.WARN)
            end
        end

        if #targets == 0 then
            if #opts.fargs == 0 then
                vim.notify("LspStop: no client attached to current buffer", vim.log.levels.INFO)
            end
            return
        end

        local labels = {}
        for _, client in ipairs(targets) do
            labels[#labels + 1] = string.format("%s(%d)", client.name, client.id)
            client:stop(opts.bang)
        end
        vim.notify("LspStop: stopped " .. table.concat(labels, ", "), vim.log.levels.INFO)
    end, {
        nargs = "*",
        bang = true,
        desc = "Stop LSP client(s) by name or id (no arg: current buffer)",
        complete = function(arglead)
            local items, seen = {}, {}
            for _, client in ipairs(vim.lsp.get_clients()) do
                if not seen[client.name] then
                    seen[client.name] = true
                    items[#items + 1] = client.name
                end
                items[#items + 1] = tostring(client.id)
            end
            table.sort(items)
            return vim.tbl_filter(function(item)
                return item:sub(1, #arglead) == arglead
            end, items)
        end,
    })
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
                    text = { [vim.diagnostic.severity.ERROR] = glyphs["sign_error"] }
                },
                update_in_insert = false,
                underline = true,
                severity_sort = true,
                float = {
                    border = "rounded"
                }
            }

            vim.diagnostic.config(config)

            set_lsp_autocmd()
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

                    -- yaml
                    null_ls.builtins.formatting.yamlfmt,

                    -- python
                    null_ls.builtins.formatting.black,
                }
            })
        end
    },
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- Library paths can be absolute
                "~/.local/share/nvim/lazy/",
                -- Or relative, which means they will be resolved from the plugin dir.
                "lazy.nvim",
                -- It can also be a table with trigger words / mods
                -- Only load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library",        words = { "vim%.uv" } },
                -- always load the LazyVim library
                "LazyVim",
                -- Only load the lazyvim library when the `LazyVim` global is found
                { path = "LazyVim",                   words = { "LazyVim" } },
                -- Load the wezterm types when the `wezterm` module is required
                -- Needs `justinsgithub/wezterm-types` to be installed
                { path = "wezterm-types",             mods = { "wezterm" } },
                -- Load the xmake types when opening file named `xmake.lua`
                -- Needs `LelouchHe/xmake-luals-addon` to be installed
                { path = "xmake-luals-addon/library", files = { "xmake.lua" } },
            },
            -- always enable unless `vim.g.lazydev_enabled = false`
            -- This is the default
            enabled = function(root_dir)
                return vim.g.lazydev_enabled == nil and true or vim.g.lazydev_enabled
            end,
            -- disable when a .luarc.json file is found
            enabled = function(root_dir)
                return not vim.uv.fs_stat(root_dir .. "/.luarc.json")
            end,
        },
    },
}
