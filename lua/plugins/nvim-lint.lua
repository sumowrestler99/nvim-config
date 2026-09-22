return {
  "mfussenegger/nvim-lint",
  ft = { "make" },
  config = function()
    local lint = require("lint")

    -- The bundled linter spec is `cmd = "checkmake"` (lint/linters/checkmake.lua),
    -- i.e. a bare $PATH lookup. Mason installs the binary but only prepends its
    -- bin/ to $PATH from mason.setup() (mason/init.lua:25), and mason.nvim is
    -- lazy-loaded on cmd/keys -- so on `nvim Makefile` the FileType event fires
    -- during startup, before mason has ever loaded, and the lookup fails.
    -- Pin the absolute path instead, and skip registering the linter entirely
    -- if it is not installed rather than erroring on every Makefile write.
    local mason_checkmake = vim.fn.stdpath("data") .. "/mason/bin/checkmake"
    local have_checkmake = vim.fn.executable(mason_checkmake) == 1
    if have_checkmake then
      lint.linters.checkmake.cmd = mason_checkmake
    else
      have_checkmake = vim.fn.executable("checkmake") == 1
    end

    lint.linters_by_ft = {}
    if have_checkmake then
      lint.linters_by_ft.make = { "checkmake" }
    end

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
