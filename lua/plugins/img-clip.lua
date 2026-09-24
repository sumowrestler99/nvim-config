return {
    "HakonHarnes/img-clip.nvim",
    -- Load only when explicitly invoked via <leader>pi
    -- Not loaded as part of avante to prevent intercepting normal paste operations.
    cmd = "PasteImage",
    opts = {
        default = {
            embed_image_as_base64 = false,
            prompt_for_file_name  = false,
            -- Off entirely. When enabled (the default, img-clip/config.lua:47)
            -- img-clip replaces vim.paste (plugin/img-clip.lua:43-85) and tries
            -- every one- or two-line paste as an image path or URL. That applies
            -- whenever the plugin is loaded -- and avante loads it on the first
            -- paste anywhere (see avante.lua).
            drag_and_drop         = { enabled = false },
            use_absolute_path     = true,
        },
    },
}
