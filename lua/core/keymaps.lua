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

-- Toggle all layout guides (Indent lines, Folds, Smart/Color columns, Inlay hints, Git signs, and Diagnostic virtual text) simultaneously
map("n", "<leader>ul", function()
    -- 1. Toggle Snacks Indent Guides (if installed and loaded)
    if pcall(require, "snacks") then
        Snacks.toggle.indent():toggle()
    end

    -- 2. Toggle Git Signs in the left gutter (if installed and loaded)
    if pcall(require, "gitsigns") then
        require("gitsigns").toggle_signs()
    end

    -- 3. Toggle Fold Column (0 <-> auto)
    if vim.wo.foldcolumn == "0" then
        vim.wo.foldcolumn = "auto"
    else
        vim.wo.foldcolumn = "0"
    end

    -- 4. Toggle LSP Inlay Hints (Parameter annotations) safely, scoped to current buffer (bufnr = 0)
    if vim.lsp.inlay_hint then
        local is_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
        vim.lsp.inlay_hint.enable(not is_enabled, { bufnr = 0 })
    end

    -- 5. Toggle LSP Diagnostics inline Virtual Text (Red squiggles/error messages)
    local diag_config = vim.diagnostic.config() or {}
    if diag_config.virtual_text == false then
        vim.diagnostic.config({ virtual_text = true })
    else
        vim.diagnostic.config({ virtual_text = false })
    end

    -- 6. Toggle Color Column (Clear <-> 100/80 guideline)
    if vim.wo.colorcolumn == "" then
        -- Intelligently restore correct limit based on active filetype
        local ft = vim.bo.filetype
        if ft == "c" or ft == "cpp" or ft == "rust" then
            vim.wo.colorcolumn = "80"
        else
            vim.wo.colorcolumn = "100"
        end
        vim.notify("Layout Guides: ENABLED", vim.log.levels.INFO)
    else
        vim.wo.colorcolumn = ""
        vim.notify("Layout Guides: DISABLED (Clean Mode)", vim.log.levels.INFO)
    end
end, { noremap = true, silent = true, desc = "Toggle Layout Guides (Clean Mode)" })

