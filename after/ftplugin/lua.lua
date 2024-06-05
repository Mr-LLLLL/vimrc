local bo = vim.bo
local o = vim.o

do
    bo.tabstop      = 4
    bo.shiftwidth   = 4
    bo.softtabstop  = 4

    o.commentstring = "-- %s"
end
