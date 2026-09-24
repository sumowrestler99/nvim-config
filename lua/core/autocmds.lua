local function set_diagnostic_highlights()
    -- The group is DiagnosticUnderlineWarn, not ...Warning. nvim_set_hl happily
    -- creates the misspelled group, it just never gets linked to anything.
    vim.api.nvim_set_hl(0, 'DiagnosticUnderlineWarn',    { undercurl = true, sp = '#ffff00' })
    vim.api.nvim_set_hl(0, 'DiagnosticUnderlineError',   { undercurl = true, sp = 'Red'     })
    vim.api.nvim_set_hl(0, 'DiagnosticUnderlineInfo',    { undercurl = true, sp = 'White'   })
    vim.api.nvim_set_hl(0, 'DiagnosticUnderlineHint',    { undercurl = true, sp = 'Blue'    })
end

-- Files that should always open at the top: git's message and todo buffers.
local lastplace_skip = {
    COMMIT_EDITMSG     = true,
    MERGE_MSG          = true,
    TAG_EDITMSG        = true,
    NOTES_EDITMSG      = true,
    EDIT_DESCRIPTION   = true,
    ["git-rebase-todo"] = true,
}

return function() -- This function is called by init.lua

    local lastplace = vim.api.nvim_create_augroup("LastPlace", {})
    vim.api.nvim_clear_autocmds({ group = lastplace })
    vim.api.nvim_create_autocmd("BufReadPost", {
        group = lastplace,
        pattern = { "*" },
        desc = "remember last cursor place",
        callback = function(args)
            -- Once per buffer: BufReadPost fires again on every :e reload.
            if vim.b[args.buf].lastplace_done then return end
            vim.b[args.buf].lastplace_done = true
            -- By name, because filetype detection has not run yet here.
            if vim.bo[args.buf].buftype ~= "" or lastplace_skip[vim.fs.basename(args.file)] then
                return
            end
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
    --
    -- TextYankPost fires for deletes and changes too (:h TextYankPost), so
    -- the copy is limited to what a person would call "copying": an actual
    -- `y` into the unnamed or a clipboard register, typed rather than replayed
    -- from a macro. Without this, every `d`, `x` and `c` overwrote the system
    -- clipboard, as did `"ay` and any yank inside a macro.
    vim.api.nvim_create_autocmd("TextYankPost", {
        group    = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
        callback = function()
            vim.hl.on_yank()

            local ev = vim.v.event
            if ev.operator ~= "y" then return end
            if ev.regname ~= "" and ev.regname ~= "+" and ev.regname ~= "*" then return end
            if vim.fn.reg_executing() ~= "" then return end
            require('vim.ui.clipboard.osc52').copy('+')(ev.regcontents)
        end,
    })

    -- No persistent undo for scratch and secret files: an undo file is a
    -- full copy of the edit history, kept in stdpath('state')/undo.
    vim.api.nvim_create_autocmd("BufWritePre", {
        group    = vim.api.nvim_create_augroup("NoUndoFile", { clear = true }),
        pattern  = { "/tmp/*", "/private/tmp/*", "/dev/shm/*", "*.gpg", "*.asc", "*.env", "*/.ssh/*" },
        callback = function(args) vim.bo[args.buf].undofile = false end,
    })

    -- Auto-resize splits when terminal is resized
    vim.api.nvim_create_autocmd("VimResized", {
        group    = vim.api.nvim_create_augroup("ResizeSplits", { clear = true }),
        -- Not :tabdo, which enters every tab (firing Tab/Win/BufEnter) and
        -- changes the last-accessed tab used by g<Tab>. nvim_win_call runs
        -- the command in each tab's context without switching to it.
        -- pcall: switching context is refused from the cmdline window.
        callback = function()
            for _, tp in ipairs(vim.api.nvim_list_tabpages()) do
                pcall(vim.api.nvim_win_call, vim.api.nvim_tabpage_get_win(tp), function()
                    vim.cmd("wincmd =")
                end)
            end
        end,
    })

    vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("NeoTreeAutoOpen", { clear = true }),
        callback = function()
            local initial_buf_name = vim.api.nvim_buf_get_name(0)
            local initial_file_path = vim.fn.expand("%:p")
            if not string.match(initial_buf_name, "gdrive") and vim.fn.isdirectory(initial_file_path) ~= 0 then
                -- Rooted at the directory argument, not the cwd.
                vim.cmd.Neotree({ "toggle", "dir=" .. initial_file_path })
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
