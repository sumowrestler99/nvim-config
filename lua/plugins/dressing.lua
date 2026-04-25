return {
    "stevearc/dressing.nvim",
    -- Already a dependency of avante; configure it standalone here.
    -- Load only when vim.ui.input or vim.ui.select is first called.
    init = function()
        vim.ui.select = function(...)
            require("lazy").load({ plugins = { "dressing.nvim" } })
            return vim.ui.select(...)
        end
        vim.ui.input = function(...)
            require("lazy").load({ plugins = { "dressing.nvim" } })
            return vim.ui.input(...)
        end
    end,
    opts = {
        input = {
            enabled      = true,
            default_prompt = "Input:",
            border        = "rounded",
            relative      = "cursor",  -- float near the cursor
            prefer_width  = 40,
            win_options   = {
                winblend    = 0,
                wrap        = false,
                list        = true,
                listchars   = "precedes:…,extends:…",
                sidescrolloff = 0,
            },
        },
        select = {
            enabled  = true,
            backend  = { "snacks", "telescope", "builtin" },
            builtin  = {
                border       = "rounded",
                min_height   = 1,
                win_options  = { winblend = 0 },
            },
        },
    },
}
