return {
    "m4xshen/smartcolumn.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        colorcolumn = "100",
        custom = {
            c = "80",
            cpp = "80",
            rust = "80",
        }
    }
}

