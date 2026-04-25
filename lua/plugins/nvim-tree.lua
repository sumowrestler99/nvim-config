return {
    "nvim-tree/nvim-tree.lua",
    cmd          = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
        { "<leader>e",  "<cmd>NvimTreeToggle<cr>",   desc = "Toggle file tree" },
        { "<leader>ef", "<cmd>NvimTreeFindFile<cr>", desc = "Reveal file in tree" },
    },
    config = function()
        require("nvim-tree").setup({
            disable_netrw = false, -- keep netrw for scp:// remote file editing
            hijack_netrw  = true,

            -- Highlight the file currently open in the editor
            update_focused_file = {
                enable      = true,
                update_root = false, -- don't change root when following file
            },

            view = {
                width            = 35,
                side             = "left",
                preserve_window_proportions = true,
            },

            renderer = {
                group_empty        = true,  -- collapse single-child dirs
                highlight_git      = true,  -- color filenames by git status
                highlight_modified = "name",
                root_folder_label  = ":~:s?$?/..?", -- show relative root
                indent_markers = {
                    enable = true,
                },
                icons = {
                    git_placement = "before",
                    modified_placement = "after",
                    show = {
                        file         = true,
                        folder       = true,
                        folder_arrow = true,
                        git          = true,
                        modified     = true,
                    },
                },
            },

            -- Git integration
            git = {
                enable  = true,
                ignore  = false, -- show git-ignored files (dimmed)
                timeout = 500,
            },

            -- Show modified buffers indicator
            modified = {
                enable = true,
            },

            -- LSP diagnostics in tree
            diagnostics = {
                enable = true,
                show_on_dirs = true,
                icons = {
                    error   = "",
                    warning = "",
                    hint    = "",
                    info    = "",
                },
            },

            filters = {
                dotfiles = false, -- show dotfiles
                custom   = { "^.git$" },
            },

            actions = {
                open_file = {
                    quit_on_open  = false, -- keep tree open after opening file
                    resize_window = false,
                },
            },

            -- Live filter (press f in tree to filter)
            live_filter = {
                always_show_folders = false,
            },
        })
    end,
}
