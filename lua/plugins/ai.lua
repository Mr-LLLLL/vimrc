return {
    {
        "David-Kunz/gen.nvim",
        cmd = "Gen",
        keys = {
            { "<space>l", ":Gen<CR>", mode = { "n", "x" }, { noremap = true, silent = true }, desc = "Gen Nvim" }
        },
        config = function()
            require("gen").setup {
                model = "llama2:13b",                            -- The default model to use.
                host = require("private.private").gen_nvim_host, -- The host running the Ollama service.
                port = "11434",                                  -- The port on which the Ollama service is listening.
                display_mode = "float",                          -- The display mode. Can be "float" or "split".
                show_prompt = true,                              -- Shows the Prompt submitted to Ollama.
                show_model = true,                               -- Displays which model you are using at the beginning of your chat session.
                no_auto_close = true,                            -- Never closes the window automatically.
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
    {
        "sourcegraph/sg.nvim",
        cmd = "Cody",
        dependencies = { "nvim-lua/plenary.nvim", --[[ "nvim-telescope/telescope.nvim ]] },
        config = function()
            require("sg").setup {
                on_attach = require("common").lsp_on_attack,
            }
        end
    },
    -- {
    --     "Exafunction/codeium.nvim",
    --     lazy = true,
    --     dependencies = {
    --         "nvim-lua/plenary.nvim",
    --     },
    --     config = function()
    --         require("codeium").setup({})
    --     end
    -- },
}
