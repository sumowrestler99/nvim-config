return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end,                                desc = "Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end,        desc = "Conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end,                                         desc = "Continue" },
      { "<leader>dn", function() require("dap").step_over() end,                                        desc = "Step over" },
      { "<leader>ds", function() require("dap").step_into() end,                                        desc = "Step into" },
      { "<leader>df", function() require("dap").step_out() end,                                         desc = "Step out" },
      { "<leader>dr", function() require("dap").repl.open() end,                                        desc = "Open REPL" },
      { "<leader>dl", function() require("dap").run_last() end,                                         desc = "Run last" },
      { "<leader>du", function() require("dapui").toggle() end,                                         desc = "Toggle DAP UI" },
      { "<leader>dx", function() require("dap").terminate() end,                                        desc = "Terminate" },
      { "<leader>dK", function() require("dap.ui.widgets").hover() end,                                 desc = "Hover value" },
    },
    config = function()
      local dap     = require("dap")
      local dapui   = require("dapui")

      -- Auto-open/close UI on session start/end
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]     = function() dapui.close() end

      -- codelldb adapter (installed via Mason)
      dap.adapters.codelldb = {
        type    = "server",
        port    = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
          args    = { "--port", "${port}" },
        },
      }

      -- C / C++ configurations
      dap.configurations.cpp = {
        {
          name    = "Launch (codelldb)",
          type    = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd            = "${workspaceFolder}",
          stopOnEntry    = false,
          args           = function()
            local input = vim.fn.input("Args (space-separated): ")
            return vim.split(input, " ", { trimempty = true })
          end,
        },
      }
      dap.configurations.c = dap.configurations.cpp

      -- Virtual text: show variable values inline while debugging
      require("nvim-dap-virtual-text").setup({
        commented = true,
      })

      -- DAP UI layout
      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes",      size = 0.4 },
              { id = "breakpoints", size = 0.2 },
              { id = "stacks",      size = 0.2 },
              { id = "watches",     size = 0.2 },
            },
            size     = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl",    size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size     = 12,
            position = "bottom",
          },
        },
      })
    end,
  },
}
