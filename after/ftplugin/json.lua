local bo = vim.bo

do
    bo.tabstop     = 2
    bo.shiftwidth  = 2
    bo.softtabstop = 2

    -- rest.nvim 用 `gq` 格式化响应体，而 `gq` 依赖 formatexpr/formatprg。
    -- json 没有内置格式化器时它只能跳过，响应会保持 curl 返回的原始单行。
    if vim.fn.executable("jq") == 1 then
        bo.formatprg = "jq ."
    end
end
