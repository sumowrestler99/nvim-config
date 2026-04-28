return {
  "danymat/neogen",
  -- Uncomment next line if you want to follow only stable versions
  -- version = "*"
    -- Load neogen only when the :Neogen command is executed.
    cmd = "Neogen",
    dependencies = { "L3MON4D3/LuaSnip" },
  -- The 'config' function runs after the plugin is successfully loaded
  config = function()
    require('neogen').setup({ snippet_engine = "luasnip" })

    vim.keymap.set("n", "<Leader>nf", function() require('neogen').generate() end, { noremap = true, silent = true })
  end,
}
