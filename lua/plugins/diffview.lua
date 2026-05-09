return {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    -- Load on demand via commands
    cmd = {
        "DiffviewOpen",
        "DiffviewClose",
        "DiffviewFileHistory",
        "DiffviewToggleFiles",
        "DiffviewFocusFiles",
        "DiffviewRefresh",
    },
    keys = {
        { "<leader>gd", "<cmd>DiffviewOpen<cr>",            desc = "Diffview open" },
        { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>",   desc = "Diffview file history" },
        { "<leader>gH", "<cmd>DiffviewFileHistory<cr>",     desc = "Diffview repo history" },
        { "<leader>gx", "<cmd>DiffviewClose<cr>",           desc = "Diffview close" },
    },
    opts = {
        enhanced_diff_hl = true, -- better diff highlights
        view = {
            -- Side-by-side diff (default)
            default = {
                layout = "diff2_horizontal",
            },
            -- Merge tool layout for 3-way conflicts
            merge_tool = {
                layout = "diff3_horizontal",
                disable_diagnostics = true,
            },
        },
        file_panel = {
            listing_style = "tree",
            tree_options = {
                flatten_dirs = true,
                folder_statuses = "only_folded",
            },
        },
        keymaps = {
            view = {
                -- Custom 2-character shortcuts for 3-way merge resolution
                { { "n", "x" }, "g<", function() require("diffview.actions").diffget("ours")() end, { desc = "Obtain diff from Left (ours)" } },
                { { "n", "x" }, "g>", function() require("diffview.actions").diffget("theirs")() end, { desc = "Obtain diff from Right (theirs)" } },
            }
        },
    },
}
