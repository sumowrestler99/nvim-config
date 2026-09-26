-- Custom 2-character shortcuts for 3-way merge resolution. A function so
-- each layout gets its own tables.
local function merge_keys()
    return {
        { { "n", "x" }, "g<", function() require("diffview.actions").diffget("ours")() end, { desc = "Obtain diff from Left (ours)" } },
        { { "n", "x" }, "g>", function() require("diffview.actions").diffget("theirs")() end, { desc = "Obtain diff from Right (theirs)" } },
    }
end

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
        "DiffviewLog",
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
            -- 3-way layouts only: diffget has no target in 2-way diffs. The
            -- merge tool cycles (g<C-x>) from diff3 to diff4_mixed, where
            -- ours/theirs still apply, so both get the maps.
            diff3 = merge_keys(),
            diff4 = merge_keys(),
        },
    },
}
