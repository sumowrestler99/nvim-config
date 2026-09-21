return {
  "mfussenegger/nvim-lint",
  ft = { "make" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      make = { "checkmake" },
    }

    -- `pattern` matches file names rather than filetypes, so the guard has to
    -- live in the callback. Without it this autocmd is global: once nvim-lint
    -- loads for a single Makefile it would call try_lint() on every read and
    -- every write of every buffer for the rest of the session.
    --
    -- The augroup makes re-sourcing the config replace the autocmd instead of
    -- stacking another copy.
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
      group = vim.api.nvim_create_augroup("UserNvimLint", { clear = true }),
      callback = function(args)
        if lint.linters_by_ft[vim.bo[args.buf].filetype] then
          lint.try_lint()
        end
      end,
    })
  end,
}
