return {
  "sphamba/smear-cursor.nvim",
  enabled = true, -- Re-enabled per user request
  event = "VeryLazy",
  opts  = {
    smear_between_buffers    = true,
    smear_between_neighbor_lines = true,
    scroll_buffer_space      = true,
    legacy_computing_symbols_support = false,
  },
}
