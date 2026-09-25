return {
    {
        'folke/snacks.nvim',
        lazy = false,
        priority = 1000,
        init = function()
            -- snacks' bigfile detector returns nothing for a buffer whose ft
            -- is already "bigfile" (so its setup can look up the real ft).
            -- A reload (:edit, :checktime, autoread) then re-detected the
            -- file as its real ft, with treesitter, LSP, cmp, gitsigns and
            -- ufo all back on. Clear the ft, without FileType autocmds,
            -- before the re-read so detection starts fresh.
            vim.api.nvim_create_autocmd("BufReadPre", {
                group    = vim.api.nvim_create_augroup("local_bigfile_reload", { clear = true }),
                callback = function(ev)
                    if vim.bo[ev.buf].filetype == "bigfile" then
                        vim.api.nvim_buf_call(ev.buf, function()
                            vim.cmd("noautocmd setlocal filetype=")
                        end)
                    end
                end,
            })
        end,
        ---@type snacks.Config
        opts = {
            -- Same threshold as nvim-treesitter.lua's highlight guard. Files
            -- over it get ft=bigfile, which ufo, cmp and gitsigns also skip.
            bigfile   = { enabled = true, size = 500 * 1024 },
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
            -- vim.ui.input. vim.ui.select comes from the picker (`ui_select`,
            -- on by default). Both replace the archived dressing.nvim.
            input     = { enabled = true },
            picker    = { enabled = true },
            quickfile = { enabled = true },
            scroll    = { enabled = true },
            --dashboard = { enabled = true },
            --explorer = { enabled = true },
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
