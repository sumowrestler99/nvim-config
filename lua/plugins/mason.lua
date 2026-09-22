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
      -- These are nvim-dap ADAPTER names, not Mason package names.
      -- ensure_installed.lua:8 looks each one up in
      -- mappings/source.lua's `nvim_dap_to_package` table and silently skips
      -- anything it cannot resolve, so the previous list
      -- ({codelldb, cpptools, debugpy, bash-debug-adapter, checkmake}) only ever
      -- matched `codelldb`. checkmake is a linter and was never installable here.
      --   cppdbg -> cpptools, python -> debugpy, bash -> bash-debug-adapter
      ensure_installed = { "codelldb", "cppdbg", "python", "bash" },
      automatic_installation = true,
    },
  },
}
