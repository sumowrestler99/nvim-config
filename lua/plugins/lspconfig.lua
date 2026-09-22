-- Optional machine-local overrides (extra filetypes, private language servers).
-- Empty table when lua/local/lspconfig.lua does not exist.
local extra = require('core.local').get('lspconfig')

-- Filetypes that should trigger loading the LSP stack. A machine-local module
-- may append its own.
local filetypes = {
    "lua", "python", "typescript", "javascript",
    "html", "css", "json", "jsonc", "yaml", "markdown",
    "go", "rust", "bash", "sh", "c", "cpp", "java",
    "swift", "objective-c", "objective-cpp",
    "proto", "textpb", "bzl", "gss", "sql", "xml",
    "dart",
}
vim.list_extend(filetypes, extra.filetypes or {})

return {
    'neovim/nvim-lspconfig',
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "mason-org/mason.nvim",
        "mason-org/mason-lspconfig.nvim",
        "b0o/schemastore.nvim",
        -- Attached to document-symbol-capable clients in the LspAttach handler
        -- below. Declared here rather than relying on barbecue pulling it in.
        "SmiteshP/nvim-navic",
    },
    ft = filetypes,
    config = function()
        -- Lives here rather than in core/options.lua: referencing vim.lsp at
        -- startup pulls in the whole LSP module before any server exists.
        vim.lsp.log.set_level("OFF")

        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
            callback = function(ev)
                local bufnr = ev.buf
                local bufname = vim.api.nvim_buf_get_name(bufnr)
                if bufname:match("%.cint$") then
                    local client_id = ev.data and ev.data.client_id
                    if client_id then
                        vim.lsp.buf_detach_client(bufnr, client_id)
                    end
                    return
                end

                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                if not client then return end
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

        -- Applies to every server unless overridden below.
        vim.lsp.config('*', { capabilities = lsp_capabilities })

        -- clangd: performance-tuned flags
        vim.lsp.config('clangd', {
            cmd = {
                "clangd",
                "--background-index",         -- build symbol index in background
                "--clang-tidy=0",             -- disable clang-tidy (major perf win)
                "--completion-style=bundled", -- group overloads → fewer items, faster
                "--header-insertion=never",   -- skip auto-include analysis per completion
                "--pch-storage=memory",       -- keep precompiled headers in RAM vs disk
                "--j=" .. #vim.uv.cpu_info(), -- indexing threads (dynamic core count)
                "--log=error",                -- suppress info/warning log noise
            },
            root_dir = function(bufnr, on_dir)
                local filepath = vim.api.nvim_buf_get_name(bufnr)
                if filepath:match("%.cint$") then return end
                -- A machine-local module can claim paths that another server owns.
                if extra.skip_clangd and extra.skip_clangd(filepath) then return end

                local markers = { 'compile_commands.json', '.clangd', '.git' }
                local found = vim.fs.find(markers, { path = filepath, upward = true })[1]
                if found then
                    on_dir(vim.fs.dirname(found))
                end
            end,
        })

        -- sourcekit-lsp: macOS only (ships with Xcode)
        if vim.fn.has("mac") == 1 then
            vim.lsp.config('sourcekit', {
                cmd          = { "xcrun", "sourcekit-lsp" },
                filetypes    = { "swift", "objective-c", "objective-cpp" },
                root_markers = { "Package.swift", ".git" },
            })
            vim.lsp.enable('sourcekit')
        end

        -- SchemaStore's catalog costs ~6 ms to parse, and this spec loads for
        -- any of 32 filetypes -- so opening a .lua file was paying for it.
        -- Build it in before_init, i.e. only once the server actually starts.
        --
        -- The empty `settings = {}` and the in-place mutation are both
        -- deliberate. vim/lsp/client.lua does `settings = config.settings or {}`
        -- by reference, so REASSIGNING config.settings in before_init (as the
        -- example in client.lua's own docs does) leaves client.settings
        -- pointing at the original table and the schemas are never sent.

        -- jsonls: schema-aware JSON via SchemaStore
        vim.lsp.config('jsonls', {
            settings = {},
            before_init = function(_, config)
                config.settings.json = vim.tbl_deep_extend('force', config.settings.json or {}, {
                    schemas  = require('schemastore').json.schemas(),
                    validate = { enable = true },
                })
            end,
        })

        -- yamlls: schema-aware YAML via SchemaStore
        --
        -- Merge rather than assign. nvim-lspconfig's lsp/yamlls.lua already
        -- ships `settings.yaml = { format = { enable = true } }` because
        -- yaml-language-server disables formatting by default, and its on_init
        -- forces `documentFormattingProvider = true` on top. Replacing the
        -- table dropped format.enable, leaving a server that claims to format
        -- and then does nothing.
        vim.lsp.config('yamlls', {
            settings = {},
            before_init = function(_, config)
                config.settings.yaml = vim.tbl_deep_extend('force', config.settings.yaml or {}, {
                    schemaStore = { enable = false, url = "" },
                    schemas     = require('schemastore').yaml.schemas(),
                })
            end,
        })

        -- Mason: ensure servers are installed; auto-enables them via vim.lsp.enable()
        require("mason-lspconfig").setup({
            ensure_installed = { "clangd", "lua_ls", "bashls", "pyright", "marksman", "jsonls", "yamlls" },
        })

        -- Servers that only exist on this machine, registered last so they can
        -- override anything above.
        if extra.setup then
            extra.setup()
        end

        -- Visual range format.
        --
        -- Do NOT build the range from nvim_buf_get_mark(0, "<"/">"): those marks
        -- are only written when Visual mode is LEFT, so a mapping invoked from
        -- Visual mode reads the *previous* selection. vim.lsp.buf.format already
        -- handles this: when no range is passed and the mode is v/V it calls
        -- range_from_selection() against the live selection
        -- (runtime/lua/vim/lsp/buf.lua:617-620) and switches the request to
        -- textDocument/rangeFormatting.
        vim.keymap.set("v", "\\qf", function()
            vim.lsp.buf.format({ async = true })
        end, { noremap = true, desc = "LSP range format" })
    end,
}
