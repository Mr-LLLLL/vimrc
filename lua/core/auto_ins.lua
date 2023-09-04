local m = {}

m.startup = function()
    require('packer').startup({
        function(use)
            -- Packer can manage itself
            use 'wbthomason/packer.nvim'

            use {
                -- { 'nvim-treesitter/playground' },
            }

            use {
            }

            use {
                { 'mfussenegger/nvim-dap' },
                { 'rcarriga/nvim-dap-ui' },
                { 'theHamsta/nvim-dap-virtual-text' },
            }

            use {
                { 'lewis6991/gitsigns.nvim' },
                {
                    'junegunn/gv.vim',
                    requires = {
                        'tpope/vim-fugitive',
                    }
                },
            }

            -- Uilts
            use {
                "vinnymeller/swagger-preview.nvim",
                run = "npm install --localtion=global swagger-ui-watcher",
            }
            use { 'dpayne/CodeGPT.nvim' }
            use { 'uga-rosa/ccc.nvim' }
            use {
                -- 'sainnhe/gruvbox-material',
                'sainnhe/everforest',
            }
            use { 'iamcco/markdown-preview.nvim', run = 'cd app && ./install.sh' }
            use { "folke/which-key.nvim" }
            use { 'michaelb/sniprun', run = 'bash ./install.sh' }
            use { 'lukas-reineke/indent-blankline.nvim' }
            use {
                'numToStr/Comment.nvim',
                "folke/todo-comments.nvim",
            }
            use { 'windwp/nvim-spectre' }
            use { 'MR-LLLLL/interestingwords.nvim' }
            use { 'kylechui/nvim-surround', tag = "*" }
            -- it's not smarter than auto-pairs
            use { "windwp/nvim-autopairs" }
            -- use { 'jiangmiao/auto-pairs' }
            use { 'junegunn/vim-easy-align' }
            use { 'mg979/vim-visual-multi' }
            use { 'akinsho/toggleterm.nvim', tag = "*" }
            use {
                'nvim-lualine/lualine.nvim',
                requires = {
                    'linrongbin16/lsp-progress.nvim'
                },
            }
            use { 'tpope/vim-repeat' }
            use { 'voldikss/vim-browser-search' }
            use { 'glepnir/dashboard-nvim' }
            -- use { 'sbdchd/neoformat' }
            use { 'ggandor/leap.nvim' }
            use { 'potamides/pantran.nvim' }
            use { 'rest-nvim/rest.nvim' }
            -- use { 'gelguy/wilder.nvim' }
            use {
                "folke/noice.nvim",
                requires = {
                    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
                    "MunifTanjim/nui.nvim",
                    -- OPTIONAL:
                    --   `nvim-notify` is only needed, if you want to use the notification view.
                    --   If not available, we use `mini` as the fallback
                    "rcarriga/nvim-notify",
                }
            }
            use {
                {
                    'mfussenegger/nvim-jdtls',
                },
                {
                    'ray-x/go.nvim',
                    requires = {
                        'ray-x/guihua.lua' -- recommanded if need floating window support
                    }
                },
                {
                    'simrat39/rust-tools.nvim'
                },
            }
            use { 'sindrets/diffview.nvim' }
            use { 'ThePrimeagen/refactoring.nvim' }

            -- UI
            -- use { "folke/trouble.nvim" }
            use { 'eandrju/cellular-automaton.nvim' }
            use { 'stevearc/dressing.nvim' }
            use { "RRethy/vim-illuminate" }
            use { "glepnir/lspsaga.nvim", branch = "main" }
            use { "Bekaboo/dropbar.nvim" }
            use {
                'kristijanhusak/vim-dadbod-ui',
                requires = {
                    'tpope/vim-dadbod',
                }
            }
            use { 'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async' }

            -- Automatically set up your configuration after cloning packer.nvim
            -- Put this at the end after all plugins
            if m.packer_bootstrap then
                require('packer').sync()
            end
        end,
        config = {
            display = {
                open_fn = function()
                    return require('packer.util').float({ border = 'rounded' })
                end
            }
        }
    })
end

m.install = function()
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        m.packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
            install_path })
    end

    vim.cmd [[packadd packer.nvim]]
    m.startup()
end



return m
