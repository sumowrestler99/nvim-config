-- Optional machine-local overrides (extra filetypes, private language servers).
-- Empty table when lua/local/lspconfig.lua does not exist.
local extra = require('core.local').get('lspconfig')

-- Filetypes that should trigger loading the LSP stack. A machine-local module
-- may append its own.
local filetypes = {
    "lua", "python", "typescript", "javascript",
    "html", "css", "json", "jsonc", "yaml", "markdown",
    "go", "rust", "bash", "sh", "c", "cpp", "java",
    -- Neovim filetype names, not LSP languageIds: objc rather than
    -- "objective-c", and pbtxt for *.textproto/*.textpb.
    "swift", "objc", "objcpp", "cuda",
    "proto", "pbtxt", "bzl", "gss", "sql", "xml",
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
                -- No .cint check needed: init.lua maps .cint to c, and the
                -- root_dir functions of the servers that serve c decline those
                -- files, so no client attaches to them in the first place.

                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                if not client then return end
                local bufopts = { silent = true, buf = bufnr }

                if client.server_capabilities.documentSymbolProvider then
                    local navic = require('nvim-navic')
                    if not navic.is_available(bufnr) then
                        navic.attach(client, bufnr)
                    end
                end

                -- Not while <leader>ul clean mode is on (see core/keymaps.lua).
                if client.server_capabilities.inlayHintProvider
                    and not vim.g.clean_mode then
                    local uri = vim.uri_from_bufnr(bufnr)
                    if string.match(uri, "^file:") then
                        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                    end
                end

                vim.keymap.set('n', 'gD',         vim.lsp.buf.declaration,    bufopts)
                vim.keymap.set('n', 'gd',         vim.lsp.buf.definition,     bufopts)
                -- hover and signature_help are looked up when pressed: noice
                -- replaces both at VeryLazy (noice/lsp/init.lua:19-26), and a
                -- buffer that attached earlier would keep the originals.
                vim.keymap.set('n', 'K',          function() vim.lsp.buf.hover() end,          bufopts)
                vim.keymap.set('n', 'gi',         vim.lsp.buf.implementation, bufopts)
                vim.keymap.set('n', '<C-k>',      function() vim.lsp.buf.signature_help() end, bufopts)
                vim.keymap.set('n', '<space>D',   vim.lsp.buf.type_definition,bufopts)
                vim.keymap.set('n', '<space>rn',  vim.lsp.buf.rename,         bufopts)
                vim.keymap.set('n', '<space>ca',  vim.lsp.buf.code_action,    bufopts)
                -- No `gr` mapping here on purpose. Neovim 0.12 binds six built-in
                -- LSP maps under that prefix -- grn gra grx grr gri grt, see
                -- :h lsp-defaults -- and a bare `gr` makes every one of them wait
                -- out 'timeoutlen' (500 ms) in every LSP buffer. `grr` is already
                -- vim.lsp.buf.references, so the mapping was redundant as well as
                -- costly.
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

                -- nvim-lspconfig's markers (lsp/clangd.lua:68-76). A root_dir
                -- function replaces root_markers entirely, so they are repeated
                -- here. vim.fs.root() tries each item in order across ALL
                -- ancestors, so upstream's flat list lets any ancestor .clangd
                -- (e.g. one in $HOME) beat a nearer compile_commands.json. The
                -- nested list gives the project markers equal priority -- the
                -- nearest wins -- and keeps .git as the last resort.
                local markers = {
                    {
                        '.clangd', '.clang-tidy', '.clang-format', 'compile_commands.json',
                        'compile_flags.txt', 'configure.ac',
                    },
                    '.git',
                }
                -- on_dir must be called even when nothing is found: vim.lsp only
                -- starts the client from inside that callback (runtime
                -- lsp.lua:548-555). nil starts clangd in single-file mode.
                on_dir(vim.fs.root(bufnr, markers))
            end,
        })

        -- sourcekit-lsp: macOS only (ships with Xcode)
        if vim.fn.has("mac") == 1 then
            vim.lsp.config('sourcekit', {
                cmd          = { "xcrun", "sourcekit-lsp" },
                filetypes    = { "swift", "objc", "objcpp" },
                root_markers = { "Package.swift", ".git" },
            })
            vim.lsp.enable('sourcekit')
        end

        -- lua_ls: point the workspace library at THIS nvim's runtime.
        --
        -- This used to live in .luarc.json as a hardcoded
        -- /opt/homebrew/Cellar/neovim/0.12.1/... path. That directory does not
        -- exist here, so lua_ls had no Neovim definitions loaded at all and
        -- silently reported no diagnostics for misspelled `vim.*` calls or
        -- highlight groups. Deriving it from $VIMRUNTIME keeps the committed
        -- config machine-independent.
        --
        -- .luarc.json still wins for the keys it declares (runtime.version,
        -- diagnostics.globals, workspace.checkThirdParty); it deliberately no
        -- longer declares workspace.library so this takes effect.
        --
        -- Only when the workspace IS this config, though: any other Lua project
        -- would otherwise index the Neovim runtime and accept `vim.*` as
        -- defined. The mutation is in place for the reason given at jsonls
        -- below. nvim-lspconfig's lua_ls config always has a `settings` table.
        vim.lsp.config('lua_ls', {
            before_init = function(_, config)
                local root = config.root_dir and vim.uv.fs_realpath(config.root_dir)
                if not root or root ~= vim.uv.fs_realpath(vim.fn.stdpath('config')) then
                    return
                end
                local lua = config.settings.Lua or {}
                config.settings.Lua = lua
                lua.workspace = vim.tbl_deep_extend('force', lua.workspace or {}, {
                    library = {
                        vim.env.VIMRUNTIME .. '/lua',
                        vim.fn.stdpath('data') .. '/lazy/lazy.nvim/lua',
                    },
                })
            end,
        })

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

        -- Visual range format (linewise).
        --
        -- Do NOT build the range from nvim_buf_get_mark(0, "<"/">"): those marks
        -- are only written when Visual mode is LEFT, so a mapping invoked from
        -- Visual mode reads the *previous* selection. line("v") and line(".")
        -- are the live selection. The range is explicit because format() only
        -- infers one in modes v/V (runtime/lua/vim/lsp/buf.lua:615-620); from
        -- blockwise Visual it would format the whole file. Mode "x", not "v",
        -- so the map stays out of Select mode (snippet placeholders).
        vim.keymap.set("x", "\\qf", function()
            local s, e = vim.fn.line("v"), vim.fn.line(".")
            if s > e then s, e = e, s end
            vim.lsp.buf.format({
                async = true,
                range = { start = { s, 0 }, ["end"] = { e, #vim.fn.getline(e) } },
            })
        end, { desc = "LSP range format" })
    end,
}
