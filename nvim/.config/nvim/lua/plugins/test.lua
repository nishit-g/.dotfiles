return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- Adapters
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-plenary",
      "nvim-neotest/neotest-jest",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
          }),
          require("neotest-plenary"),
          require("neotest-jest")({
            jestCommand = "npm test --",
            jestConfigFile = "custom.jest.config.ts",
            env = { CI = true },
            cwd = function(path)
              return vim.fn.getcwd()
            end,
          }),
        },
      })

      -- Keymaps
      vim.keymap.set("n", "<leader>tt", function() require("neotest").run.run() end, { desc = "Run nearest test" })
      vim.keymap.set("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "Run file" })
      vim.keymap.set("n", "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, { desc = "Debug nearest test" })
      vim.keymap.set("n", "<leader>ts", function() require("neotest").summary.toggle() end, { desc = "Toggle summary" })
      vim.keymap.set("n", "<leader>to", function() require("neotest").output.open({ enter = true }) end, { desc = "Show output" })
      vim.keymap.set("n", "<leader>tO", function() require("neotest").output_panel.toggle() end, { desc = "Toggle output panel" })
    end,
  },
}
