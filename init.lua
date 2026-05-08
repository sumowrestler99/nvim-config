-- Set leader keys before lazy.nvim so all plugin keymaps bind correctly
vim.g.mapleader      = "\\"  -- <leader>  = backslash (default)
vim.g.maplocalleader = "\\"  -- <localleader> = backslash

-- Treat .vscode/*.json files as jsonc (JSON with Comments) so LSPs/linters don't flag comments as errors
vim.filetype.add({
  filename = {
    ['launch.json'] = 'jsonc',
    ['tasks.json'] = 'jsonc',
    ['settings.json'] = 'jsonc',
  },
  pattern = {
    ['.*/%.vscode/.*%.json'] = 'jsonc',
  },
})

-- Compatibility hook for Neovim v0.11+ / v0.12+ treesitter get_node_text breaking change
-- In newer Neovim versions, a matched query capture can return a list of nodes (TSNode[])
-- instead of a single TSNode. Old plugins (like nvim-treesitter master branch) still
-- expect a single TSNode. This shim automatically unpacks lists to prevent crashes.
local original_get_node_text = vim.treesitter.get_node_text
vim.treesitter.get_node_text = function(node, source, opts)
  if type(node) == "table" and node[1] and not node.range then
    node = node[1]
  end
  return original_get_node_text(node, source, opts)
end
-- This file can be loaded by calling `lua require('plugins')` from your init.vim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
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

-- Built-in nvim 0.12 undotree: inject lua path before lazy's loader intercepts
package.path = package.path .. ";" .. vim.env.VIMRUNTIME .. "/pack/dist/opt/nvim.undotree/lua/?.lua"

require('lazy').setup({
    spec = {
        { import = "plugins" },
    },
    ui = { border = "rounded" },
    checker = { enabled = false, concurrency = 1, frequency = 86400 }, --automatically check for plugin updates
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

