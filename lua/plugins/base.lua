local g = vim.g
local api = vim.api
local cmd = vim.cmd

return {
    {
        "sainnhe/everforest",
        lazy = false,    -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            cmd("colorscheme everforest")

            if g.colors_name == 'gruvbox-material' then
                api.nvim_set_hl(0, "NormalFloat", { bg = '#282828' })
                api.nvim_set_hl(0, "CustomBorder", { bg = '#282828', fg = '#d4be98' })
            elseif g.colors_name == 'everforest' then
                g.everforest_show_eob = 0
                g.everforest_diagnostic_virtual_text = 'colored'

                api.nvim_set_hl(0, "NormalFloat", { bg = '#2d353b' })
                api.nvim_set_hl(0, "CustomBorder", { bg = '#2d353b', fg = '#5c6a72' })
            end

            api.nvim_set_hl(0, "FloatBorder", { link = 'CustomBorder' })
            api.nvim_set_hl(0, "TelescopeBorder", { link = 'CustomBorder' })
            api.nvim_set_hl(0, "CustomVirtualText", { fg = '#5a5b5a', italic = true })
        end
    },
    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
        config = function()
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
    },
    {
        'nvim-lua/plenary.nvim',
        lazy = true,
    },
    {
        'nvim-lua/popup.nvim',
        lazy = true,
    },
}
