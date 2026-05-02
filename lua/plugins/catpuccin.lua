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
            show_end_of_buffer = false, -- show the '~' characters after the end of buffers
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
            custom_highlights = {},
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
                telescope = true,
                notify = true,
                mini = false,
                noice = true,
                which_key = true,
                ufo = true,
                bufferline = true,
                diffview = true,
                treesitter = true,
                indent_blankline = {
                    enabled = false,
                    colored_indent_levels = false,
                },
                native_lsp = {
                    enabled = true,
                    virtual_text = {
                        errors = { "italic" },
                        hints = { "italic" },
                        warnings = { "italic" },
                        information = { "italic" },
                    },
                    underlines = {
                        errors = { "undercurl" },
                        hints = { "undercurl" },
                        warnings = { "undercurl" },
                        information = { "undercurl" },
                    },
                },

                -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
            },
        })
        vim.cmd.colorscheme "catppuccin"
  end,
}
