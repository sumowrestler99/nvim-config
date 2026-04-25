return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = {
        "smartpde/tree-sitter-cpp-google",
        {
            "lewis6991/tree-sitter-tcl",
            build = "make",
        },
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    ft = {
        "lua", "python", "typescript", "javascript",
        "html", "css", "json", "yaml", "markdown",
        "go", "rust", "bash", "sh", "c", "cpp", "java", "tcl",
    },
    config = function()
        require("tree-sitter-cpp-google").setup()
        require('nvim-treesitter.install').compilers = { "clang", "gcc" }

        vim.api.nvim_set_hl(0, "fec", { link = "Identifier" })

        require('nvim-treesitter.configs').setup({
            ensure_installed = { "c", "lua", "vim", "markdown", "bash" },
            sync_install     = false,
            auto_install     = true,
            ignore_install   = { "javascript" },
            highlight = {
                enable = true,
                -- Disable for files over 100 KB to avoid slowdowns
                disable = function(_, buf)
                    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > 100 * 1024 then
                        return true
                    end
                end,
                additional_vim_regex_highlighting = false,
            },
            incremental_selection = {
                enable  = true,
                keymaps = {
                    init_selection    = "gnn",
                    node_incremental  = "grn",
                    scope_incremental = "grc",
                    node_decremental  = "grm",
                },
            },
        })

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
        local swap = require("nvim-treesitter-textobjects.swap")
        vim.keymap.set("n", "<leader>a", function() swap.swap_next("@parameter.inner")     end)
        vim.keymap.set("n", "<leader>A", function() swap.swap_previous("@parameter.inner") end)
    end,
}
