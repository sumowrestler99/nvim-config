-- Optional machine-local overrides (provider, ACP backend). Empty table when
-- lua/local/avante.lua does not exist.
local extra = require('core.local').get('avante')

return {
    "yetone/avante.nvim",
    enabled = true, -- Re-enabled
    event   = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    -- Native Rust libs (avante_tokenizers/templates/repo_map/html2md).
    -- On Unix `make` shells out to `cargo`, which is not installed everywhere.
    -- Rather than letting every :Lazy update fail, skip the build when cargo is
    -- missing: the already-compiled .so files in lua/ stay API-compatible
    -- (crate changes since they were built are dependency bumps only).
    -- To enable native rebuilds:  install cargo, then  :Lazy build avante.nvim
    build   = (function()
        if vim.fn.has("win32") ~= 0 then
            -- Windows path downloads prebuilt binaries, so it needs no toolchain.
            return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
        end
        if vim.fn.executable("cargo") == 0 then
            return false
        end
        return "make"
    end)(),


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

        -- A machine-local module may point avante at a different backend (for
        -- example a corp-only CLI exposed over ACP). Without one, fall back to
        -- the public API-key provider configured below.
        provider      = extra.provider or "gemini",
        acp_providers = extra.acp_providers,

        providers = {
            -- Used unless a machine-local module overrides `provider` above.
            -- Requires GEMINI_API_KEY in the environment.
            gemini = {
                -- @see https://ai.google.dev/gemini-api/docs/models/gemini
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
