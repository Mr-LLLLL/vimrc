local api = vim.api
local cmd = vim.cmd

return {
    {
        "sainnhe/everforest",
        lazy = false,    -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            cmd("colorscheme everforest")
            vim.api.nvim_set_hl(0, "NonText", {
                fg = require("common").colors.NonTextFg,
                ctermfg = require("common").colors.NonTextCtermFg,
                italic = true,
            })

            api.nvim_set_hl(0, "NormalFloat", { bg = require("common").colors.CustomBorderBg })
            api.nvim_set_hl(0, "CustomBorder",
                { bg = require("common").colors.CustomBorderBg, fg = require("common").colors.CustomBorderFg })

            api.nvim_set_hl(0, "FloatBorder", { link = 'CustomBorder' })
            api.nvim_set_hl(0, "debugPC", { bg = require("common").colors.CustomBorderBg })
            api.nvim_set_hl(0, "WinBarNC", { bg = require("common").colors.CustomBorderBg })
            api.nvim_set_hl(0, "TelescopeBorder", { link = 'CustomBorder' })
            api.nvim_set_hl(0, "Visual", { bg = require("common").colors.VisualBg, italic = false, nocombine = true })

            -- Snacks floats (scratch picker, input/list/preview panes) should use the same
            -- float palette as Telescope and treesitter-context instead of everforest's
            -- `SnacksPicker -> Normal` / `SnacksPickerBorder -> Grey` links. Keep the
            -- background on CustomBorderBg and the border on CustomBorder so all floating
            -- panels line up with the rest of the theme.
            local colors = require("common").colors
            local normal_fg = api.nvim_get_hl(0, { name = "Normal" }).fg

            local function set_hl(group, opts)
                opts.default = false
                api.nvim_set_hl(0, group, opts)
            end

            for _, group in ipairs({
                "SnacksPicker",
                "SnacksPickerBox",
                "SnacksPickerList",
                "SnacksPickerInput",
                "SnacksPickerPreview",
            }) do
                set_hl(group, { bg = colors.CustomBorderBg, fg = normal_fg })
            end

            for _, group in ipairs({
                "SnacksPickerBorder",
                "SnacksPickerBoxBorder",
                "SnacksPickerListBorder",
                "SnacksPickerInputBorder",
                "SnacksPickerPreviewBorder",
            }) do
                set_hl(group, { link = "CustomBorder" })
            end

            for _, group in ipairs({
                "SnacksPickerTitle",
                "SnacksPickerBoxTitle",
                "SnacksPickerListTitle",
                "SnacksPickerInputTitle",
                "SnacksPickerPreviewTitle",
                "SnacksScratchTitle",
            }) do
                set_hl(group, { link = "FloatTitle" })
            end
            set_hl("SnacksScratch", { link = "NormalFloat" })
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
