return {
  {
    "mason-org/mason.nvim",
    cmd  = { "Mason", "MasonInstall", "MasonUpdate" },
    keys = {
      { "<leader>mi", "<cmd>Mason<cr>",        desc = "Open Mason UI" },
      { "<leader>mu", "<cmd>MasonUpdate<cr>",  desc = "Update Mason registries" },
    },
    opts = {
      ui = { border = "rounded" },
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "mason-org/mason.nvim", "mfussenegger/nvim-dap" },
    event = "VeryLazy",
    opts = {
      ensure_installed = { "codelldb", "cpptools", "debugpy", "checkmake" },
      automatic_installation = true,
    },
  },
}
