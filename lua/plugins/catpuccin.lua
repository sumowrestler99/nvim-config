return {
    'catppuccin/nvim',
    lazy = false,
    priority = 1000,
  -- The 'config' function runs after the plugin is successfully loaded
  config = function()
        require("catppuccin").setup({
            flavour = "mocha", -- latte, frappe, macchiato, mocha
            background = { -- :h background
                light = "latte",
                dark = "mocha",
            },
            transparent_background = false,
            term_colors = false,
            dim_inactive = {
                enabled = true,
                shade = "dark",
                percentage = 0.15,
            },
            no_italic = false, -- Force no italic
            no_bold = false, -- Force no bold
            styles = {
                comments = { "italic" },
                conditionals = { "italic" },
                loops = {},
                functions = { "bold" },
                keywords = {},
                strings = {},
                variables = { "bold" },
                numbers = {},
                booleans = {},
                properties = {},
                types = {},
                operators = {},
            },
            color_overrides = {},
            custom_highlights = {
                -- nvim-dap.lua's stopped-line highlight; neither catppuccin
                -- nor nvim-dap defines it.
                DapStoppedLine         = { link = "Visual" },
                -- catppuccin's avante integration defines these first, so
                -- avante's own highlights.diff option is skipped
                -- (avante highlights.lua:113-116). Set them here instead.
                AvanteConflictCurrent  = { link = "DiffText" },
                AvanteConflictIncoming = { link = "DiffAdd" },
            },
            integrations = {
                barbecue = {
                    dim_dirname = true,
                    bold_basename = true,
                    dim_context = false,
                },
                cmp = true,
                gitsigns = true,
                nvimtree = false,
                neotree = true,
                dap = true,
                dap_ui = true,
                overseer = false,
                notify = true,
                mini = false,
                noice = true,
                which_key = true,
                ufo = true,
                diffview = true,
                -- Matches avante.lua's sidebar_header.rounded = true.
                avante = { enabled = true, windows_sidebar_header_rounded = true },
                indent_blankline = {
                    enabled = false,
                    colored_indent_levels = false,
                },
                -- Diagnostic styling: catppuccin's top-level `lsp_styles`
                -- defaults (italic virtual text) are what this wants; the
                -- undercurls come from core/autocmds.lua. The old
                -- integrations.native_lsp key is no longer read.

                -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
            },
        })
        vim.cmd.colorscheme "catppuccin"
  end,
}
