return {
    "greggh/claude-code.nvim",
    cmd = {
        "ClaudeCode", "ClaudeCodeContinue", "ClaudeCodeResume", "ClaudeCodeVerbose",
        "ClaudeCodeVersion",
    },
    -- setup() creates these (claude-code/keymaps.lua); without stubs they did
    -- not exist until :ClaudeCode had run once.
    keys = {
        { "<C-,>",      "<cmd>ClaudeCode<cr>",         desc = "Claude Code: toggle" },
        { "<leader>cC", "<cmd>ClaudeCodeContinue<cr>", desc = "Claude Code: continue" },
        { "<leader>cV", "<cmd>ClaudeCodeVerbose<cr>",  desc = "Claude Code: verbose" },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        require("claude-code").setup()
    end,
}
