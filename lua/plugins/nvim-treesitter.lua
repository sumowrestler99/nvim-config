-- nvim-treesitter, `main` branch.
--
-- `master` is frozen -- its README states it is "provided for backward
-- compatibility only" and that all future work happens on `main`. The two
-- branches are the halves of a rewrite, and this config was straddling both:
-- nvim-treesitter on master, nvim-treesitter-textobjects on main. That skew is
-- what forced the global `vim.treesitter.get_node_text` monkeypatch that used
-- to sit in init.lua.
--
-- `main` deletes most of the old configuration surface. There is no
-- `nvim-treesitter.configs` module at all, so `configs.setup{}`,
-- `ensure_installed`, `highlight.enable`, `auto_install` and
-- `incremental_selection` are all gone. Highlighting is Neovim's own
-- `vim.treesitter.start()`, parsers install into `stdpath('data')/site`
-- instead of the plugin directory, and compilation is done by the
-- `tree-sitter` CLI (`tree-sitter build`) rather than an internally-selected
-- compiler -- so `install.compilers` no longer exists either.
--
-- Everything master used to do declaratively is therefore wired up by hand
-- below.

-- Parsers to keep installed. Under master this was `ensure_installed` plus
-- whatever `auto_install` had accumulated; this list is the set that was
-- actually present, so the migration does not silently drop languages.
-- Filtered against get_available() at run time so an unknown name cannot
-- produce a warning on every update.
--
-- Two entries from the master-era set are deliberately absent:
--   jsonc  not a parser on main; vim.treesitter.language.get_lang('jsonc')
--          resolves to 'json', which is installed, so jsonc still highlights.
--   tmux   removed from main's parser list upstream. No loss in practice --
--          'tmux' is not in this spec's `ft`, so the plugin never loaded for
--          those buffers anyway.
--
-- tcl is managed here too. It used to come from a lewis6991/tree-sitter-tcl
-- dependency, but that never produced a parser on 'runtimepath' -- it only
-- contributed a competing, non-`extends` queries/tcl/ set and an ftplugin that
-- called vim.treesitter.start() before any parser existed. nvim-treesitter's
-- own tcl entry is the same grammar (transferred to tree-sitter-grammars).
--
-- regex is a later addition rather than inherited: noice highlights regex
-- patterns in the cmdline with it, and :checkhealth noice reports it missing.
local ensure_installed = {
    'bash', 'c', 'cpp', 'csv', 'diff', 'html', 'json', 'lua', 'make',
    'markdown', 'markdown_inline', 'perl', 'python', 'regex', 'starlark', 'tcl',
    'textproto', 'vim', 'vimdoc', 'yaml',
}

-- Languages fetched the first time a buffer of that language is opened,
-- rather than up front.
local on_demand = { 'css', 'go', 'java', 'javascript', 'rust', 'typescript' }

-- The plugin's `ft` trigger, derived from the two lists above so they cannot
-- drift apart again. They had: eight installed parsers (csv diff make perl
-- starlark textproto vim vimdoc) belonged to filetypes that never loaded the
-- plugin, so they were never used for highlighting.
--
-- Only languages with filetypes other than their own name need an entry.
-- These mirror the aliases nvim-treesitter registers in plugin/filetypes.lua,
-- which only runs once the plugin has loaded and so cannot be consulted here.
-- Neovim's filetype detection uses the alias, not the parser name: BUILD and
-- *.bzl are 'bzl', *.textproto and *.pbtxt are 'pbtxt'.
-- markdown_inline and regex are only ever injected; they have no filetype.
local lang_filetypes = {
    bash            = { 'bash', 'sh' },
    diff            = { 'diff', 'gitdiff' },
    javascript      = { 'javascript', 'javascriptreact' },
    json            = { 'json', 'jsonc' },
    make            = { 'make', 'automake' },
    markdown        = { 'markdown', 'pandoc' },
    markdown_inline = {},
    python          = { 'python', 'gyp' },
    regex           = {},
    starlark        = { 'starlark', 'bzl' },
    tcl             = { 'tcl', 'expect' },
    textproto       = { 'textproto', 'pbtxt' },
    vimdoc          = { 'help' },
}
local filetypes = {}
for _, langs in ipairs({ ensure_installed, on_demand }) do
    for _, lang in ipairs(langs) do
        vim.list_extend(filetypes, lang_filetypes[lang] or { lang })
    end
end

--- Selects a treesitter node as a charwise visual selection.
---
--- Sets the '< and '> marks and reselects with `gv` rather than entering
--- visual mode with `normal! v`. `normal! v` only works when the caller is in
--- normal mode, so it breaks for grn/grc/grm, which are invoked from a
--- selection that is already active.
---@param node TSNode
local function select_node(node)
    local srow, scol, erow, ecol = node:range()
    -- range() end columns are exclusive; a node ending at column 0 really ends
    -- at the end of the previous line.
    if ecol == 0 then
        erow = erow - 1
        local line = vim.api.nvim_buf_get_lines(0, erow, erow + 1, false)[1] or ''
        ecol = #line
    end
    local buf = vim.api.nvim_get_current_buf()
    -- Marks are 1-indexed for rows and columns; node ranges are 0-indexed.
    vim.fn.setpos("'<", { buf, srow + 1, scol + 1, 0 })
    vim.fn.setpos("'>", { buf, erow + 1, ecol, 0 })
    -- `gv` reselects using the *last* visual mode, so after any linewise or
    -- blockwise selection it would reselect the node linewise or blockwise.
    -- A trailing `v` switches that back to charwise over the same marks. It
    -- must not be sent when the last mode was already charwise (or none):
    -- there `v` would end Visual mode instead.
    local last = vim.fn.visualmode()
    vim.cmd('normal! gv' .. ((last == 'V' or last == '\22') and 'v' or ''))
end

--- Incremental selection.
---
--- `main` removed this feature outright with no replacement, so it is
--- reimplemented here directly against Neovim's treesitter API. The selection
--- history is a per-buffer stack so that grm can walk back down it.
local incremental = {}
do
    ---@type table<integer, TSNode[]>
    local stacks = {}

    vim.api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout' }, {
        group = vim.api.nvim_create_augroup('UserTSIncrementalSelection', { clear = true }),
        callback = function(args) stacks[args.buf] = nil end,
    })

    --- Nearest ancestor whose range differs from `node`'s.
    ---
    --- Ancestors that span exactly the same text are skipped, otherwise a
    --- single keypress would appear to do nothing. The comparison is on the
    --- full (row, col) range rather than just the rows, so a parent that is
    --- wider only in columns still counts as growth.
    ---@param node TSNode
    ---@return TSNode?
    local function grow(node)
        local srow, scol, erow, ecol = node:range()
        local parent = node:parent()
        while parent do
            local psrow, pscol, perow, pecol = parent:range()
            if psrow ~= srow or pscol ~= scol or perow ~= erow or pecol ~= ecol then
                return parent
            end
            parent = parent:parent()
        end
        return nil
    end

    function incremental.init()
        local buf = vim.api.nvim_get_current_buf()
        local node = vim.treesitter.get_node()
        if not node then return end
        stacks[buf] = { node }
        select_node(node)
    end

    function incremental.node_incremental()
        local buf = vim.api.nvim_get_current_buf()
        local stack = stacks[buf]
        if not stack or #stack == 0 then return incremental.init() end
        local parent = grow(stack[#stack])
        if not parent then
            select_node(stack[#stack])
            return
        end
        stack[#stack + 1] = parent
        select_node(parent)
    end

    --- Approximation of master's `scope_incremental`, which relied on the
    --- locals.scm scope captures. Here it expands until the node covers more
    --- lines than the current one, which lands on the enclosing block or
    --- function in practice.
    function incremental.scope_incremental()
        local buf = vim.api.nvim_get_current_buf()
        local stack = stacks[buf]
        if not stack or #stack == 0 then return incremental.init() end
        local current = stack[#stack]
        local start_lines = current:end_() - current:start()
        local node = current
        while true do
            local parent = grow(node)
            if not parent then break end
            node = parent
            stack[#stack + 1] = parent
            if (parent:end_() - parent:start()) > start_lines then break end
        end
        select_node(node)
    end

    function incremental.node_decremental()
        local buf = vim.api.nvim_get_current_buf()
        local stack = stacks[buf]
        if not stack or #stack <= 1 then return end
        stack[#stack] = nil
        select_node(stack[#stack])
    end
end

return {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    ft = filetypes,
    config = function()
        local ts = require('nvim-treesitter')
        ts.setup()

        local group = vim.api.nvim_create_augroup('UserTreesitter', { clear = true })

        -- Google's C++ grammar, which extends the upstream one.
        --
        -- Under master this came from the smartpde/tree-sitter-cpp-google
        -- plugin, whose setup() called parsers.get_parser_configs(). That
        -- function does not exist on main -- parsers.lua is now a plain data
        -- table -- so the plugin is dropped and the entry is written directly.
        -- `User TSUpdate` is the documented hook, fired by install/update
        -- before they read the parser table.
        --
        -- No `generate` key: the repo ships a pre-generated src/parser.c.
        vim.api.nvim_create_autocmd('User', {
            pattern = 'TSUpdate',
            group = group,
            callback = function()
                require('nvim-treesitter.parsers').cpp = {
                    install_info = {
                        url = 'https://github.com/smartpde/tree-sitter-cpp-google',
                        revision = 'df6440a13741700414d12f51355d8e8cf30f5b14',
                    },
                    requires = { 'c' },
                    tier = 2,
                }
            end,
        })

        -- Replacement for master's `ensure_installed` and `highlight`/`auto_install`.
        --
        -- Both sets are needed below, so build them once.
        local available = {}
        for _, lang in ipairs(ts.get_available()) do
            available[lang] = true
        end
        local installed = {}
        for _, lang in ipairs(ts.get_installed('parsers')) do
            installed[lang] = true
        end

        -- Install tasks still in flight, by language. A buffer whose parser is
        -- on its way waits for that task rather than queueing a second
        -- install: a duplicate request blocks in vim.wait() until the first
        -- one finishes (nvim-treesitter install.lua:474-478).
        local pending = {}

        -- `main` builds parsers with the tree-sitter CLI (0.26.1 or later, per
        -- its README). Without it every install fails, silently -- the failure
        -- is hidden by the pcall(vim.treesitter.start) below -- so say so once.
        local function can_build()
            if vim.fn.executable('tree-sitter') == 1 then return true end
            if not vim.g.user_ts_cli_warned then
                vim.g.user_ts_cli_warned = true
                vim.notify('nvim-treesitter: no tree-sitter CLI on $PATH, so '
                    .. 'parsers cannot be installed', vim.log.levels.WARN)
            end
            return false
        end

        ---@param langs string[]
        local function install(langs)
            if not can_build() then return end
            local task = ts.install(langs)
            for _, lang in ipairs(langs) do
                pending[lang] = task
            end
        end

        -- Only install what is genuinely missing.
        --
        -- `install()` is NOT a cheap no-op for already-present parsers: it
        -- skips the download, but it first calls reload_parsers(), which nils
        -- and re-parses the 2,346-line parsers.lua and re-fires `User TSUpdate`
        -- -- repeating the work get_available() above has already done. In the
        -- steady state nothing is missing, so the call is skipped entirely.
        local missing = vim.tbl_filter(function(lang)
            return available[lang] and not installed[lang]
        end, ensure_installed)
        if #missing > 0 then
            install(missing)
        end

        ---@param buf integer
        local function start_highlighting(buf)
            if not vim.api.nvim_buf_is_valid(buf) then return end
            local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
            if not lang then return end

            -- Skip very large files; treesitter parsing dominates there.
            local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > 500 * 1024 then return end

            if installed[lang] then
                pcall(vim.treesitter.start, buf, lang)
                return
            end
            -- auto_install: fetch it, then highlight once it lands.
            if not pending[lang] and available[lang] then
                install({ lang })
            end
            if pending[lang] then
                pending[lang]:await(vim.schedule_wrap(function()
                    pcall(vim.treesitter.start, buf, lang)
                end))
            end
        end

        vim.api.nvim_create_autocmd('FileType', {
            group = group,
            callback = function(args) start_highlighting(args.buf) end,
        })

        -- The FileType event for the buffer that triggered this plugin's `ft`
        -- load has already fired, so it would otherwise never be highlighted.
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) then
                start_highlighting(buf)
            end
        end

        -- Incremental selection (see the implementation above).
        vim.keymap.set('n', 'gnn', incremental.init,              { desc = 'Init selection' })
        vim.keymap.set('x', 'grn', incremental.node_incremental,  { desc = 'Increment node' })
        vim.keymap.set('x', 'grc', incremental.scope_incremental, { desc = 'Increment scope' })
        vim.keymap.set('x', 'grm', incremental.node_decremental,  { desc = 'Decrement node' })

        -- textobjects: select
        require("nvim-treesitter-textobjects").setup({ select = { lookahead = true } })
        local select = require("nvim-treesitter-textobjects.select")
        vim.keymap.set({ "x", "o" }, "af", function() select.select_textobject("@function.outer", "textobjects") end)
        vim.keymap.set({ "x", "o" }, "if", function() select.select_textobject("@function.inner", "textobjects") end)
        vim.keymap.set({ "x", "o" }, "ac", function() select.select_textobject("@class.outer",    "textobjects") end)
        vim.keymap.set({ "x", "o" }, "ic", function() select.select_textobject("@class.inner",    "textobjects") end)
        vim.keymap.set({ "x", "o" }, "aa", function() select.select_textobject("@parameter.outer",   "textobjects") end)
        vim.keymap.set({ "x", "o" }, "ia", function() select.select_textobject("@parameter.inner",   "textobjects") end)
        vim.keymap.set({ "x", "o" }, "ax", function() select.select_textobject("@conditional.outer", "textobjects") end)
        vim.keymap.set({ "x", "o" }, "ix", function() select.select_textobject("@conditional.inner", "textobjects") end)
        vim.keymap.set({ "x", "o" }, "al", function() select.select_textobject("@loop.outer",        "textobjects") end)
        vim.keymap.set({ "x", "o" }, "il", function() select.select_textobject("@loop.inner",        "textobjects") end)

        -- textobjects: move
        local move = require("nvim-treesitter-textobjects.move")
        vim.keymap.set({ "n", "x", "o" }, "]m", function() move.goto_next_start("@function.outer",     "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "]M", function() move.goto_next_end("@function.outer",       "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "[m", function() move.goto_previous_start("@function.outer", "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "[M", function() move.goto_previous_end("@function.outer",   "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "]]", function() move.goto_next_start("@class.outer",        "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "[[", function() move.goto_previous_start("@class.outer",    "textobjects") end)

        -- textobjects: swap
        --
        -- <leader>s rather than <leader>a: avante defines fifteen <leader>a?
        -- mappings, so a bare <leader>a was a prefix of all of them and every
        -- swap waited out 'timeoutlen' (500 ms) first.
        local swap = require("nvim-treesitter-textobjects.swap")
        vim.keymap.set("n", "<leader>sa", function() swap.swap_next("@parameter.inner")     end,
            { desc = "Swap parameter next" })
        vim.keymap.set("n", "<leader>sA", function() swap.swap_previous("@parameter.inner") end,
            { desc = "Swap parameter previous" })
    end,
}
