-- Optional machine-local configuration.
--
-- Anything under `lua/local/` is gitignored, which makes it the place for
-- config that must not be published: work-specific language servers,
-- completion sources, AI providers, private paths, and so on.
--
-- A module is entirely optional. On a machine where `lua/local/cmp.lua` does
-- not exist, `require('core.local').get('cmp')` simply returns an empty table
-- and every caller degrades to its public defaults.
--
-- Usage from a plugin spec:
--
--     local extra = require('core.local').get('cmp')
--     vim.list_extend(sources, extra.sources or {})

local M = {}

---@type table<string, table|false>
local cache = {}

--- Loads `lua/local/<name>.lua` if it exists.
---
--- Existence is checked against the runtimepath before requiring, so a genuine
--- error inside the module (syntax error, bad require) propagates normally
--- instead of being swallowed the way `pcall(require, ...)` would swallow it.
---
---@param name string Module name below `local.`, e.g. `"cmp"`.
---@return table|nil # The module's return value, or nil if it does not exist.
function M.load(name)
  local cached = cache[name]
  if cached ~= nil then
    return cached or nil
  end

  local modname = 'local.' .. name
  local path = 'lua/' .. modname:gsub('%.', '/') .. '.lua'
  if #vim.api.nvim_get_runtime_file(path, false) == 0 then
    cache[name] = false
    return nil
  end

  local mod = require(modname)
  if type(mod) ~= 'table' then
    vim.notify(
      ('core.local: %s must return a table, got %s'):format(path, type(mod)),
      vim.log.levels.ERROR
    )
    cache[name] = false
    return nil
  end

  cache[name] = mod
  return mod
end

--- Same as `load`, but never returns nil.
---
--- Lets callers write `require('core.local').get('cmp').sources or {}` without
--- a nil guard.
---
---@param name string Module name below `local.`, e.g. `"cmp"`.
---@return table
function M.get(name)
  return M.load(name) or {}
end

--- lazy.nvim import entries for machine-local plugin specs.
---
--- `lua/local/plugins/` is gitignored, so plugins that must not be published
--- live there instead of in `lua/plugins/`. lazy.nvim errors on an import of a
--- directory that does not exist, hence the probe.
---
---@return table[] # Splice into `lazy.setup{ spec = ... }`; empty when absent.
function M.plugin_specs()
  local dir = vim.fn.stdpath('config') .. '/lua/local/plugins'
  if vim.uv.fs_stat(dir) then
    return { { import = 'local.plugins' } }
  end
  return {}
end

return M
