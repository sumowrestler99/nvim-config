local function set_diagnostic_highlights()
    vim.api.nvim_set_hl(0, 'DiagnosticUnderlineWarning', { undercurl = true, sp = '#ffff00' })
    vim.api.nvim_set_hl(0, 'DiagnosticUnderlineError',   { undercurl = true, sp = 'Red'     })
    vim.api.nvim_set_hl(0, 'DiagnosticUnderlineInfo',    { undercurl = true, sp = 'White'   })
    vim.api.nvim_set_hl(0, 'DiagnosticUnderlineHint',    { undercurl = true, sp = 'Blue'    })
end

return function() -- This function is called by init.lua

    local lastplace = vim.api.nvim_create_augroup("LastPlace", {})
    vim.api.nvim_clear_autocmds({ group = lastplace })
    vim.api.nvim_create_autocmd("BufReadPost", {
        group = lastplace,
        pattern = { "*" },
        desc = "remember last cursor place",
        callback = function()
            local mark = vim.api.nvim_buf_get_mark(0, '"')
            local lcount = vim.api.nvim_buf_line_count(0)
            if mark[1] > 0 and mark[1] <= lcount then
                pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
        end,
    })
    -- Apply diagnostic highlights on startup and re-apply after any colorscheme change
    set_diagnostic_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
        group    = vim.api.nvim_create_augroup("DiagnosticHighlights", { clear = true }),
        pattern  = "*",
        callback = set_diagnostic_highlights,
    })

    -- Highlight on yank + send to local clipboard via OSC52.
    -- OSC52 copy works locally and over SSH without a terminal round-trip.
    vim.api.nvim_create_autocmd("TextYankPost", {
        group    = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
        callback = function()
            vim.highlight.on_yank()
            require('vim.ui.clipboard.osc52').copy('+')(vim.v.event.regcontents)
        end,
    })

    -- Auto-resize splits when terminal is resized
    vim.api.nvim_create_autocmd("VimResized", {
        group    = vim.api.nvim_create_augroup("ResizeSplits", { clear = true }),
        callback = function() vim.cmd("tabdo wincmd =") end,
    })

    vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("NeoTreeAutoOpen", { clear = true }),
        callback = function()
            local initial_buf_name = vim.api.nvim_buf_get_name(0)
            local initial_file_path = vim.fn.expand("%:p")
            if not string.match(initial_buf_name, "gdrive") and vim.fn.isdirectory(initial_file_path) ~= 0 then
                vim.cmd("Neotree toggle")
            end
        end,
    })

    -- Add dummy winbar to fugitive blame to align with file window
    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("FugitiveBlameWinbar", { clear = true }),
        pattern = "fugitiveblame",
        callback = function()
            vim.wo.winbar = " "
        end,
    })
end
