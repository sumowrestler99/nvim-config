return {
    "m4xshen/smartcolumn.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        colorcolumn = "100",
        -- Measures only the visible lines, but smartcolumn.lua:13 still copies
        -- the whole buffer first, on every BufEnter, CursorMoved(I) and
        -- WinScrolled. disabled_filetypes is checked before that copy.
        scope = "window",
        -- Replaces the plugin's default list (help, text, markdown) rather than
        -- extending it. bigfile: see above. Avante: its sidebar is streamed into.
        disabled_filetypes = { "help", "text", "markdown", "bigfile", "Avante", "AvanteInput" },
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

