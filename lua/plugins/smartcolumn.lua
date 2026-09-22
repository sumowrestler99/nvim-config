return {
    "m4xshen/smartcolumn.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        colorcolumn = "100",
        scope = "window", -- OPTIMIZED: only check visible lines, not 34K file lines!
        -- The option is `custom_colorcolumn`, not `custom`. setup() copies every
        -- user key into its config table verbatim, so a typo is silently kept
        -- and simply never read (smartcolumn.lua:54-59).
        custom_colorcolumn = {
            c = "80",
            cpp = "80",
            rust = "80",
        }
    }
}

