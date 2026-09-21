return {
  "nvim-lualine/lualine.nvim",
  enabled = true, -- Re-enabled with default config
  dependencies = 'nvim-tree/nvim-web-devicons',
  opts = {
    options = {
      theme = "auto", -- Automatically match colorscheme
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = ''},
    },
  },
}
