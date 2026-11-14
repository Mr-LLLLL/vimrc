local o = vim.o
local km = vim.keymap
local g = vim.g

-- WSL has no clipboard tool of its own, so +/* silently do nothing out of the box.
-- Prefer win32yank.exe when it is installed, otherwise use the clip.exe/powershell
-- pair every WSL distro ships, and fall back to OSC 52 for terminals that support it.
local function setup_wsl_clipboard()
    if vim.fn.has("wsl") ~= 1 then
        return
    end

    if vim.fn.executable("win32yank.exe") == 1 then
        g.clipboard = {
            name = "wsl-win32yank",
            copy = {
                ["+"] = { "win32yank.exe", "-i", "--crlf" },
                ["*"] = { "win32yank.exe", "-i", "--crlf" },
            },
            paste = {
                ["+"] = { "win32yank.exe", "-o", "--lf" },
                ["*"] = { "win32yank.exe", "-o", "--lf" },
            },
            cache_enabled = 1,
        }
    elseif vim.fn.executable("clip.exe") == 1 and vim.fn.executable("powershell.exe") == 1 then
        local paste = {
            "powershell.exe",
            "-NoLogo",
            "-NoProfile",
            "-c",
            '[Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        }
        g.clipboard = {
            name = "wsl-clip",
            copy = {
                ["+"] = { "clip.exe" },
                ["*"] = { "clip.exe" },
            },
            paste = {
                ["+"] = paste,
                ["*"] = paste,
            },
            -- clip.exe does not stick around, so there is nothing to cache against.
            cache_enabled = 0,
        }
    else
        g.clipboard = "osc52"
    end
end

local function load_base()
    setup_wsl_clipboard()
    g.mapleader                          = ","
    g.custom_blend                       = 10

    g.everforest_show_eob                = 0
    g.everforest_diagnostic_virtual_text = 'colored'
    g.everforest_enable_italic           = 1

    o.winblend                           = g.custom_blend
    o.pumblend                           = g.custom_blend
    o.number                             = true
    -- o.rnu                                = true
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
    o.conceallevel                       = 1
    o.showtabline                        = 2
    o.lcs                                = "tab:  "

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

    -- Terminals cannot report <C-/> as-is: it usually arrives as <C-_> (0x1F), and with
    -- the Windows Terminal `sendInput` snippet it arrives as a CSI-u sequence that nvim
    -- decodes back into <C-/>. Map both so "/" search works outside of neovide as well.
    local function start_search()
        vim.fn.feedkeys("/", "n")
    end
    km.set({ "n", "x" }, "<C-/>", start_search, { noremap = true, silent = true, desc = "Search" })
    km.set({ "n", "x" }, "<C-_>", start_search, { noremap = true, silent = true, desc = "Search (ctrl-/ fallback)" })
end

local function load_neovide()
    if g.neovide == nil then
        return
    end

    g.neovide_fullscreen                     = true
    g.neovide_confirm_quit                   = true
    g.neovide_floating_blur_amount_x         = 0.0
    g.neovide_floating_blur_amount_y         = 0.0
    g.neovide_floating_shadow                = false
    g.neovide_floating_z_height              = 10
    g.neovide_light_angle_degrees            = 45
    g.neovide_light_radius                   = 5
    g.neovide_opacity                        = 1.0
    g.neovide_scroll_animation_length        = 0.3
    g.neovide_cursor_animation_length        = 0.3
    g.neovide_scroll_animation_far_lines     = 1
    g.neovide_cursor_trail_size              = 0.8
    g.neovide_cursor_antialiasing            = true
    g.neovide_cursor_unfocused_outline_width = 0.125
    g.neovide_hide_mouse_when_typing         = true
    g.neovide_underline_automatic_scaling    = true
    g.neovide_refresh_rate                   = 60
    g.neovide_refresh_rate_idle              = 5
    g.neovide_remember_window_size           = true
    g.neovide_profiler                       = false
    g.neovide_cursor_vfx_mode                = "pixiedust"
    g.neovide_cursor_vfx_particle_density    = 20.0
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
        function() g.neovide_fullscreen = not g.neovide_fullscreen end,
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
        },
    })

    vim.api.nvim_set_hl(0, "LazyBackdrop", { bg = require("common").colors.CustomBorderBg })
end

local function init()
    load_base()
    load_neovide()
    load_lazy()
end
init()
