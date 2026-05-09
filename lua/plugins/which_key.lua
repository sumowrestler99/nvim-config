return {
  'folke/which-key.nvim',
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")

    wk.add({
      -- LSP g-prefixed keys
      { "gd",    desc = "LSP Definition",       icon = { icon = "󰌹", color = "blue"   } },
      { "gD",    desc = "LSP Declaration",       icon = { icon = "󰌹", color = "grey"   } },
      { "gi",    desc = "LSP Implementation",    icon = { icon = "󰰱", color = "blue"   } },
      { "gr",    desc = "LSP References",        icon = { icon = "󰈇", color = "blue"   } },
      { "K",     desc = "LSP Hover",             icon = { icon = "󰋖", color = "cyan"   } },
      { "<C-k>", desc = "LSP Signature Help",    icon = { icon = "󰊕", color = "cyan"   } },

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
      { "[d", desc = "Prev Diagnostic", icon = { icon = "󰒕", color = "yellow" } },
      { "]d", desc = "Next Diagnostic", icon = { icon = "󰒕", color = "yellow" } },

      -- <leader> groups
      { "<leader>u",  group = "Undo",      icon = { icon = "󰑖", color = "yellow" } },
      { "<leader>ut", desc = "Toggle undotree" },
      { "<leader>ul", desc = "Toggle layout guides (clean mode)", icon = { icon = "󰒉", color = "grey" } },

      { "<leader>f",  group = "Find",      icon = { icon = "󰍉", color = "blue"   } },
      { "<leader>ft", desc = "Todo comments" },
      { "]t", desc = "Next todo",  icon = { icon = "󰄲", color = "blue" } },
      { "[t", desc = "Prev todo",  icon = { icon = "󰄲", color = "blue" } },

      { "<leader>w",  desc = "Save file",        icon = { icon = "󰆓", color = "blue"   } },

      { "<leader>e",  desc = "Toggle file tree",        icon = { icon = "󰙅", color = "green"  } },
      { "<leader>ef", desc = "Reveal file in tree",     icon = { icon = "󰈞", color = "green"  } },
      { "<leader>eg", desc = "Git status (float)",      icon = { icon = "󰊢", color = "orange" } },
      { "<leader>eb", desc = "Toggle buffer list",      icon = { icon = "󰓩", color = "blue"   } },

      { "<leader>pi", desc = "Paste image",             icon = { icon = "󰋩", color = "cyan"   } },

      { "<leader>n",  group = "Neogen",    icon = { icon = "󰆉", color = "cyan"   } },
      { "<leader>nf", desc = "Generate annotation" },

      { "<leader>g",  group = "Git",       icon = { icon = "󰊢", color = "orange" } },
      { "<leader>gd", desc = "Diffview open" },
      { "<leader>gh", desc = "Diffview file history" },
      { "<leader>gH", desc = "Diffview repo history" },
      { "<leader>gx", desc = "Diffview close" },

      { "<leader>d",  group = "Debug",     icon = { icon = "󰃤", color = "red"    } },
      { "<leader>db", desc = "Toggle breakpoint" },
      { "<leader>dB", desc = "Conditional breakpoint" },
      { "<leader>dc", desc = "Continue" },
      { "<leader>dC", desc = "Run to cursor" },
      { "<leader>dn", desc = "Step over" },
      { "<leader>ds", desc = "Step into" },
      { "<leader>df", desc = "Step out" },
      { "<leader>dr", desc = "Open REPL" },
      { "<leader>dl", desc = "Run last" },
      { "<leader>du", desc = "Toggle DAP UI" },
      { "<leader>dx", desc = "Terminate" },
      { "<leader>dK", desc = "Hover value" },

      -- Fn keys (active only during a DAP session)
      { "<F5>",  desc = "DAP Continue (session)" },
      { "<F9>",  desc = "DAP Toggle breakpoint (session)" },
      { "<F10>", desc = "DAP Step over (session)" },
      { "<F11>", desc = "DAP Step into (session)" },
      { "<F12>", desc = "DAP Step out (session)" },

      -- <space> LSP keys
      { "<space>e",  desc = "Diagnostic float",         icon = { icon = "󰒕", color = "yellow" } },
      { "<space>q",  desc = "Diagnostic loclist",        icon = { icon = "󰒕", color = "yellow" } },
      { "<space>D",  desc = "LSP Type Definition" },
      { "<space>rn", desc = "LSP Rename",                icon = { icon = "󰑕", color = "blue"   } },
      { "<space>ca", desc = "LSP Code Action",           icon = { icon = "󰌵", color = "yellow" } },
      { "<space>f",  desc = "LSP Format buffer",         icon = { icon = "󰉼", color = "blue"   } },
      { "<space>w",  group = "Workspace",  icon = { icon = "󰉋", color = "blue"   } },
      { "<space>wa", desc = "Add workspace folder" },
      { "<space>wr", desc = "Remove workspace folder" },
      { "<space>wl", desc = "List workspace folders" },

      -- Visual mode
      { "\\qf", mode = "v", desc = "LSP Range Format" },

      -- Mason
      { "<leader>m",  group = "Mason",     icon = { icon = "󰏗", color = "purple" } },
      { "<leader>mi", "<cmd>Mason<cr>",       desc = "Open Mason UI" },
      { "<leader>mu", "<cmd>MasonUpdate<cr>", desc = "Update Mason registries" },

      -- Function keys
      { "<F4>", desc = "Toggle tab width 2/4" },
    })
  end,
}
