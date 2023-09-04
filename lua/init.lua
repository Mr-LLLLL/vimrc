local o = vim.o
local g = vim.g
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

local function load_base()
    g.mapleader      = ","
    g.custom_blend   = 10

    o.winblend       = g.custom_blend
    o.pumblend       = g.custom_blend
    o.number         = true
    o.rnu            = false
    o.hidden         = true
    o.cmdheight      = 0
    o.updatetime     = 300
    o.shortmess      = o.shortmess .. "c"
    -- o.foldcolumn     = '1'
    o.foldenable     = true
    o.foldlevel      = 99
    o.foldlevelstart = 99
    o.smartcase      = true
    o.ignorecase     = true
    o.mouse          = "a"
    o.termguicolors  = true
    o.clipboard      = "unnamed,unnamedplus"
    o.background     = "dark"
    o.wildmode       = "longest,full"
    o.laststatus     = 3
    -- o.scrolloff      = 5

    o.tabstop        = 4
    o.expandtab      = true
    o.autoindent     = true
    o.shiftwidth     = 4
    o.softtabstop    = 4

    o.backup         = false
    o.undofile       = false
    o.swapfile       = false
    o.writebackup    = false

    o.list           = true
end

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

load_base()

require("lazy").setup("plugins", {
    default = {
        lazy = false,
    },
    ui = {
        border = "rounded"
    }
})
