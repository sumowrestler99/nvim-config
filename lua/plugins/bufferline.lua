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
        -- The defaults are "bdelete! %d", which throws away unsaved changes
        -- on a click. Snacks.bufdelete asks first and keeps the layout.
        close_command       = function(n) Snacks.bufdelete(n) end,
        right_mouse_command = function(n) Snacks.bufdelete(n) end,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(count, level)
          local icons = {
            error   = " ",
            warning = " ",
            info    = " ",
            hint    = " ",
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
