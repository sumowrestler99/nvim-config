-- Optional machine-local overrides (provider, ACP backend). Empty table when
-- lua/local/avante.lua does not exist.
local extra = require('core.local').get('avante')

return {
    "yetone/avante.nvim",
    -- Entry points, NOT `event = "VeryLazy"`.
    --
    -- lazy.nvim loads *and configures* a plugin's `dependencies` unconditionally
    -- when the parent loads, ignoring each dependency's own trigger
    -- (lazy/core/loader.lua:352-356). With avante on VeryLazy that dragged
    -- nvim-cmp (`event = "InsertEnter"`), dressing.nvim (`lazy = true`) and
    -- render-markdown (`ft`) into startup with it, costing ~35 ms for a
    -- sidebar that may never be opened.
    --
    -- The commands come from avante's plugin/avante.lua, which is sourced by
    -- packadd when the plugin loads.
    cmd = {
        "AvanteAsk", "AvanteChat", "AvanteChatNew", "AvanteToggle", "AvanteEdit",
        "AvanteRefresh", "AvanteFocus", "AvanteStop", "AvanteClear", "AvanteHistory",
        "AvanteModels", "AvanteShowRepoMap", "AvanteBuild",
        "AvanteSwitchProvider", "AvanteSwitchSelectorProvider", "AvanteSwitchInputProvider",
        "AvanteACPModels", "AvanteACPModes",
    },
    -- These mirror avante's own defaults (avante/config.lua:755-797), but the
    -- <Plug> targets MUST be spelled out rather than left as bare lhs stubs.
    --
    -- avante sets its keymaps through Utils.safe_keymap_set, which drops any
    -- mode where lazy's keys handler reports `Keys:have(lhs, mode)`
    -- (avante/utils/init.lua:243). That reads `self.managed`, which still holds
    -- the entry after the stub has deleted itself -- so avante would decline to
    -- install the real mapping, and lazy's `_set` creates nothing for a spec
    -- entry with no rhs. The key would be dead after its first press.
    --
    -- Naming the <Plug> target hands ownership to lazy, which is precisely what
    -- safe_keymap_set is written to defer to. `remap = true` is required:
    -- <Plug> mappings are not resolved under noremap.
    keys = {
        { "<leader>aa", "<Plug>(AvanteAsk)",              mode = { "n", "v" }, remap = true, desc = "avante: ask" },
        { "<leader>an", "<Plug>(AvanteAskNew)",           mode = { "n", "v" }, remap = true, desc = "avante: new ask" },
        { "<leader>az", "<Plug>(AvanteZenMode)",          mode = { "n", "v" }, remap = true, desc = "avante: zen mode" },
        { "<leader>ae", "<Plug>(AvanteEdit)",             mode = "v",          remap = true, desc = "avante: edit" },
        { "<leader>ar", "<Plug>(AvanteRefresh)",          mode = "n",          remap = true, desc = "avante: refresh" },
        { "<leader>af", "<Plug>(AvanteFocus)",            mode = "n",          remap = true, desc = "avante: focus" },
        { "<leader>aS", "<Plug>(AvanteStop)",             mode = "n",          remap = true, desc = "avante: stop" },
        { "<leader>at", "<Plug>(AvanteToggle)",           mode = "n",          remap = true, desc = "avante: toggle" },
        { "<leader>ad", "<Plug>(AvanteToggleDebug)",      mode = "n",          remap = true, desc = "avante: toggle debug" },
        { "<leader>aC", "<Plug>(AvanteToggleSelection)",  mode = "n",          remap = true, desc = "avante: toggle selection" },
        { "<leader>as", "<Plug>(AvanteToggleSuggestion)", mode = "n",          remap = true, desc = "avante: toggle suggestion" },
        { "<leader>aR", "<Plug>(AvanteShowRepoMap)",      mode = "n",          remap = true, desc = "avante: show repo map" },
        { "<leader>a?", "<Plug>(AvanteSelectModel)",      mode = "n",          remap = true, desc = "avante: select model" },
        { "<leader>ah", "<Plug>(AvanteSelectHistory)",    mode = "n",          remap = true, desc = "avante: select history" },
        { "<leader>aM", "<Plug>(AvanteSelectACPModel)",   mode = "n",          remap = true, desc = "avante: select ACP model" },
        { "<leader>am", "<Plug>(AvanteSelectACPMode)",    mode = "n",          remap = true, desc = "avante: select ACP mode" },
        { "<leader>aB", "<Plug>(AvanteAddAllBuffers)",    mode = "n",          remap = true, desc = "avante: add all buffers" },
    },
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
        "MeanderingProgrammer/render-markdown.nvim", -- configured in render-markdown.lua
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
            -- Has no effect: avante replaces it with "is img-clip installed"
            -- (avante/config.lua:1216,1275) and wraps vim.paste, requiring
            -- img-clip on the first paste in any buffer. The wrapper only acts in
            -- AvanteInput; img-clip's own paste hook is off (img-clip.lua).
            support_paste_from_clipboard     = false,
            -- The default is true (avante/config.lua:683): in agentic mode every
            -- tool, shell commands and file writes included, would run without
            -- a confirmation prompt.
            auto_approve_tool_permissions    = false,
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
