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
                    path = { 'lua/?.lua', 'lua/?/init.lua' },
                },
                diagnostics = {
                    -- Get the language server to recognize the `vim` global
                    globals = { 'vim' },
                },
                workspace = {
                    -- 只索引当前工作区，不加载 VIMRUNTIME / 插件目录（会撑到 2GB+）
                    library = {},
                    checkThirdParty = false,
                    maxPreload = 1000,
                    preloadFileSize = 500,
                },
                hint = { enable = false },
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
    -- nvim 0.12 自带 `:lsp stop` / `:lsp restart`，但它们只动 client，不碰共享 daemon。
    -- 这里补一个彻底重启：停 client → 杀共享 daemon（gopls 的 -remote=auto serve 进程）
    -- → 在当前 buffer 上重新起一个 client。
    --   :LspRestart            重启当前 buffer 上的 client
    --   :LspRestart gopls      按名字（支持子串）重启所有同名 client
    --   :LspRestart 3          同名多 client 时按 id 指定
    local function lsp_alive(pid)
        return vim.fn.system({ "ps", "-p", tostring(pid), "-o", "pid=" }):find("%d") ~= nil
    end

    local function lsp_kill_daemons()
        local daemons = {}
        -- 只杀本进程 XDG_RUNTIME_DIR 下的共享 daemon（同一用户的 nvim session 共用那个 socket）
        local run_dir = vim.env.XDG_RUNTIME_DIR
        for _, line in ipairs(vim.fn.systemlist("ps -eo pid,args")) do
            local pid, args = line:match("^%s*(%d+)%s+(.*)$")
            local socket = args and args:match("%-listen unix;(%S+)")
            if pid and socket and args:find("/gopls serve -listen", 1, true) then
                if not run_dir or socket:sub(1, #run_dir) == run_dir then
                    daemons[#daemons + 1] = { pid = tonumber(pid), socket = socket }
                end
            end
        end
        for _, d in ipairs(daemons) do
            pcall(vim.uv.kill, d.pid, "sigterm")
        end
        -- 等 daemon 真的退出，否则新 client 可能连上还在关闭的 socket
        vim.wait(2000, function()
            for _, d in ipairs(daemons) do
                if lsp_alive(d.pid) then
                    return false
                end
            end
            return true
        end, 25)
        for _, d in ipairs(daemons) do
            if lsp_alive(d.pid) then
                pcall(vim.uv.kill, d.pid, "sigkill")
                vim.wait(500, function()
                    return not lsp_alive(d.pid)
                end, 25)
            end
            if d.socket and not lsp_alive(d.pid) then
                vim.uv.fs_unlink(d.socket)
            end
        end
        return #daemons
    end

    -- 解析参数：无参 = 当前 buffer 的 client；有参 = 名字（子串兜底）或 client id
    local function lsp_collect_targets(fargs)
        local seen, targets, names = {}, {}, {}
        local function add(client)
            if client and not seen[client.id] and not client:is_stopped() then
                seen[client.id] = true
                targets[#targets + 1] = client
                if not vim.tbl_contains(names, client.name) then
                    names[#names + 1] = client.name
                end
            end
        end
        if #fargs == 0 then
            for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
                add(client)
            end
            return targets, names, {}
        end
        local clients, unmatched = vim.lsp.get_clients(), {}
        for _, arg in ipairs(fargs) do
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
                unmatched[#unmatched + 1] = arg
            end
        end
        return targets, names, unmatched
    end

    api.nvim_create_user_command("LspRestart", function(opts)
        local bufnr = api.nvim_get_current_buf()
        local targets, names, unmatched = lsp_collect_targets(opts.fargs)
        if #targets == 0 then
            if #unmatched > 0 then
                vim.notify("LspRestart: no running client matches '" .. table.concat(unmatched, " ") .. "'", vim.log.levels.WARN)
            else
                vim.notify("LspRestart: no client attached to current buffer", vim.log.levels.INFO)
            end
            return
        end

        for _, client in ipairs(targets) do
            pcall(client.stop, client)
        end
        vim.wait(2000, function()
            for _, client in ipairs(targets) do
                if vim.lsp.get_client_by_id(client.id) then
                    return false
                end
            end
            return true
        end, 25)

        local killed = lsp_kill_daemons()

        local started, started_names, skipped = {}, {}, {}
        local filetype = api.nvim_get_option_value("filetype", { buf = bufnr })
        for _, name in ipairs(names) do
            local config = vim.lsp.config[name]
            local applies = config and (not config.filetypes or vim.tbl_contains(config.filetypes, filetype))
            if config and applies and vim.lsp.is_enabled(name) then
                config = vim.deepcopy(config)
                local ok_start, id = pcall(vim.lsp.start, config, {
                    bufnr = bufnr,
                    reuse_client = config.reuse_client,
                    _root_markers = config.root_markers,
                })
                id = ok_start and id or nil
                if id then
                    started[#started + 1] = string.format("%s(%d)", name, id)
                    started_names[#started_names + 1] = name
                end
            elseif config then
                skipped[#skipped + 1] = name
            end
        end

        local msg = string.format(
            "LspRestart: stopped %d client(s), killed %d daemon(s), started %s",
            #targets,
            killed,
            #started > 0 and table.concat(started, ", ") or "none"
        )
        if #started_names > 0 then
            -- client 起进程后要等 initialize 完成才会 fold 到 buffer 上
            local attached = vim.wait(5000, function()
                for _, name in ipairs(started_names) do
                    if #vim.lsp.get_clients({ bufnr = bufnr, name = name }) == 0 then
                        return false
                    end
                end
                return true
            end, 50)
            if not attached then
                msg = msg .. " (not attached yet; check :lsp log)"
            end
        end
        if #unmatched > 0 then
            msg = msg .. " (no client named: " .. table.concat(unmatched, " ") .. ")"
        end
        if #skipped > 0 then
            msg = msg .. " (not applicable to current buffer: " .. table.concat(skipped, ", ") .. ")"
        end
        vim.notify(msg, vim.log.levels.INFO)
    end, {
        nargs = "*",
        desc = "Stop LSP clients, kill shared daemons, restart a client in the current buffer",
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
    }
