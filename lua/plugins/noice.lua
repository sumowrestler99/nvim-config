return {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
        lsp = {
            -- Use Treesitter for markdown rendering in cmp, hover, etc.
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"]                = true,
                ["cmp.entry.get_documentation"]                  = true,
            },
            -- Show LSP progress in the bottom-right corner
            progress = {
                enabled = true,
                format  = "lsp_progress",
                format_done = "lsp_progress_done",
                throttle = 1000 / 30, -- 30fps
                view = "mini",
            },
            hover      = { enabled = true },
            signature  = { enabled = true },
        },

        cmdline = {
            format = {
                cmdline     = { icon = "󰘳 " },  -- : commands
                search_down = { icon = " " }, -- / search
                search_up   = { icon = " " }, -- ? search
                filter      = { icon = " " }, -- :! shell
                lua         = { icon = " " }, -- :lua
                help        = { icon = "󰋖 " },  -- :help
                calculator  = { icon = " " }, -- = calculator
                input       = { icon = "󰥻 " },  -- input() prompts
            },
        },

        popupmenu = {
            kind_icons = true, -- LSP kind icons in completion menu
        },

        presets = {
            bottom_search         = false, -- use noice popup for / search
            command_palette       = true,  -- cmdline + popupmenu together
            long_message_to_split = true,  -- send long messages to a split
            inc_rename            = false,
            lsp_doc_border        = true,  -- border on hover docs and signature help
        },

        -- Suppress common low-signal messages
        routes = {
            -- Hide "N lines written" write confirmations
            { filter = { event = "msg_show", kind = "", find = "written" },        opts = { skip = true } },
            -- Hide search wrap messages
            { filter = { event = "msg_show", kind = "", find = "search hit" },     opts = { skip = true } },
            -- Hide "already at newest/oldest change" undo messages
            { filter = { event = "msg_show", kind = "", find = "already at" },     opts = { skip = true } },
        },
    },

    dependencies = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
    },
}
