return {
    "HakonHarnes/img-clip.nvim",
    -- Load only when explicitly invoked via <leader>pi
    -- Not loaded as part of avante to prevent intercepting normal paste operations.
    cmd = "PasteImage",
    opts = {
        default = {
            embed_image_as_base64 = false,
            prompt_for_file_name  = false,
            drag_and_drop         = { insert_mode = false },
            use_absolute_path     = true,
        },
    },
}
