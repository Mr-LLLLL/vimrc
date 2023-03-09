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
        }
    })
end

return m
