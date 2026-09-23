return {
  "nvim-lualine/lualine.nvim",
  dependencies = 'nvim-tree/nvim-web-devicons',
  -- Load-bearing. A spec with no event/ft/cmd/keys and no explicit `lazy` key
  -- resolves to `lazy = false` (lazy/core/plugin.lua:235-243), so this was
  -- loading eagerly at startup by accident -- unlike barbecue, catppuccin and
  -- snacks, which are eager deliberately and say so.
  --
  -- The statusline is not needed before the first redraw, so VeryLazy is right.
  event = "VeryLazy",
  -- NOTE: these values currently match lualine's own defaults byte for byte
  -- (lualine/config.lua:12-14). They are kept deliberately, to pin the
  -- appearance against upstream default changes, not because they do anything
  -- today.
  opts = {
    options = {
      theme = "auto", -- Automatically match colorscheme
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = ''},
    },
  },
}
