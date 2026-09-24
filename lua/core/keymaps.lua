-- ~/.config/nvim/lua/core/keymaps.lua

-- Helper function to set keymaps with common options
local map = vim.keymap.set

-- Exit insert mode with jk
map("i", "jk", "<ESC>", { noremap = true, silent = true, desc = "Exit Insert Mode" })

-- Save file
map("n", "<leader>w", "<cmd>w<cr>", { noremap = true, desc = "Save Current Buffer" })

-- Diagnostic keymaps (global, always available)
--
-- [d and ]d are deliberately absent: Neovim 0.12 already defines them
-- (runtime/lua/vim/_core/defaults.lua, :h ]d-default) and the built-ins pass
-- vim.v.count1, which the hand-rolled versions here did not -- 3]d jumped a
-- single diagnostic. Everything else about them was byte-for-byte identical,
-- so deleting them is a pure gain. ]D / [D / <C-W>d come free with the
-- built-ins too.
map('n', '<space>e', vim.diagnostic.open_float,  { noremap = true, silent = true, desc = "Diagnostic float" })
map('n', '<space>q', vim.diagnostic.setloclist,  { noremap = true, silent = true, desc = "Diagnostic loclist" })

-- Undotree, from the 'dist' pack that Neovim 0.12 ships opt-in.
--
-- `packadd` rather than appending the pack's lua/ directory to package.path:
-- the hand-rolled path only made `require('undotree')` resolve and never
-- sourced the pack's plugin/ file, so the :Undotree command it defines did
-- not exist. packadd puts the whole pack on 'runtimepath'.
--
-- Deferred to first keypress so nothing is sourced at startup, and the pack
-- guards itself with vim.g.loaded_undotree_plugin, so pressing it again is a
-- no-op.
map("n", "<leader>ut", function()
    vim.cmd.packadd("nvim.undotree")
    require("undotree").open({ command = "rightbelow 30vnew" })
end, { noremap = true, silent = true, desc = "Toggle undotree" })

-- Paste image from clipboard (img-clip)
map({ "n", "i" }, "<leader>pi", "<cmd>PasteImage<cr>", { noremap = true, silent = true, desc = "Paste image" })

-- Toggle tab width between 2 and 4
map("n", "<F4>", function()
    local width = vim.opt.tabstop:get() == 4 and 2 or 4
    vim.opt.tabstop = width
    vim.opt.shiftwidth = width
    vim.opt.softtabstop = width
    vim.notify("Tab width: " .. width, vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = "Toggle tab width 2/4" })

-- --- Other common keymaps you might want to add ---
-- map("n", "<leader>pv", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
-- map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })

-- Example: Close current buffer without closing window
-- map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete Buffer" })

--- Suspends or resumes smartcolumn's management of 'colorcolumn'.
---
--- smartcolumn owns the option: it rewrites it from BufEnter, CursorMoved and
--- WinScrolled whenever a buffer crosses the limit (smartcolumn.lua:79-91), so
--- writing 'colorcolumn' directly only lasts until the next crossing. Its
--- autocmds live in the "SmartColumn" augroup (smartcolumn.lua:103), and
--- setup() with no argument re-creates them while keeping the configured
--- options, which persist in the module (smartcolumn.lua:96-101).
---@param enabled boolean
local function set_smartcolumn(enabled)
    -- A plain require: lazy's require hook loads and configures the plugin if
    -- it has not been yet, and a genuine error is not swallowed.
    local smartcolumn = require("smartcolumn")
    if enabled then
        smartcolumn.setup()
        -- It only writes on a state *change*, cached per buffer; forget the
        -- cache so the next update re-applies the column.
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            vim.b[buf].prev_state = nil
        end
        vim.api.nvim_exec_autocmds("BufEnter", { group = "SmartColumn" })
    else
        vim.api.nvim_clear_autocmds({ group = "SmartColumn" })
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            vim.wo[win].colorcolumn = ""
        end
    end
end

-- Values to put back when clean mode ends, captured when it starts.
local before_clean = {}

-- Clean mode: hide every layout guide at once -- indent lines, git signs, the
-- fold column, inlay hints, diagnostic virtual text and the colour column --
-- and put them all back.
--
-- One flag drives every component. Each used to flip independently, so a
-- component that had changed on its own (smartcolumn clearing its column, or
-- a window opened since) came back inverted relative to the rest.
map("n", "<leader>ul", function()
    local clean = not vim.g.clean_mode
    vim.g.clean_mode = clean

    if clean then
        before_clean = {
            foldcolumn   = vim.wo.foldcolumn,
            virtual_text = vim.diagnostic.config().virtual_text,
        }
    end

    -- snacks is `lazy = false` (see snacks.lua), so Snacks always exists.
    if clean then Snacks.indent.disable() else Snacks.indent.enable() end
    require("gitsigns").toggle_signs(not clean)
    vim.wo.foldcolumn = clean and "0" or before_clean.foldcolumn
    vim.lsp.inlay_hint.enable(not clean, { bufnr = 0 })
    vim.diagnostic.config({ virtual_text = (not clean) and before_clean.virtual_text })
    set_smartcolumn(not clean)

    vim.notify(clean and "Layout Guides: DISABLED (Clean Mode)" or "Layout Guides: ENABLED",
        vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = "Toggle Layout Guides (Clean Mode)" })

