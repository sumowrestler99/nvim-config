-- Byte-compilation cache for Lua modules. Must run before anything is
-- require()d, including lazy.nvim's bootstrap, or those loads miss the cache.
vim.loader.enable()

-- Set leader keys before lazy.nvim so all plugin keymaps bind correctly
vim.g.mapleader      = "\\"  -- <leader>  = backslash (default)
vim.g.maplocalleader = "\\"  -- <localleader> = backslash

-- Treat .vscode/*.json files as jsonc (JSON with Comments) so LSPs/linters don't flag comments as errors
-- Treat .cint files as C
--
-- No `filename` table: vim.filetype falls back to matching the basename alone,
-- so `['launch.json'] = 'jsonc'` made every launch.json, tasks.json and
-- settings.json anywhere on disk jsonc. The pattern below already covers the
-- .vscode/ ones, which are the only ones that actually allow comments.
vim.filetype.add({
  extension = {
    cint = 'c',
  },
  pattern = {
    ['.*/%.vscode/.*%.json'] = 'jsonc',
  },
})

-- Bootstrap lazy.nvim: clone it on first start, then put it on 'runtimepath'.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
  -- Without this check a failed clone surfaces a few lines later as
  -- "module 'lazy' not found", which says nothing about the real cause.
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- --- Core Neovim Configuration Loading ---
-- Load your global Neovim options first
require("core.options")

-- Load global variables and Vimscript-related settings
require("core.globals")

-- Load your custom autocommands
require("core.autocmds")() -- Call the function returned by autocmds.lua

-- Load your custom keymaps
require("core.keymaps")

-- Public plugin specs, plus any machine-local ones from the gitignored
-- lua/local/plugins/ directory.
local spec = { { import = "plugins" } }
vim.list_extend(spec, require("core.local").plugin_specs())

require('lazy').setup({
    spec = spec,
    ui = { border = "rounded" },
    -- No background update checks; run :Lazy check by hand. The other fields
    -- only matter if this is turned back on.
    checker = { enabled = false, concurrency = 1, frequency = 86400 },
    performance = {
        rtp = {
            -- Bundled plugins this config never reaches for. Deliberately kept:
            -- matchit/matchparen (bracket matching), man (:Man and K on sh),
            -- editorconfig, osc52, shada, rplugin, spellfile.
            disabled_plugins = {
                "gzip",          -- browsing .gz archives in a buffer
                "tarPlugin",     -- browsing .tar archives in a buffer
                "zipPlugin",     -- browsing .zip archives in a buffer
                "tutor",         -- :Tutor
                -- netrwPlugin is deliberately NOT here. It provides scp://,
                -- sftp:// and http:// editing (README: "Remote file editing"),
                -- :Explore, and the directory browser for `nvim <dir>` and
                -- `:e <dir>` -- neo-tree only loads on :Neotree or its keys, so
                -- without netrw those open an empty buffer.
            },
        },
    },
    -- lazy can generate helptags from the headings in markdown readme files,
    -- so :help works even for plugins that don't have vim docs.
    -- when the readme opens with :help it will be correctly displayed as markdown
    readme = {
        enabled = true,
        root = vim.fn.stdpath("state") .. "/lazy/readme",
        files = { "README.md", "lua/**/README.md" },
        -- only generate markdown helptags for plugins that dont have docs
        skip_if_doc_exists = true,
    },
})

