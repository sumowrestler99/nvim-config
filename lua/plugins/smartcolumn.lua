return {
    "m4xshen/smartcolumn.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        colorcolumn = "100",
        scope = "window", -- OPTIMIZED: only check visible lines, not 34K file lines!
        custom = {
            c = "80",
            cpp = "80",
            rust = "80",
        }
    }
}

