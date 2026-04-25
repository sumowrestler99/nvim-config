return {
    "yetone/avante.nvim",
    event   = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    build   = vim.fn.has("win32") ~= 0
        and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
        or  "make",

    dependencies = {
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "folke/snacks.nvim",               -- file selector + input provider
        "hrsh7th/nvim-cmp",                -- autocompletion for avante commands
        "nvim-tree/nvim-web-devicons",
        -- img-clip loaded separately (see img-clip.lua / <leader>pi)
        -- Removed from here to prevent it intercepting normal paste operations.
        {
            "MeanderingProgrammer/render-markdown.nvim",
            ft   = { "markdown", "Avante" },
            opts = { file_types = { "markdown", "Avante" } },
        },
    },

    ---@module 'avante'
    opts = {
        mode = "agentic", -- "agentic" | "legacy"

        provider = "gemini",

        providers = {
            gemini = {
                model       = "gemini-2.5-flash",
                temperature = 0,
                max_tokens  = 8192,
            },
        },

        behaviour = {
            auto_suggestions                 = false,
            auto_set_highlight_group         = true,
            auto_set_keymaps                 = true,
            auto_apply_diff_after_generation = false,
            support_paste_from_clipboard     = false,
        },

        -- UI windows
        windows = {
            position = "right",  -- sidebar on the right
            wrap     = true,     -- wrap long lines
            width    = 35,       -- % of total window width

            sidebar_header = {
                enabled = true,
                align   = "center",
                rounded = true,
            },

            input = {
                prefix = " ",   -- prompt prefix icon
                height = 8,      -- input box height in lines
            },

            edit = {
                border       = "rounded",
                start_insert = true,
            },

            ask = {
                floating       = false,
                start_insert   = true,
                border         = "rounded",
                focus_on_apply = "ours",
            },
        },

        hints     = { enabled = false },
        selection = { hint_display = "none" },

        -- Diff view
        diff = {
            autojump    = true,
            list_opener = "copen",
        },

        -- Use catppuccin-compatible diff highlights
        highlights = {
            diff = {
                current  = "DiffText",
                incoming = "DiffAdd",
            },
        },
    },
}
