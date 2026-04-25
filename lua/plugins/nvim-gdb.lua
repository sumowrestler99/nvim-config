return {
    "sakhnik/nvim-gdb",
    build = ':!./install.sh',
    -- Load nvim-gdb only when the :Gdb command (or similar) is executed.
    -- You can list other commands if the plugin provides more entry points.
    cmd = { "Gdb", "GdbAttach", "GdbRun", "GdbStart" }, -- Adjust based on actual commands
    keys = {
        { "<leader>dd", desc = "nvim-gdb" },
    }
}

