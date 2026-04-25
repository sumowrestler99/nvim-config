-- NvimGdb configuration override
-- This is a Vimscript variable, so assign it to vim.g
vim.g.nvimgdb_config_override = {
    key_next = 'n',
    key_step = 's',
    key_finish = 'f',
    key_continue = 'c',
    key_until = 'u',
    key_breakpoint = 'b',
    -- Define the set_tkeymaps function directly in Lua.
    -- This function will be called by nvim-gdb.
    set_tkeymaps = function()
        -- Ensure terminal keymaps are set correctly for the debugger CLI
        vim.api.nvim_set_keymap('t', '<esc>', '<c-\\><c-n>', { silent = true, buffer = true })
    end,
}
