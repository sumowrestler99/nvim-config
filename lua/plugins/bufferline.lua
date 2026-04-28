return {
  "akinsho/bufferline.nvim",
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
    event = "VeryLazy",
  -- The 'config' function runs after the plugin is successfully loaded
  config = function()
    require("bufferline").setup {
      options = {
        separator_style = "padded_slant",
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(count, level)
          local icons = {
            error   = " ",
            warning = " ",
            info    = " ",
            hint    = " ",
          }
          return (icons[level] or "") .. count
        end,
        hover = {
          enabled = true,
          delay = 200,
          reveal = {'close'}
        }
      }
    }
  end,
}
