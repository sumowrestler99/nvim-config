return {
  "nvim-neo-tree/neo-tree.nvim",
  branch       = "v3.x",
  cmd          = "Neotree",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    { "<leader>e",  "<cmd>Neotree toggle<cr>",           desc = "Toggle file tree" },
    { "<leader>ef", "<cmd>Neotree reveal<cr>",           desc = "Reveal file in tree" },
    { "<leader>eg", "<cmd>Neotree float git_status<cr>", desc = "Git status (float)" },
    { "<leader>eb", "<cmd>Neotree toggle buffers<cr>",   desc = "Toggle buffer list" },
  },
  opts = {
    close_if_last_window = true,
    enable_git_status    = true,
    enable_diagnostics   = true,

    default_component_configs = {
      indent = {
        indent_size          = 2,
        with_markers         = true,
        indent_marker        = "│",
        last_indent_marker   = "└",
        with_expanders       = true,
        expander_collapsed   = "",
        expander_expanded    = "",
      },
      icon = {
        folder_closed = "",
        folder_open   = "",
        folder_empty  = "",
      },
      modified = { symbol = "●" },
      git_status = {
        symbols = {
          added     = "",
          modified  = "",
          deleted   = "",
          renamed   = "󰁕",
          untracked = "",
          ignored   = "",
          unstaged  = "󰄱",
          staged    = "",
          conflict  = "",
        },
      },
      diagnostics = {
        symbols = {
          error = " ",
          warn  = " ",
          info  = " ",
          hint  = " ",
        },
        highlights = {
          error = "DiagnosticSignError",
          warn  = "DiagnosticSignWarn",
          info  = "DiagnosticSignInfo",
          hint  = "DiagnosticSignHint",
        },
      },
    },

    window = {
      position = "left",
      width    = 35,
      mappings = {
        ["<space>"] = "none",
        ["l"]       = "open",
        ["h"]       = "close_node",
        ["v"]       = "open_vsplit",
        ["s"]       = "open_split",
        ["P"]       = { "toggle_preview", config = { use_float = true } },
      },
    },

    filesystem = {
      filtered_items = {
        visible        = true,  -- show hidden/ignored but dimmed
        hide_dotfiles  = false,
        hide_gitignored = true,
        hide_by_name   = { ".git" },
      },
      follow_current_file = {
        enabled          = true,
        leave_dirs_open  = false,
      },
      group_empty_dirs = true,
      use_libuv_file_watcher = true,
    },

    buffers = {
      follow_current_file = { enabled = true },
    },

    git_status = {
      window = { position = "float" },
    },
  },
}
