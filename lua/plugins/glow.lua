return {
    "ellisonleao/glow.nvim",
    -- :Glow is its only entry point, so there is nothing to load for until
    -- it is run.
    cmd = "Glow",
    -- Only with the glow CLI installed. Otherwise :Glow downloads a release
    -- tarball into the cwd and unpacks it into ~/.local/bin, unverified
    -- (glow.lua:299-347).
    cond = function() return vim.fn.executable("glow") == 1 end,
    opts = {}
}
