local fn = vim.fn

local m = {}

m.startup = function()
    require('packer').startup({
        function(use)
            -- Packer can manage itself
            use 'wbthomason/packer.nvim'

            -- common library
            use {
                { 'nvim-lua/plenary.nvim' },
                { 'nvim-lua/popup.nvim' },
                { 'nvim-tree/nvim-web-devicons' },
                { 'neovim/nvim-lspconfig' },
                { 'ray-x/lsp_signature.nvim' },
                { 'jose-elias-alvarez/null-ls.nvim' },
            }

            use {
                { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
                {
                    "williamboman/mason-lspconfig.nvim",
                    requires = {
                        "williamboman/mason.nvim",
                    }
                }
            }

            use {
                'hrsh7th/cmp-nvim-lsp',
                'hrsh7th/cmp-buffer',
                'hrsh7th/cmp-path',
                'hrsh7th/cmp-cmdline',
                'hrsh7th/nvim-cmp',
                --  For luasnip users.
                'L3MON4D3/LuaSnip',
                'saadparwaiz1/cmp_luasnip',
                "rafamadriz/friendly-snippets",

                'hrsh7th/cmp-emoji',
                'chrisgrieser/cmp-nerdfont',
                'hrsh7th/cmp-calc',
                'kristijanhusak/vim-dadbod-completion',
                'hrsh7th/cmp-nvim-lua',
                'onsails/lspkind.nvim',
            }

            use {
                { 'nvim-treesitter/nvim-treesitter',            run = ':TSUpdate' },
                -- { 'nvim-treesitter/playground' },
                { 'nvim-treesitter/nvim-treesitter-context' },
                { 'nvim-treesitter/nvim-treesitter-textobjects' },
                { 'RRethy/nvim-treesitter-textsubjects' },
                { 'RRethy/nvim-treesitter-endwise' },
                { 'p00f/nvim-ts-rainbow' },
            }

            use {
                {
                    'nvim-telescope/telescope.nvim',
                    tag = '0.1.x',
                    requires = {
                        { 'nvim-telescope/telescope-frecency.nvim' },
                        { 'nvim-telescope/telescope-fzf-native.nvim',  run = 'make' },
                        { 'nvim-telescope/telescope-file-browser.nvim' },
                        { 'kkharji/sqlite.lua' },
                    }
                },
                {
                    'nvim-telescope/telescope-project.nvim',
                    requires = {
                        -- auto change dir for workspace
                        'Abstract-IDE/penvim',
                    },
                },
                {
                    'dhruvmanila/telescope-bookmarks.nvim',
                    tag = '*',
                    -- Uncomment if the selected browser is Firefox, Waterfox or buku
                    requires = {
                        'tyru/open-browser.vim',
                    }
                },
                {
                    'renerocksai/telekasten.nvim',
                    requires = {
                        'renerocksai/calendar-vim'
                    }
                },
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
            use { 'nvim-tree/nvim-tree.lua' }
            use { 'uga-rosa/ccc.nvim' }
            use { 'gbprod/yanky.nvim' }
            use {
                -- 'sainnhe/gruvbox-material',
                'sainnhe/everforest',
            }
            use { 'iamcco/markdown-preview.nvim', run = 'cd app && ./install.sh' }
            use { 'm-demare/hlargs.nvim' }
            use { "folke/which-key.nvim" }
            use { 'Wansmer/treesj' }
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
            use { 'mizlan/iswap.nvim' }
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

local function load_mason()
    require("mason").setup({
        ui = {
            border = "rounded",
        }
    })
    require("mason-lspconfig").setup({
        -- A list of servers to automatically install if they're not already installed. Example: { "rust_analyzer@nightly", "sumneko_lua" }
        -- This setting has no relation with the `automatic_installation` setting.
        ensure_installed = {},
        -- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed.
        -- This setting has no relation with the `ensure_installed` setting.
        -- Can either be:
        --   - false: Servers are not automatically installed.
        --   - true: All servers set up via lspconfig are automatically installed.
        --   - { exclude: string[] }: All servers set up via lspconfig, except the ones provided in the list, are automatically installed.
        --       Example: automatic_installation = { exclude = { "rust_analyzer", "solargraph" } }
        automatic_installation = { exclude = {} },
    })
end

local function load_mason_tool()
    require('mason-tool-installer').setup {
        -- a list of all tools you want to ensure are installed upon
        -- start; they should be the names Mason uses for each tool
        ensure_installed = {
            -- you can turn off/on auto_update per tool
            { 'jq',                auto_update = true },
            { 'delve' },
            { 'shfmt' },
            { 'shellcheck' },
            { 'protolint' },
            { 'sql-formatter' },
            { 'jdtls' },
            { 'java-test' },
            { 'java-debug-adapter' },
            { 'yamlfmt' },
        },

        -- if set to true this will check each tool for updates. If updates
        -- are available the tool will be updated. This setting does not
        -- affect :MasonToolsUpdate or :MasonToolsInstall.
        -- Default: false
        auto_update = true,

        -- automatically install / update on startup. If set to false nothing
        -- will happen on startup. You can use :MasonToolsInstall or
        -- :MasonToolsUpdate to install tools and check for updates.
        -- Default: true
        run_on_start = true,

        -- set a delay (in ms) before the installation starts. This is only
        -- effective if run_on_start is set to true.
        -- e.g.: 5000 = 5 second delay, 10000 = 10 second delay, etc...
        -- Default: 0
        start_delay = 3000, -- 3 second delay

        -- Only attempt to install if 'debounce_hours' number of hours has
        -- elapsed since the last time Neovim was started. This stores a
        -- timestamp in a file named stdpath('data')/mason-tool-installer-debounce.
        -- This is only relevant when you are using 'run_on_start'. It has no
        -- effect when running manually via ':MasonToolsInstall' etc....
        -- Default: nil
        debounce_hours = nil, -- at least 5 hours between attempts to install/update
    }
end

m.install = function()
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        m.packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
            install_path })
    end

    vim.cmd [[packadd packer.nvim]]
    m.startup()

    load_mason()
    load_mason_tool()
end



return m
