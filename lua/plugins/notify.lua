return {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
        require("notify").setup({
            background_colour = "#000000",
            icons = {
                ERROR = "",
                WARN  = "",
                INFO  = "",
                DEBUG = "",
                TRACE = "",
            },
        })
    end,
}
