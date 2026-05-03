return {
    'neovim/nvim-lspconfig',
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "mason-org/mason.nvim",
        "mason-org/mason-lspconfig.nvim",
        "b0o/schemastore.nvim",
    },
    ft = {
        "lua", "python", "typescript", "javascript",
        "html", "css", "json", "yaml", "markdown",
        "go", "rust", "bash", "sh", "c", "cpp", "java",
        "swift", "objective-c", "objective-cpp",
    },
    config = function()
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
            callback = function(ev)
                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                if not client then return end
                local bufnr = ev.buf
                local bufopts = { noremap = true, silent = true, buffer = bufnr }

                if client.server_capabilities.documentSymbolProvider then
                    local navic = require('nvim-navic')
                    if not navic.is_available(bufnr) then
                        navic.attach(client, bufnr)
                    end
                end

                if vim.lsp.inlay_hint and client.server_capabilities.inlayHintProvider then
                    local uri = vim.uri_from_bufnr(bufnr)
                    if string.match(uri, "^file:") then
                        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                    end
                end

                vim.keymap.set('n', 'gD',         vim.lsp.buf.declaration,    bufopts)
                vim.keymap.set('n', 'gd',         vim.lsp.buf.definition,     bufopts)
                vim.keymap.set('n', 'K',          vim.lsp.buf.hover,          bufopts)
                vim.keymap.set('n', 'gi',         vim.lsp.buf.implementation, bufopts)
                vim.keymap.set('n', '<C-k>',      vim.lsp.buf.signature_help, bufopts)
                vim.keymap.set('n', '<space>D',   vim.lsp.buf.type_definition,bufopts)
                vim.keymap.set('n', '<space>rn',  vim.lsp.buf.rename,         bufopts)
                vim.keymap.set('n', '<space>ca',  vim.lsp.buf.code_action,    bufopts)
                vim.keymap.set('n', 'gr',         vim.lsp.buf.references,     bufopts)
                vim.keymap.set('n', '<space>f',   function()
                    vim.lsp.buf.format { async = true }
                end, bufopts)
                vim.keymap.set('n', '<space>wa',  vim.lsp.buf.add_workspace_folder,    bufopts)
                vim.keymap.set('n', '<space>wr',  vim.lsp.buf.remove_workspace_folder, bufopts)
                vim.keymap.set('n', '<space>wl',  function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, bufopts)
            end,
        })

        local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
        lsp_capabilities.textDocument.foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
        }

        local clangd_cmd = {
            "clangd",
            "--background-index",         -- build symbol index in background
            "--clang-tidy=0",             -- disable clang-tidy (major perf win)
            "--completion-style=bundled", -- group overloads → fewer items, faster
            "--header-insertion=never",   -- skip auto-include analysis per completion
            "--pch-storage=memory",       -- keep precompiled headers in RAM vs disk
            "--j=" .. #vim.uv.cpu_info(),  -- indexing threads (dynamic core count)
            "--log=error",                -- suppress info/warning log noise
        }

        if vim.fn.has('nvim-0.11') == 1 then
            -- Neovim 0.11+: native vim.lsp.config / vim.lsp.enable API
            vim.lsp.config('*', { capabilities = lsp_capabilities })

            -- clangd: performance-tuned flags
            vim.lsp.config('clangd', { cmd = clangd_cmd })

            -- sourcekit-lsp: macOS only (ships with Xcode)
            if vim.fn.has("mac") == 1 then
                vim.lsp.config('sourcekit', {
                    cmd          = { "xcrun", "sourcekit-lsp" },
                    filetypes    = { "swift", "objective-c", "objective-cpp" },
                    root_markers = { "Package.swift", ".git" },
                })
                vim.lsp.enable('sourcekit')
            end

            -- jsonls: schema-aware JSON via SchemaStore
            vim.lsp.config('jsonls', {
                settings = {
                    json = {
                        schemas  = require('schemastore').json.schemas(),
                        validate = { enable = true },
                    },
                },
            })

            -- yamlls: schema-aware YAML via SchemaStore
            vim.lsp.config('yamlls', {
                settings = {
                    yaml = {
                        schemaStore = { enable = false, url = "" },
                        schemas     = require('schemastore').yaml.schemas(),
                    },
                },
            })

            -- Mason: ensure servers are installed; auto-enables them via vim.lsp.enable()
            require("mason-lspconfig").setup({
                ensure_installed = { "clangd", "lua_ls", "bashls", "pyright", "marksman", "jsonls", "yamlls" },
            })

        else
            -- Neovim 0.10: legacy require('lspconfig') API
            local lspconfig = require('lspconfig')

            -- sourcekit-lsp: macOS only (ships with Xcode)
            if vim.fn.has("mac") == 1 then
                lspconfig.sourcekit.setup({
                    capabilities = lsp_capabilities,
                    cmd          = { "xcrun", "sourcekit-lsp" },
                    filetypes    = { "swift", "objective-c", "objective-cpp" },
                    root_dir     = lspconfig.util.root_pattern("Package.swift", ".git"),
                })
            end

            -- Mason: ensure servers are installed
            require("mason-lspconfig").setup({
                ensure_installed = { "clangd", "lua_ls", "bashls", "pyright", "marksman", "jsonls", "yamlls" },
                handlers = {
                    function(server_name)
                        lspconfig[server_name].setup({ capabilities = lsp_capabilities })
                    end,
                    ["clangd"] = function()
                        lspconfig.clangd.setup({
                            capabilities = lsp_capabilities,
                            cmd          = clangd_cmd,
                        })
                    end,
                    ["jsonls"] = function()
                        lspconfig.jsonls.setup({
                            capabilities = lsp_capabilities,
                            settings = {
                                json = {
                                    schemas  = require('schemastore').json.schemas(),
                                    validate = { enable = true },
                                },
                            },
                        })
                    end,
                    ["yamlls"] = function()
                        lspconfig.yamlls.setup({
                            capabilities = lsp_capabilities,
                            settings = {
                                yaml = {
                                    schemaStore = { enable = false, url = "" },
                                    schemas     = require('schemastore').yaml.schemas(),
                                },
                            },
                        })
                    end,
                },
            })

        end

        -- Visual range format
        local function format_range()
            vim.lsp.buf.format({
                async = true,
                range = {
                    ["start"] = vim.api.nvim_buf_get_mark(0, "<"),
                    ["end"]   = vim.api.nvim_buf_get_mark(0, ">"),
                },
            })
        end
        vim.keymap.set("v", "\\qf", format_range, { noremap = true, desc = "LSP range format" })
    end,
}
