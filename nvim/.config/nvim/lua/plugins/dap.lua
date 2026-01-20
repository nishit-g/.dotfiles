return {
  {
    "mfussenegger/nvim-dap",
    cmd = { "DapContinue", "DapToggleBreakpoint" },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "Open REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle UI" },
    },
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "jay-babu/mason-nvim-dap.nvim",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("mason-nvim-dap").setup({
        automatic_installation = true,
        handlers = {},
        ensure_installed = { "python" },
      })

      require("nvim-dap-virtual-text").setup({})
      dapui.setup()

      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
    end,
  },
}
