-- ~/.config/nvim/lua/core/keymaps.lua

-- Helper function to set keymaps with common options
local map = vim.keymap.set

-- Exit insert mode with jk
map("i", "jk", "<ESC>", { noremap = true, silent = true, desc = "Exit Insert Mode" })

-- Save file
map("n", "<leader>w", "<cmd>w<cr>", { noremap = true, desc = "Save Current Buffer" })

-- Diagnostic keymaps (global, always available)
map('n', '<space>e', vim.diagnostic.open_float,  { noremap = true, silent = true, desc = "Diagnostic float" })
map('n', '[d',       function() vim.diagnostic.jump({ count = -1 }) end, { noremap = true, silent = true, desc = "Prev diagnostic" })
map('n', ']d',       function() vim.diagnostic.jump({ count =  1 }) end, { noremap = true, silent = true, desc = "Next diagnostic" })
map('n', '<space>q', vim.diagnostic.setloclist,  { noremap = true, silent = true, desc = "Diagnostic loclist" })

-- Undotree (built-in nvim 0.12 pack)
map("n", "<leader>ut", function() require("undotree").open({ command = "rightbelow 30vnew" }) end, { noremap = true, silent = true, desc = "Toggle undotree" })

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
