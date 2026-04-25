return {
    {
        'folke/snacks.nvim',
        lazy = false,
        priority = 1000,
        ---@type snacks.Config
        opts = {
            bigfile   = { enabled = true },
            indent    = {
            enabled = true,
            animate = {
                enabled  = true,
                style    = "up_down",
                easing   = "linear",
                duration = {
                    step  = 20,
                    total = 500,
                },
            },
        },
            picker    = { enabled = true },
            quickfile = { enabled = true },
            scroll    = { enabled = true },
            --dashboard = { enabled = true },
            --explorer = { enabled = true },
            --input = { enabled = true },
            --notifier = { enabled = true },
            --scope = { enabled = true },
            --statuscolumn = { enabled = true },
            --words = { enabled = true },
        },
        keys = {
            -- Files
            { '<leader>ff', function() Snacks.picker.files() end,         desc = 'Find files' },
            { '<leader>fr', function() Snacks.picker.recent() end,        desc = 'Recent files' },

            -- Search
            { '<leader>fg', function() Snacks.picker.grep() end,          desc = 'Live grep' },
            { '<leader>fw', function() Snacks.picker.grep_word() end,     desc = 'Grep word under cursor', mode = { 'n', 'x' } },
            { '<leader>fs', function() Snacks.picker.lsp_symbols() end,   desc = 'LSP symbols' },
            { '<leader>fS', function() Snacks.picker.lsp_workspace_symbols() end, desc = 'LSP workspace symbols' },

            -- Buffers & navigation
            { '<leader>fb', function() Snacks.picker.buffers() end,       desc = 'Buffers' },
            { '<leader>fj', function() Snacks.picker.jumps() end,         desc = 'Jump list' },

            -- Git
            { '<leader>gc', function() Snacks.picker.git_log() end,       desc = 'Git commits (repo)' },
            { '<leader>gC', function() Snacks.picker.git_log_file() end,  desc = 'Git commits (file)' },
            { '<leader>gs', function() Snacks.picker.git_status() end,    desc = 'Git status' },
            { '<leader>gb', function() Snacks.picker.git_branches() end,  desc = 'Git branches' },

            -- Vim
            { '<leader>f:', function() Snacks.picker.command_history() end, desc = 'Command history' },
            { '<leader>fh', function() Snacks.picker.help() end,           desc = 'Help tags' },
            { '<leader>fk', function() Snacks.picker.keymaps() end,        desc = 'Keymaps' },
            { '<leader>fd', function() Snacks.picker.diagnostics() end,    desc = 'Diagnostics' },
        },
    },
}
