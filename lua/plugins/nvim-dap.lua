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
      { "<leader>dC", function() require("dap").run_to_cursor() end,                                    desc = "Run to cursor" },
    },
    config = function()
      local dap     = require("dap")
      local dapui   = require("dapui")

      -- Gutter signs
      vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DapBreakpoint",         linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected",  { text = "●", texthl = "DapBreakpointRejected",  linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint",            { text = "◉", texthl = "DapLogPoint",            linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DapStopped",             linehl = "DapStoppedLine", numhl = "" })


      -- Fn keys active only during a debug session
      local debug_fn_keys = {
        { key = "<F5>",  fn = function() dap.continue() end },
        { key = "<F9>",  fn = function() dap.toggle_breakpoint() end },
        { key = "<F10>", fn = function() dap.step_over() end },
        { key = "<F11>", fn = function() dap.step_into() end },
        { key = "<F12>", fn = function() dap.step_out() end },
      }
      local function set_fn_keys()
        for _, map in ipairs(debug_fn_keys) do
          vim.keymap.set("n", map.key, map.fn, { silent = true })
        end
      end
      local function del_fn_keys()
        for _, map in ipairs(debug_fn_keys) do
          pcall(vim.keymap.del, "n", map.key)
        end
      end

      -- Auto-open UI on session start; leave it open on exit so output is readable
      dap.listeners.after.event_initialized["dapui_config"]     = function() dapui.open() end
      dap.listeners.after.event_initialized["dap_fn_keys"]      = set_fn_keys
      dap.listeners.before.event_terminated["dap_fn_keys"]      = del_fn_keys
      dap.listeners.before.event_exited["dap_fn_keys"]          = del_fn_keys

      -- codelldb adapter (installed via Mason)
      dap.adapters.codelldb = {
        type    = "server",
        port    = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
          args    = { "--port", "${port}" },
        },
      }

      -- cppdbg adapter (ms-vscode.cpptools) — works with GDB 7+ for gdbserver
      dap.adapters.cppdbg = {
        type    = "executable",
        command = vim.fn.stdpath("data") .. "/mason/bin/OpenDebugAD7",
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
        {
          name                     = "Attach to gdbserver",
          type                     = "cppdbg",
          request                  = "launch",
          program                  = function()
            return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          miDebuggerServerAddress  = function()
            return vim.fn.input("gdbserver (host:port): ", "localhost:1234")
          end,
          miDebuggerPath           = "gdb",
          cwd                      = "${workspaceFolder}",
          stopAtEntry              = false,
        },
      }
      dap.configurations.c = dap.configurations.cpp

      -- Python (debugpy)
      dap.adapters.python = {
        type    = "executable",
        command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
        args    = { "-m", "debugpy.adapter" },
      }

      dap.configurations.python = {
        {
          name    = "Launch script",
          type    = "python",
          request = "launch",
          program = function()
            return vim.fn.input("Script: ", vim.fn.getcwd() .. "/", "file")
          end,
          args    = function()
            local input = vim.fn.input("Args (space-separated): ")
            return vim.split(input, " ", { trimempty = true })
          end,
          cwd          = "${workspaceFolder}",
          console      = "integratedTerminal",
          justMyCode   = false,
        },
        {
          name    = "Attach to process",
          type    = "python",
          request = "attach",
          processId = function()
            return tonumber(vim.fn.input("PID: "))
          end,
          justMyCode = false,
        },
      }

      -- Bash (bash-debug-adapter + bashdb)
      dap.adapters.bashdb = {
        type    = "executable",
        command = vim.fn.stdpath("data") .. "/mason/bin/bash-debug-adapter",
      }

      dap.configurations.sh = {
        {
          name       = "Launch Bash script",
          type       = "bashdb",
          request    = "launch",
          program    = function()
            return vim.fn.input("Script: ", vim.fn.getcwd() .. "/", "file")
          end,
          args       = function()
            local input = vim.fn.input("Args (space-separated): ")
            return vim.split(input, " ", { trimempty = true })
          end,
          cwd        = "${workspaceFolder}",
          pathBashdb = vim.fn.has("mac") == 1 and "/opt/homebrew/bin/bashdb" or "/usr/bin/bashdb",
          env        = {},
        },
      }
      dap.configurations.bash = dap.configurations.sh

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
