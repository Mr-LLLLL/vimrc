return {
    {
        'lewis6991/gitsigns.nvim',
        event = "VeryLazy",
        config = function()
            require('gitsigns').setup({
                signs = {
                    add          = { hl = 'GitSignsAdd', text = '│', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
                    change       = {
                        hl = 'GitSignsChange',
                        text = '│',
                        numhl = 'GitSignsChangeNr',
                        linehl = 'GitSignsChangeLn'
                    },
                    delete       = {
                        hl = 'GitSignsDelete',
                        text = '_',
                        numhl = 'GitSignsDeleteNr',
                        linehl = 'GitSignsDeleteLn'
                    },
                    topdelete    = {
                        hl = 'GitSignsDelete',
                        text = '‾',
                        numhl = 'GitSignsDeleteNr',
                        linehl = 'GitSignsDeleteLn'
                    },
                    changedelete = {
                        hl = 'GitSignsChange',
                        text = '~',
                        numhl = 'GitSignsChangeNr',
                        linehl = 'GitSignsChangeLn'
                    },
                    untracked    = { hl = 'GitSignsAdd', text = '┆', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
                },
                current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
                current_line_blame_opts = {
                    virt_text = false,
                    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
                    delay = 500,
                    ignore_whitespace = false,
                },
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns

                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end

                    -- Navigation
                    map('n', ']c', function()
                        if vim.wo.diff then return ']c' end
                        vim.schedule(function() gs.next_hunk() end)
                        return '<Ignore>'
                    end, { expr = true, desc = "Gitsigns forward hunk" })

                    map('n', '[c', function()
                        if vim.wo.diff then return '[c' end
                        vim.schedule(function() gs.prev_hunk() end)
                        return '<Ignore>'
                    end, { expr = true, desc = "Gitsigns backward hunk" })

                    -- Actions
                    map({ 'n', 'v' }, '<leader>gs', ':Gitsigns stage_hunk<CR>', { desc = "Gitsigns stage hunk" })
                    map({ 'n', 'v' }, '<leader>gr', ':Gitsigns reset_hunk<CR>', { desc = "Gitsigns reset hunk" })
                    map('n', '<leader>gS', gs.stage_buffer, { desc = "Gitsigns stage buffer" })
                    map('n', '<leader>gu', gs.undo_stage_hunk, { desc = "Gitsigns undo stage hunk" })
                    map('n', '<leader>gR', gs.reset_buffer, { desc = "Gitsigns reset buffer" })
                    map('n', '<leader>gp', gs.preview_hunk, { desc = "Gitsigns preview hunk" })
                    map('n', '<leader>gb', function() gs.blame_line { full = true } end, { desc = "Gitsigns blame line" })
                    -- map('n', '<leader>gB', gs.toggle_current_line_blame, { desc = "Gitsigns toggle current line blame" })
                    -- map('n', '<leader>gd', gs.diffthis)
                    map('n', '<leader>gd', function() gs.diffthis('~') end, { desc = "Gitsigns diff" })
                    map('n', '<leader>gD', gs.toggle_deleted, { desc = "Gitsigns toggle deleted" })

                    -- Text object
                    map({ 'o', 'x' }, 'ig', '<esc><cmd>Gitsigns select_hunk<CR>')
                end
            })

            local old = require("lualine").get_config()
            table.insert(old.tabline.lualine_x, 1, {
                function() return vim.b.gitsigns_blame_line end,
                cond = function() return vim.b.gitsigns_blame_line ~= nil end,
            })
            require("lualine").setup(old)
        end
    },
    {
        'junegunn/gv.vim',
        cmd = "GV",
        dependencies = {
            'tpope/vim-fugitive',
        }
    },
    {
        'tpope/vim-fugitive',
        cmd = "G",
    }
}
