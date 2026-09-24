-- The single definition of render-markdown.nvim.
--
-- It used to be declared twice -- once as an inline dependency of avante, once
-- inside a machine-local plugin spec -- with different `opts`. lazy.nvim merges
-- the fragments, but lua/plugins/ is imported before lua/local/plugins/, so the
-- local copy silently won any collision, and on a machine without lua/local/
-- its options vanished altogether. Plugins that need it now list it by name.
return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "Avante" },
    opts = {
        file_types = { "markdown", "Avante" },
        -- Scratch buffers (buftype=nofile) -- the avante sidebar and other
        -- chat panes -- are streamed into and never edited by hand, so render
        -- them plainly and without delay.
        overrides = {
            buftype = {
                nofile = {
                    anti_conceal = { enabled = false },
                    code = { left_pad = 0, right_pad = 0 },
                    debounce = 0,
                },
            },
        },
    },
}
