return {
    "greggh/claude-code.nvim",
    cmd = {
        "ClaudeCode", "ClaudeCodeContinue", "ClaudeCodeResume", "ClaudeCodeVerbose",
        -- Not ClaudeCodeVersion: it errors upstream (commands.lua:35 calls a
        -- table). Use :lua print(require("claude-code").get_version()).
    },
    -- setup() creates these (claude-code/keymaps.lua); without stubs they did
    -- not exist until :ClaudeCode had run once.
    keys = {
        { "<C-,>",      "<cmd>ClaudeCode<cr>",         desc = "Claude Code: toggle" },
        { "<leader>cC", "<cmd>ClaudeCodeContinue<cr>", desc = "Claude Code: continue" },
        { "<leader>cV", "<cmd>ClaudeCodeVerbose<cr>",  desc = "Claude Code: verbose" },
    },
    config = function()
        require("claude-code").setup()
    end,
}
