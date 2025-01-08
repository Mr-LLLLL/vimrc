return {
    {
        'milanglacier/minuet-ai.nvim',
        lazy = true,
        dependencies = {
            { 'nvim-lua/plenary.nvim' },
        },
        config = function()
            require('minuet').setup({
                notify = "error",
                provider = "openai_fim_compatible",
                provider_options = {
                    openai_fim_compatible = {
                        model = 'deepseek-coder',
                        end_point = 'https://api.deepseek.com/beta/completions',
                        name = 'Deepseek',
                        api_key = "OPENAI_API_KEY",
                        stream = true,
                        optional = {
                            stop = nil,
                            max_tokens = nil,
                        },
                    },
                },
            })
        end
    },
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        keys = {
            {
                "<space>/",
                function()
                    require("avante").toggle()
                end,
                mode = { "n" },
                { noremap = true, silent = true },
                desc = "Avante Toggle"
            },
        },
        version = false, -- set this to "*" if you want to always pull the latest change, false to update on release
        build = "make",
        dependencies = {
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
            {
                -- Make sure to set this up properly if you have lazy=true
                'MeanderingProgrammer/render-markdown.nvim',
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
        },
        config = function()
            require('avante').setup({
                provider = "openai",
                auto_suggestions_provider = "openai", -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
                openai = {
                    endpoint = "https://api.deepseek.com/v1",
                    model = "deepseek-coder",
                    timeout = 30000, -- Timeout in milliseconds
                    temperature = 0,
                    max_tokens = 4096,
                },
                behaviour = {
                    auto_suggestions = false, -- Experimental stage
                    auto_set_highlight_group = true,
                    auto_set_keymaps = true,
                    auto_apply_diff_after_generation = false,
                    support_paste_from_clipboard = false,
                    minimize_diff = true,
                },
                mappings = {
                    --- @class AvanteConflictMappings
                    diff = {
                        ours = "co",
                        theirs = "ct",
                        all_theirs = "ca",
                        both = "cb",
                        cursor = "cc",
                        next = "]x",
                        prev = "[x",
                    },
                    suggestion = {
                        accept = "<M-y>",
                        next = "<M-]>",
                        prev = "<M-[>",
                        dismiss = "<C-]>",
                    },
                    jump = {
                        next = "]]",
                        prev = "[[",
                    },
                    submit = {
                        normal = "<CR>",
                        insert = "<C-CR>",
                    },
                    ask = "<leader>aa",
                    edit = "<leader>ae",
                    refresh = "<leader>ar",
                    focus = "<leader>af",
                    toggle = {
                        default = "<space>/",
                        debug = "<leader>ad",
                        hint = "<leader>ah",
                        suggestion = "<leader>as",
                        repomap = "<leader>aR",
                    },
                    sidebar = {
                        apply_all = "A",
                        apply_cursor = "a",
                        switch_windows = "<Tab>",
                        reverse_switch_windows = "<S-Tab>",
                    },
                    files = {
                        add_current = "<leader>ac", -- Add current buffer to selected files
                    },
                },
                windows = {
                    ask = {
                        floating = false,        -- Open the 'AvanteAsk' prompt in a floating window
                        border = "rounded",
                        start_insert = true,     -- Start insert mode when opening the ask window
                        ---@alias AvanteInitialDiff "ours" | "theirs"
                        focus_on_apply = "ours", -- which diff to focus after applying
                    },
                }

            })

            vim.api.nvim_set_hl(0, "AvanteInlineHint", { link = 'NonText' })
            vim.api.nvim_create_autocmd(
                { "Filetype" },
                {
                    pattern = { "AvanteInput", "Avante" },
                    callback = function(opts)
                        vim.keymap.set('i', "<c-c>", function()
                            -- in case occur error
                            require('blink.cmp.completion.list').hide()
                            vim.cmd("quit!")
                            vim.cmd("stopinsert")
                        end, { noremap = true, silent = true, buffer = opts.buf })
                    end,
                    group = vim.api.nvim_create_augroup("AvanteAutocmd", { clear = true }),
                }
            )
        end
    },
    {
        "David-Kunz/gen.nvim",
        cmd = "Gen",
        config = function()
            require("gen").setup {
                model = "llama3.1",     -- The default model to use.
                host = "localhost",     -- The host running the Ollama service.
                port = "11434",         -- The port on which the Ollama service is listening.
                display_mode = "float", -- The display mode. Can be "float" or "split".
                show_prompt = true,     -- Shows the Prompt submitted to Ollama.
                show_model = true,      -- Displays which model you are using at the beginning of your chat session.
                no_auto_close = true,   -- Never closes the window automatically.
                init = function(options) pcall(io.popen, "ollama serve > /dev/null 2>&1 &") end,
                -- Function to initialize Ollama
                command = function(options)
                    return "curl --silent --no-buffer -X POST http://" ..
                        options.host .. ":" .. options.port .. "/api/chat -d $body"
                end,
                -- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
                -- This can also be a command string.
                -- The executed command must return a JSON object with { response, context }
                -- (context property is optional).
                -- list_models = '<omitted lua function>', -- Retrieves a list of model names
                debug = false -- Prints errors and the command which is run.
            }
        end
    },
    -- {
    --     "sourcegraph/sg.nvim",
    --     cmd = { "Cody", "Sourcegraph" },
    --     dependencies = { "nvim-lua/plenary.nvim", --[[ "nvim-telescope/telescope.nvim ]] },
    --     config = function()
    --         require("sg").setup {
    --             on_attach = require("common").lsp_on_attach,
    --         }
    --     end
    -- },
    {
        "Exafunction/codeium.nvim",
        cmd = "Codeium",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("codeium").setup({})
        end
    },
    {
        "supermaven-inc/supermaven-nvim",
        cmd = "SupermavenUseFree",
        config = function()
            require("supermaven-nvim").setup({
                keymaps = {
                    accept_suggestion = "<c-y>",
                    clear_suggestion = "<C-]>",
                    accept_word = "<A-y>",
                },
            })
        end,
    },
}
