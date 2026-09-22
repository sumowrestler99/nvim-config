return {
    "folke/todo-comments.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    event = "BufReadPost",
    keys = {
        -- todo-comments ships no :TodoSnacks command. Its plugin/todo.vim only
        -- defines TodoQuickFix/TodoLocList/TodoTelescope/TodoFzfLua/TodoTrouble.
        -- Snacks integration is registered from todo-comments' own setup(), as
        -- `Snacks.picker.sources.todo_comments`, so call the picker directly.
        { "<leader>ft", function() Snacks.picker.todo_comments() end, desc = "Todo comments" },
        { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo" },
        { "[t", function() require("todo-comments").jump_prev() end, desc = "Prev todo" },
    },
    opts = {
        signs = true,
        keywords = {
            FIX  = { icon = " ", color = "error",   alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
            TODO = { icon = " ", color = "info" },
            HACK = { icon = " ", color = "warning" },
            WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
            PERF = { icon = " ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
            NOTE = { icon = " ", color = "hint",    alt = { "INFO" } },
            TEST = { icon = "󰙨 ", color = "test",    alt = { "TESTING", "PASSED", "FAILED" } },
        },
        gui_style = {
            fg = "BOLD",
        },
        merge_keywords = true,
        highlight = {
            before       = "",
            keyword      = "wide_bg",
            after        = "fg",
            pattern      = [[.*<(KEYWORDS)\s*:]],
            comments_only = true,
        },
        colors = {
            error   = { "DiagnosticError",   "ErrorMsg",  "#DC2626" },
            warning = { "DiagnosticWarn",    "WarningMsg","#FBBF24" },
            info    = { "DiagnosticInfo",               "#2563EB" },
            hint    = { "DiagnosticHint",               "#10B981" },
            default = { "Identifier",                   "#7C3AED" },
            test    = { "Identifier",                   "#FF006E" },
        },
    },
}
