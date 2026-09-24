return {
  "nvim-lualine/lualine.nvim",
  dependencies = 'nvim-tree/nvim-web-devicons',
  -- Load-bearing. A spec with no event/ft/cmd/keys and no explicit `lazy` key
  -- resolves to `lazy = false` (lazy/core/plugin.lua:235-243). The original
  -- spec was eager on purpose (`lazy = false, priority = 900`); VeryLazy
  -- replaces that because the statusline is not needed before the first
  -- redraw.
  event = "VeryLazy",
  -- NOTE: theme and separators match lualine's own defaults byte for byte
  -- (lualine/config.lua:12-14). They are kept deliberately, to pin the
  -- appearance against upstream default changes, not because they do anything
  -- today.
  opts = {
    options = {
      theme = "auto", -- Automatically match colorscheme
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = ''},
      -- No statusline inside the sidebars. From the original config; lost in
      -- the ed8348c rewrite.
      disabled_filetypes = { "neo-tree", "Avante", "AvanteInput" },
    },
  },
}
