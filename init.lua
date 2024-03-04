local o = vim.o
local km = vim.keymap
local g = vim.g

local function load_base()
    g.mapleader                          = ","
    g.custom_blend                       = 10

    g.everforest_show_eob                = 0
    g.everforest_diagnostic_virtual_text = 'colored'

    o.winblend                           = g.custom_blend
    o.pumblend                           = g.custom_blend
    o.number                             = true
    o.rnu                                = true
    o.hidden                             = true
    o.cmdheight                          = 0
    o.updatetime                         = 300
    o.shortmess                          = o.shortmess .. "c"
    -- o.foldcolumn     = '1'
    o.foldenable                         = true
    o.foldlevel                          = 99
    o.foldlevelstart                     = 99
    o.smartcase                          = true
    o.ignorecase                         = true
    o.mouse                              = "a"
    o.termguicolors                      = true
    o.clipboard                          = "unnamed,unnamedplus"
    o.background                         = "dark"
    o.wildmode                           = "longest,full"
    o.laststatus                         = 3
    -- o.scrolloff      = 5

    o.tabstop                            = 4
    o.expandtab                          = true
    o.autoindent                         = true
    o.shiftwidth                         = 4
    o.softtabstop                        = 4

    o.backup                             = false
    o.undofile                           = false
    o.swapfile                           = false
    o.writebackup                        = false

    o.list                               = true
end

local function load_neovide()
    if g.neovide == nil then
        return
    end
    vim.api.nvim_set_hl(0, "NonText", { fg = "#4f585e", italic = true })

    -- set by neovide config.toml
    -- o.guifont                                = "JetBrainsMono Nerd Font Mono:h10"
    g.neovide_fullscreen                     = true
    g.neovide_confirm_quit                   = true
    g.neovide_floating_blur_amount_x         = 0.0
    g.neovide_floating_blur_amount_y         = 0.0
    g.neovide_floating_shadow                = false
    g.neovide_floating_z_height              = 10
    g.neovide_light_angle_degrees            = 45
    g.neovide_light_radius                   = 5
    g.neovide_transparency                   = 1.0
    g.neovide_scroll_animation_length        = 0.3
    g.neovide_scroll_animation_far_lines     = 1
    g.neovide_cursor_trail_size              = 0.8
    g.neovide_cursor_antialiasing            = true
    -- g.neovide_cursor_animation_length=1.00
    g.neovide_cursor_unfocused_outline_width = 0.125
    g.neovide_hide_mouse_when_typing         = true
    g.neovide_underline_automatic_scaling    = true
    g.neovide_refresh_rate                   = 60
    g.neovide_refresh_rate_idle              = 5
    g.neovide_remember_window_size           = true
    g.neovide_profiler                       = false
    g.neovide_cursor_vfx_mode                = "pixiedust"
    g.neovide_cursor_vfx_particle_density    = 50.0
    g.neovide_cursor_vfx_opacity             = 200.0
    g.neovide_cursor_vfx_particle_phase      = 1.5
    g.neovide_cursor_vfx_particle_curl       = 1.0
    g.neovide_cursor_vfx_particle_lifetime   = 1.2
    g.neovide_cursor_vfx_particle_speed      = 10.0
    g.neovide_cursor_animate_command_line    = true
    g.neovide_cursor_animate_in_insert_mode  = true
    g.neovide_padding_top                    = 0
    g.neovide_padding_bottom                 = 0
    g.neovide_padding_right                  = 0
    g.neovide_padding_left                   = 0

    km.set({ 'i' }, "<C-S-v>", "<C-r>*", { noremap = true, silent = true })
    km.set({ 'n' }, "<C-S-v>", '"*p', { noremap = true, silent = true })
    km.set({ 'c' }, "<C-S-v>", "<C-r>*", { noremap = true, silent = false })
    km.set({ 't' }, "<C-S-v>", '<C-\\><C-N>"*pi', { noremap = false, silent = true })

    km.set(
        { 'n' },
        "<F11>",
        function() if g.neovide_fullscreen then g.neovide_fullscreen = false else g.neovide_fullscreen = true end end,
        { noremap = true, silent = true, expr = true, desc = "full screen for neovide" }
    )

    g.neovide_scale_factor = 1.0
    local function scale(delta)
        g.neovide_scale_factor = g.neovide_scale_factor * delta
    end

    km.set({ 'n' }, "<c-=>", function() scale(1.25) end,
        { noremap = true, silent = true, expr = true, desc = "scale in for neovide" })
    km.set({ 'n' }, "<c-->", function() scale(1 / 1.25) end,
        { noremap = true, silent = true, expr = true, desc = "scale out for neovide" })
    -- only neovide support <c-/>, don't suport this in neovim
    km.set({ 'n', 'x' }, "<c-/>", "/", { noremap = true, silent = true, desc = "search" })
end

local function load_lazy()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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


    require("lazy").setup("plugins", {
        defaults = {
            lazy = false,
        },
        dev = {
            path = "~/workspace/personal/project"
        },
        ui = {
            border = "rounded",
        }
    })
end

local function init()
    load_base()
    load_neovide()
    load_lazy()
end
init()
