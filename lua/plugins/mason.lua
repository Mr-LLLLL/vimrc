return {
    {
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        lazy = false,
        dependencies = {
            "williamboman/mason.nvim",
        },
        config = function()
            require('mason-tool-installer').setup {
                -- a list of all tools you want to ensure are installed upon
                -- start; they should be the names Mason uses for each tool
                ensure_installed = {
                    -- you can turn off/on auto_update per tool
                    { 'jq',                    auto_update = true },
                    { 'delve' },
                    { 'shfmt' },
                    { 'shellcheck' },
                    { 'protolint' },
                    { 'sql-formatter' },
                    { 'jdtls' },
                    { 'java-test' },
                    { 'java-debug-adapter' },
                    { 'yamlfmt' },
                    { 'black' },
                    { 'gopls' },
                    { 'lua-language-server' },
                    { 'buf-language-server' },
                    { 'json-lsp' },
                    { 'yaml-language-server' },
                    { 'taplo' },
                    { 'pyright' },
                    { 'clangd' },
                    { 'bash-language-server' },
                    { 'vim-language-server' },
                    { 'gradle-language-server' },
                    { 'rust-analyzer' },
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
    },
    -- {
    --     "williamboman/mason-lspconfig.nvim",
    --     dependencies = {
    --         "williamboman/mason.nvim",
    --     },
    --     config = function()
    --         require("mason-lspconfig").setup({
    --             -- A list of servers to automatically install if they're not already installed. Example: { "rust_analyzer@nightly", "sumneko_lua" }
    --             -- This setting has no relation with the `automatic_installation` setting.
    --             ensure_installed = {},
    --             -- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed.
    --             -- This setting has no relation with the `ensure_installed` setting.
    --             -- Can either be:
    --             --   - false: Servers are not automatically installed.
    --             --   - true: All servers set up via lspconfig are automatically installed.
    --             --   - { exclude: string[] }: All servers set up via lspconfig, except the ones provided in the list, are automatically installed.
    --             --       Example: automatic_installation = { exclude = { "rust_analyzer", "solargraph" } }
    --             automatic_installation = true,
    --         })
    --     end
    -- },
    {
        "williamboman/mason.nvim",
        lazy = true,
        config = function()
            require("mason").setup({
                ui = {
                    border = "rounded",
                }
            })
        end
    }
}
