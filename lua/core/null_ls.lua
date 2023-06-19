local m = {}

m.setup = function()
    local null_ls = require("null-ls")

    null_ls.setup({
        sources = {
            null_ls.builtins.formatting.protolint,
            null_ls.builtins.diagnostics.protolint,
            null_ls.builtins.formatting.sql_formatter.with({
                extra_filetypes = { "mysql" },
            }),
            null_ls.builtins.formatting.shfmt,
            null_ls.builtins.code_actions.shellcheck,
            -- null_ls.builtins.diagnostics.shellcheck, // bashls will call shellcheck to diagnostics
            null_ls.builtins.formatting.yamlfmt,
            null_ls.builtins.formatting.black,
        }
    })
end

return m
