-- Basic UI and editing options
vim.opt.number = true             -- Show line numbers
vim.opt.tabstop = 4               -- Number of spaces a tab counts for
vim.opt.shiftwidth = 4            -- Number of spaces to use for each step of (auto)indent
vim.opt.softtabstop = 4           -- When editing, use spaces for tab but make backspace behave like tab
vim.opt.expandtab = true          -- Use spaces instead of tabs
vim.opt.ignorecase = true         -- Ignore case in search patterns (`ic`)
vim.opt.smartcase = true          -- Smart case search (if search contains uppercase, don't ignore case)
vim.opt.cursorline = true         -- Highlight the current line
vim.opt.wrap = false              -- Don't wrap lines (turn off word wrap)
vim.opt.termguicolors = true      -- Enable true color support in terminal (needed for many colorschemes)
vim.opt.mousemoveevent = true     -- Enable mouse movement events (for some plugins/UI)

-- Clipboard: OSC52 copy is handled in autocmds.lua (TextYankPost/YankHighlight).
-- paste (p/P) uses nvim's unnamed register — no terminal round-trip needed.

-- Indentation and formatting
vim.opt.autoindent = true         -- Copy indent from current line when starting a new line
vim.opt.smartindent = true        -- Smarter autoindenting for C-like languages
vim.opt.breakindent = true        -- Keep indent when wrapping lines

-- Search settings
vim.opt.hlsearch = true           -- Highlight all matches of the last search pattern
vim.opt.incsearch = true          -- Show partial matches while typing search pattern

-- Backup and swap files
vim.opt.backup = false            -- Do not create backup files
vim.opt.writebackup = false       -- Do not create a backup file when writing
vim.opt.swapfile = false          -- Do not create swap files

-- UI enhancements
vim.opt.cmdheight = 1             -- Command-line height
vim.opt.updatetime = 300          -- Faster completion (time in ms to wait for more typing)
vim.opt.timeoutlen = 500          -- Time in ms to wait for a mapped sequence to complete
vim.opt.showmode = false          -- Don't show -- INSERT -- etc. (Lualine/Noice handle this)
vim.opt.signcolumn = "yes"        -- Always show the sign column

-- Folding (if not fully managed by UFO)
vim.opt.foldcolumn = '1'          -- Show a fold column
vim.opt.foldlevel = 99            -- Don't fold by default (adjust as desired)
vim.opt.foldlevelstart = 99       -- Don't fold on file open
vim.opt.foldenable = true         -- Enable folding
vim.opt.fillchars = { eob = ' ', fold = ' ', foldopen = '▾', foldclose = '▸', foldsep = '│' }

-- Scroll context
vim.opt.scrolloff = 8             -- Keep 8 lines above/below cursor
vim.opt.sidescrolloff = 8         -- Keep 8 cols left/right of cursor

-- Undo persistence
vim.opt.undofile = true           -- Persist undo history across sessions

-- Better completion menu
vim.opt.pumheight = 10            -- Limit completion popup to 10 items

-- LSP
vim.lsp.log.set_level("OFF")
vim.diagnostic.config({
    float        = { border = "rounded", source = "if_many" },
    virtual_text = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN]  = '',
            [vim.diagnostic.severity.HINT]  = '',
            [vim.diagnostic.severity.INFO]  = '',
        },
    },
})

-- Treesitter specific options (often set by treesitter plugin itself)
-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "v:lua.require'ufo'.getFoldedResults()"
