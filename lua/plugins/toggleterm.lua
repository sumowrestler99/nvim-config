return {
    "akinsho/toggleterm.nvim",
    -- Normal and Insert, as open_mapping covers outside terminals; a
    -- Normal-only stub left Insert-mode <C-\> dead until the first load.
    keys = { { [[<C-\>]], mode = { "n", "i" }, desc = "toggleterm" } },
    -- Created only by setup() (toggleterm.lua:434-492).
    cmd = {
        "ToggleTerm", "ToggleTermToggleAll", "TermExec", "TermSelect", "TermNew",
        "ToggleTermSendCurrentLine", "ToggleTermSendVisualLines",
        "ToggleTermSendVisualSelection", "ToggleTermSetName",
    },
    opts = {
        -- size can be a number or function which is passed the current terminal
        size = 20,
        open_mapping = [[<c-\>]],
        -- <C-\> alone is the toggle inside terminal buffers and would fire
        -- before <C-\><C-n> could be typed. A longer buffer-local mapping
        -- makes Neovim wait for the second key, so the built-in escape to
        -- Terminal-Normal mode works again.
        on_create = function(t)
            vim.keymap.set("t", [[<C-\><C-n>]], [[<C-\><C-n>]],
                { buf = t.bufnr, desc = "Terminal-Normal mode" })
        end,
        --on_open = fun(t: Terminal), -- function to run when the terminal opens
        --on_close = fun(t: Terminal), -- function to run when the terminal closes
        --on_stdout = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stdout
        --on_stderr = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stderr
        --on_exit = fun(t: Terminal, job: number, exit_code: number, name: string) -- function to run when terminal process exits
        hide_numbers = true, -- hide the number column in toggleterm buffers
        shade_filetypes = {},
        autochdir = false, -- when neovim changes it current directory the terminal will change it's own when next it's opened
        --highlights = {
        --    -- highlights which map to a highlight group name and a table of it's values
        --    -- NOTE: this is only a subset of values, any group placed here will be set for the terminal window split
        --    Normal = {
        --        guibg = "<VALUE-HERE>",
        --    },
        --    NormalFloat = {
        --        link = 'Normal'
        --    },
        --    FloatBorder = {
        --        guifg = "<VALUE-HERE>",
        --        guibg = "<VALUE-HERE>",
        --    },
        --},
        shade_terminals = true, -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
        --shading_factor = '<number>', -- the percentage by which to lighten terminal background, default: -30 (gets multiplied by -3 if background is light)
        start_in_insert = true,
        insert_mappings = true, -- whether or not the open mapping applies in insert mode
        terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
        persist_size = true,
        persist_mode = true, -- if set to true (default) the previous terminal mode will be remembered
        --direction = 'vertical' | 'horizontal' | 'tab' | 'float',
        direction = 'float',
        close_on_exit = true, -- close the terminal window when the process exits
        shell = vim.o.shell, -- change the default shell
        auto_scroll = true, -- automatically scroll to the bottom on terminal output
        -- This field is only relevant if direction is set to 'float'
        float_opts = {
            -- The border key is *almost* the same as 'nvim_open_win'
            -- see :h nvim_open_win for details on borders however
            -- the 'curved' border is a custom border type
            -- not natively supported but implemented in this plugin.
            -- border = 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
            border = 'curved',
            -- like `size`, width and height can be a number or function which is passed the current terminal
            --width = <value>,
            --height = <value>,
            winblend = 3,
        },
        winbar = {
            enabled = false,
            name_formatter = function(term) --  term: Terminal
                return term.name
            end
        },
    },
    config = function(_, opts)
        require("toggleterm").setup(opts)
        -- Same for insert mode (insert_mappings): keep i_CTRL-\_CTRL-O/N.
        for _, lhs in ipairs({ [[<C-\><C-o>]], [[<C-\><C-n>]] }) do
            vim.keymap.set("i", lhs, lhs, { desc = "built-in " .. lhs })
        end
    end,
}
