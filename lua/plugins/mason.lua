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
    -- No trigger of its own: this is pulled in by nvim-dap.lua, which lists it
    -- as a dependency and loads on its own 12 debug keymaps.
    --
    -- It used to be `event = "VeryLazy"`, and since it depends on nvim-dap that
    -- dragged the whole 220-line DAP config plus nvim-dap-ui, nvim-nio and
    -- nvim-dap-virtual-text into startup -- ~30 ms for a debugger you may never
    -- start. `lazy = true` is explicit rather than implied, because a spec with
    -- no trigger and no `lazy` key resolves to EAGER, which would be worse.
    lazy = true,
    opts = {
      -- These are nvim-dap ADAPTER names, not Mason package names.
      -- ensure_installed.lua:8 looks each one up in
      -- mappings/source.lua's `nvim_dap_to_package` table and silently skips
      -- anything it cannot resolve, so the previous list
      -- ({codelldb, cpptools, debugpy, bash-debug-adapter, checkmake}) only ever
      -- matched `codelldb`. checkmake is a linter and was never installable here.
      --   cppdbg -> cpptools, python -> debugpy, bash -> bash-debug-adapter
      ensure_installed = { "codelldb", "cppdbg", "python", "bash" },

      -- `automatic_installation` is deliberately off.
      --
      -- It derives its package list from `dap.adapters`
      -- (automatic_installation.lua:6), which is now empty when this runs:
      -- lazy.nvim configures dependencies BEFORE the parent, so this config
      -- executes before nvim-dap's own config registers the adapters. It would
      -- be a silent no-op. It is also redundant -- `ensure_installed` above now
      -- names all four adapters explicitly.
    },
  },
}
