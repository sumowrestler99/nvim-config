return {
  'folke/which-key.nvim',
  event = "VeryLazy",
  -- The 'config' function runs after the plugin is successfully loaded
  config = function()
    local wk = require("which-key")

    wk.add({
      -- LSP g-prefixed keys
      { "gd",    desc = "LSP Definition" },
      { "gD",    desc = "LSP Declaration" },
      { "gi",    desc = "LSP Implementation" },
      { "gr",    desc = "LSP References" },
      { "K",     desc = "LSP Hover" },
      { "<C-k>", desc = "LSP Signature Help" },
      -- Treesitter incremental selection
      { "gnn", desc = "TS Init selection" },
      { "grn", desc = "TS Increment node" },
      { "grc", desc = "TS Increment scope" },
      { "grm", desc = "TS Decrement node" },
      -- Treesitter textobjects: select (visual + operator-pending)
      { "af", mode = { "x", "o" }, desc = "TS Around function" },
      { "if", mode = { "x", "o" }, desc = "TS Inside function" },
      { "ac", mode = { "x", "o" }, desc = "TS Around class" },
      { "ic", mode = { "x", "o" }, desc = "TS Inside class" },
      { "aa", mode = { "x", "o" }, desc = "TS Around parameter" },
      { "ia", mode = { "x", "o" }, desc = "TS Inside parameter" },
      { "ax", mode = { "x", "o" }, desc = "TS Around conditional" },
      { "ix", mode = { "x", "o" }, desc = "TS Inside conditional" },
      { "al", mode = { "x", "o" }, desc = "TS Around loop" },
      { "il", mode = { "x", "o" }, desc = "TS Inside loop" },
      -- Treesitter textobjects: move
      { "]m", mode = { "n", "x", "o" }, desc = "TS Next function start" },
      { "]M", mode = { "n", "x", "o" }, desc = "TS Next function end" },
      { "[m", mode = { "n", "x", "o" }, desc = "TS Prev function start" },
      { "[M", mode = { "n", "x", "o" }, desc = "TS Prev function end" },
      { "]]", mode = { "n", "x", "o" }, desc = "TS Next class start" },
      { "[[", mode = { "n", "x", "o" }, desc = "TS Prev class start" },
      -- Treesitter textobjects: swap
      { "<leader>a", desc = "TS Swap next parameter" },
      { "<leader>A", desc = "TS Swap prev parameter" },
      -- Diagnostic navigation
      { "[d", desc = "Prev Diagnostic" },
      { "]d", desc = "Next Diagnostic" },
      -- <leader> groups
      { "<leader>u",  group = "Undo" },
      { "<leader>ut", desc = "Toggle undotree" },
      { "<leader>f",  group = "Find" },
      { "<leader>ft", desc = "Todo comments" },
      { "]t", desc = "Next todo" },
      { "[t", desc = "Prev todo" },
      { "<leader>w",  desc = "Save file" },
      { "<leader>e",  desc = "Toggle file tree" },
      { "<leader>ef", desc = "Reveal file in tree" },
      { "<leader>pi", desc = "Paste image" },
      { "<leader>n",  group = "Neogen" },
      { "<leader>nf", desc = "Generate annotation" },
      { "<leader>g",  group = "Git" },
      { "<leader>gd", desc = "Diffview open" },
      { "<leader>gh", desc = "Diffview file history" },
      { "<leader>gH", desc = "Diffview repo history" },
      { "<leader>gx", desc = "Diffview close" },
      { "<leader>d",  group = "Debug" },
      { "<leader>db", desc = "Toggle breakpoint" },
      { "<leader>dB", desc = "Conditional breakpoint" },
      { "<leader>dc", desc = "Continue" },
      { "<leader>dn", desc = "Step over" },
      { "<leader>ds", desc = "Step into" },
      { "<leader>df", desc = "Step out" },
      { "<leader>dr", desc = "Open REPL" },
      { "<leader>dl", desc = "Run last" },
      { "<leader>du", desc = "Toggle DAP UI" },
      { "<leader>dx", desc = "Terminate" },
      { "<leader>dK", desc = "Hover value" },
      { "<leader>dC", desc = "Run to cursor" },
      -- Fn keys (active only during a DAP session)
      { "<F5>",  desc = "DAP Continue (session)" },
      { "<F9>",  desc = "DAP Toggle breakpoint (session)" },
      { "<F10>", desc = "DAP Step over (session)" },
      { "<F11>", desc = "DAP Step into (session)" },
      { "<F12>", desc = "DAP Step out (session)" },
      -- <space> LSP keys
      { "<space>e",  desc = "Diagnostic float" },
      { "<space>q",  desc = "Diagnostic loclist" },
      { "<space>D",  desc = "LSP Type Definition" },
      { "<space>rn", desc = "LSP Rename" },
      { "<space>ca", desc = "LSP Code Action" },
      { "<space>f",  desc = "LSP Format buffer" },
      { "<space>w",  group = "Workspace" },
      { "<space>wa", desc = "Add workspace folder" },
      { "<space>wr", desc = "Remove workspace folder" },
      { "<space>wl", desc = "List workspace folders" },
      -- Visual mode
      { "\\qf", mode = "v", desc = "LSP Range Format" },
      -- Mason
      { "<leader>m",  group = "Mason" },
      { "<leader>mi", "<cmd>Mason<cr>",       desc = "Open Mason UI" },
      { "<leader>mu", "<cmd>MasonUpdate<cr>", desc = "Update Mason registries" },
      -- Function keys
      { "<F4>", desc = "Toggle tab width 2/4" },
    })
  end,
}
