local m = {}

m.setup = function()
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

return m
