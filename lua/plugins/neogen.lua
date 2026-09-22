return {
  "danymat/neogen",
  -- Uncomment next line if you want to follow only stable versions
  -- version = "*"
  cmd = "Neogen",
  dependencies = { "L3MON4D3/LuaSnip" },
  -- The keymap has to be declared in the spec, not in config(). config() only
  -- runs once the plugin loads, and the only other trigger is `:Neogen`, so
  -- defining <Leader>nf there meant it did not exist until after you had
  -- already run the command it was a shortcut for.
  keys = {
    { "<Leader>nf", function() require("neogen").generate() end, desc = "Generate annotation" },
  },
  config = function()
    require("neogen").setup({ snippet_engine = "luasnip" })
  end,
}
