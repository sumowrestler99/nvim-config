return {
    "utilyre/barbecue.nvim",
    dependencies = {
        "SmiteshP/nvim-navic",
        "nvim-tree/nvim-web-devicons",
    },
    -- Load eagerly so winbar renders immediately on all windows including diff mode.
    -- Lazy loading caused the winbar to appear seconds late, misaligning diff lines
    -- between left and right windows until the delayed refresh completed.
    lazy = false,
    opts = {
        -- Auto-attach nvim-navic to LSP clients for breadcrumb symbols
        attach_navic = true,

        -- Use catppuccin highlights automatically
        theme = "auto",

        -- Show modified indicator
        show_modified = true,

        -- Separator between path components and LSP context
        symbols = {
            separator = "",
        },

        -- Don't show in these filetypes
        exclude_filetypes = {
            "help",
            "startify",
            "dashboard",
            "NvimTree",
            "Trouble",
            "alpha",
            "toggleterm",
            "qf",
            "fugitive",
            "fugitiveblame",
        },
    },
}
