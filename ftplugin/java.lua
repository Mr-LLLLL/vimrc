local function load_java()
    -- local on_attach =
    local on_attach = function(client, bufnr)
        require("core.common").lsp_on_attack(client, bufnr)
        require('jdtls').setup_dap({ hotcodereplace = 'auto' })
        require("jdtls.setup"):add_commands()
    end

    -- This bundles definition is the same as in the previous section (java-debug installation)
    local bundles = {
        vim.fn.glob(
            "/home/ubuntu/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
            1),
    };

    -- This is the new part
    vim.list_extend(
        bundles,
        vim.split(vim.fn.glob("/home/ubuntu/.local/share/nvim/mason/packages/java-test/extension/server/*.jar", 1), "\n")
    )
    require('jdtls').start_or_attach({
        on_attach = on_attach,
        capabilities = require("core.common").lsp_capabilities(),
        flags = require("core.common").lsp_flags,
        -- The command that starts the language server
        -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
        cmd = {

            -- 💀
            'java', -- or '/path/to/java17_or_newer/bin/java'
            -- depends on if `java` is in your $PATH env variable and if it points to the right version.

            '-Declipse.application=org.eclipse.jdt.ls.core.id1',
            '-Dosgi.bundles.defaultStartLevel=4',
            '-Declipse.product=org.eclipse.jdt.ls.core.product',
            '-Dlog.protocol=true',
            '-Dlog.level=ALL',
            '-Xms1g',
            '--add-modules=ALL-SYSTEM',
            '--add-opens', 'java.base/java.util=ALL-UNNAMED',
            '--add-opens', 'java.base/java.lang=ALL-UNNAMED',

            -- 💀
            '-jar',
            '/home/ubuntu/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar',
            -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
            -- Must point to the                                                     Change this to
            -- eclipse.jdt.ls installation                                           the actual version


            -- 💀
            '-configuration', '/home/ubuntu/.local/share/nvim/mason/packages/jdtls/config_linux',
            -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
            -- Must point to the                      Change to one of `linux`, `win` or `mac`
            -- eclipse.jdt.ls installation            Depending on your system.


            -- 💀
            -- See `data directory configuration` section in the README
            '-data', '/home/ubuntu/.cache/jdtls/workspace'
        },
        -- 💀
        -- This is the default if not provided, you can remove it. Or adjust as needed.
        -- One dedicated LSP server & client will be started per unique root_dir
        root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew' }),
        -- Here you can configure eclipse.jdt.ls specific settings
        -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
        -- for a list of options
        settings = {
            java = {
            }
        },
        -- Language server `initializationOptions`
        -- You need to extend the `bundles` with paths to jar files
        -- if you want to use additional eclipse.jdt.ls plugins.
        --
        -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
        --
        -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
        init_options = {
            bundles = bundles,
        },
    })
end

load_java()
