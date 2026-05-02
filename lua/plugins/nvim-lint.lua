return {
  "mfussenegger/nvim-lint",
  ft = { "make" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      make = { "checkmake" },
    }

    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
