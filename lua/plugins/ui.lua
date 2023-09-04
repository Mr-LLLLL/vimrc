local km = vim.keymap

local load_key = "<space>q"

return {
    {
        'nvim-tree/nvim-tree.lua',
        lazy = true,
        keys = {
            { load_key, nil }
        },
        config = function()
            local glyphs = require("core.common").glyphs
            local on_attach = function(bufnr)
                local tree_api = require('nvim-tree.api')

                tree_api.config.mappings.default_on_attach(bufnr)

                local function opts(desc)
                    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end

                km.del('n', "<C-e>", { buffer = bufnr })
                km.del('n', "<C-x>", { buffer = bufnr })
                km.set('n', '<C-s>', tree_api.node.open.horizontal, opts('Open: Horizontal Split'))
            end
            require("nvim-tree").setup({
                on_attach = on_attach,
                sync_root_with_cwd = true,
                respect_buf_cwd = true,
                sort_by = "name",
                view = {
                    adaptive_size = true,
                    preserve_window_proportions = true,
                },
                renderer = {
                    group_empty = false,
                    icons = {
                        glyphs = {
                            modified = glyphs["modified"],
                            git = {
                                unstaged = glyphs["modified"],
                                staged = glyphs["added"],
                                unmerged = glyphs["unmerged"],
                                renamed = glyphs["renamed"],
                                untracked = glyphs["untracked"],
                                deleted = glyphs["deleted"],
                                ignored = glyphs["ignored"],
                            },
                        },
                    }
                },
                git = {
                    enable = true,
                    ignore = false,
                    show_on_dirs = true,
                    show_on_open_dirs = true,
                    timeout = 400,
                },
                modified = {
                    enable = true,
                    show_on_dirs = true,
                    show_on_open_dirs = true,
                },
                update_focused_file = {
                    enable = true,
                    update_root = true,
                    ignore_list = {},
                },
                filters = {
                    dotfiles = true,
                    git_clean = false,
                    no_buffer = false,
                    custom = {},
                    exclude = {},
                },
            })

            km.set("n", load_key, "<cmd>NvimTreeFindFileToggle<cr>", { noremap = true, silent = true })

            if vim.g.colors_name == 'gruvbox-material' then
                api.nvim_set_hl(0, "NvimTreeCursorLine", { bg = '#3c3836' })
            elseif vim.g.colors_name == 'everforest' then
                api.nvim_set_hl(0, "NvimTreeCursorLine", { bg = '#374145' })
            end
            api.nvim_set_hl(0, "NvimTreeNormal", { link = 'Normal' })
            api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { link = 'EndOfBuffer' })
        end
    },
}
