local o = vim.o
local g = vim.g
local api = vim.api
local cmd = vim.cmd

local m = {}

local function load_devicons()
    require 'nvim-web-devicons'.setup {
        -- your personnal icons can go here (to override)
        -- you can specify color or cterm_color instead of specifying both of them
        -- DevIcon will be appended to `name`
        override = {
            zsh = {
                icon = "",
                color = "#428850",
                cterm_color = "65",
                name = "Zsh"
            }
        },
        -- globally enable different highlight colors per icon (default to true)
        -- if set to false all icons will have the default icon's color
        color_icons = true,
        -- globally enable default icons (default to false)
        -- will get overriden by `get_icons` option
        default = true,
    }
end

local function load_colorscheme()
    cmd("colorscheme everforest")

    if g.colors_name == 'gruvbox-material' then
        api.nvim_set_hl(0, "NormalFloat", { bg = '#282828' })
        api.nvim_set_hl(0, "CustomBorder", { bg = '#282828', fg = '#d4be98' })
    elseif g.colors_name == 'everforest' then
        api.nvim_set_hl(0, "NormalFloat", { bg = '#2d353b' })
        api.nvim_set_hl(0, "CustomBorder", { bg = '#2d353b', fg = '#5c6a72' })
    end

    api.nvim_set_hl(0, "FloatBorder", { link = 'CustomBorder' })
    api.nvim_set_hl(0, "TelescopeBorder", { link = 'CustomBorder' })
    api.nvim_set_hl(0, "CustomVirtualText", { fg = '#5a5b5a', italic = true })
end

local function load_base_value()
    g.mapleader = ","
    g.custom_blend = 10

    g.everforest_show_eob = 0
    g.everforest_diagnostic_virtual_text = 'colored'
end

local function load_base_option()
    o.winblend       = g.custom_blend
    o.pumblend       = g.custom_blend
    o.number         = true
    o.rnu            = false
    o.hidden         = true
    o.cmdheight      = 0
    o.updatetime     = 300
    o.shortmess      = o.shortmess .. "c"
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
    o.scrolloff      = 5

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

m.setup = function()
    require("core.auto_ins").install()

    load_base_value()
    load_base_option()
    load_colorscheme()
    load_devicons()

    require("core.lsp").setup()
    require("core.treesiter").setup()
    require("core.tele").setup()
    require("core.ui").setup()
    require("core.assist").setup()
    require("core.debug").setup()
    require("core.extension").setup()
    require("core.null_ls").setup()
end

return m
