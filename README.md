# Neovim Configuration

A full-featured, opinionated Neovim 0.12+ configuration built for C/C++, Swift, Lua, Python, and Bash development. Designed for use both locally and over SSH, with a polished UI, AI-assisted editing, and fast startup through aggressive lazy loading.

---

## Major Capabilities

- **Full LSP support** — go-to-definition, rename, code actions, inlay hints, diagnostics in gutter and float, auto-installed servers via Mason
- **AI-assisted editing** — Avante.nvim powered by Gemini 2.5 Flash; ask questions, edit selections, and apply diffs without leaving the editor
- **Fuzzy finding** — Snacks picker for files, live grep, buffers, LSP symbols, git log, diagnostics, keymaps, jump list
- **Git integration** — gitsigns for per-hunk staging/reset/blame, diffview for side-by-side diffs and file history, 3-way merge tool, vim-fugitive for full git commands
- **Treesitter** — accurate syntax highlighting, incremental selection, rich text objects (functions, classes, parameters, loops, conditionals) with motions and swap
- **Code folding** — nvim-ufo with virtual text showing folded line count, custom status column
- **Persistent undo** — full undo history survives session restarts
- **OSC52 clipboard** — yank to local clipboard transparently over SSH, no clipboard tool required on the remote
- **Debugging** — nvim-dap with codelldb (LLDB), cpptools (gdbserver), and debugpy (Python); DAP UI auto-opens on session start
- **Snippet support** — LuaSnip with VSCode-compatible friendly-snippets
- **Image paste** — paste images from clipboard into buffers via img-clip (`<leader>pi`)
- **Annotation generation** — Neogen generates docstrings/doxygen comments (`<leader>nf`)
- **Todo tracking** — todo-comments.nvim highlights and navigates TODO/FIXME/NOTE/HACK/WARN across the codebase
- **Terminal** — toggleterm floating terminal (`<C-\>`)
- **Remote file editing** — netrw re-enabled for `scp://host/path` style remote files alongside neo-tree
- **Animated cursor** — smear-cursor.nvim animates cursor movement with a smear trail

---

## Assumptions

- You are running **macOS** (some paths and tools assume Homebrew, e.g. `/opt/homebrew/bin/nvim`)
- Your terminal uses a **Nerd Font** — all icons (gitsigns, lualine, cmp, noice, neo-tree) depend on it ([Iosevka Nerd Font](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Iosevka) recommended)
- **Swift/Objective-C** development uses Xcode's `sourcekit-lsp` via `xcrun`; Xcode must be installed
- `GEMINI_API_KEY` is set in your shell environment for Avante AI features
- Tab width is **4 spaces** by default; toggle to 2 with `<F4>`
- The **leader key** is `\` (backslash)
- All plugins load **lazily** — most have zero startup cost and only load on first use
- Plugin versions are **pinned** via `lazy-lock.json` for reproducible installs

---

## Installation

> **Warning:** This will replace your existing Neovim configuration. Back it up first if needed.

```bash
# Back up existing config (optional)
mv ~/.config/nvim ~/.config/nvim.bak

# Clone the repo
git clone https://github.com/sumowrestler99/nvim-config.git ~/.config/nvim

# Start Neovim — lazy.nvim will auto-install itself and all plugins
nvim
```

On first launch:
1. lazy.nvim bootstraps itself and downloads all plugins
2. Treesitter parsers are compiled (`TSUpdate` runs automatically)
3. Mason auto-installs LSP servers (`clangd`, `lua_ls`, `bashls`, `marksman`, `jsonls`, `yamlls`) and tools (`codelldb`, `cpptools`, `debugpy`, `checkmake`)
4. Restart nvim once everything finishes installing

**Set your Gemini API key** (required for Avante AI features):
```bash
# Add to your ~/.zshrc or ~/.bashrc
export GEMINI_API_KEY="your-key-here"
```
Get a free key at [aistudio.google.com](https://aistudio.google.com).

---

## Requirements

- Neovim 0.12+
- A [Nerd Font](https://www.nerdfonts.com/) (icons throughout UI) — [Iosevka Nerd Font](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Iosevka) recommended
- `git`, `curl`, `make`, `clang` or `gcc`
- `GEMINI_API_KEY` environment variable (for Avante AI assistant)

---

## Structure

```
~/.config/nvim/
├── init.lua                  # Entry point: loads core modules, lazy.nvim, built-in packs
├── lua/
│   ├── core/
│   │   ├── options.lua       # Editor options, LSP diagnostics config
│   │   ├── keymaps.lua       # Global keymaps
│   │   ├── autocmds.lua      # Autocommands (yank, cursor restore, resize)
│   │   └── globals.lua       # Global variables
│   └── plugins/              # One file per plugin, loaded via lazy.nvim
└── .gitignore
```

---

## Editor Options

| Option | Value | Effect |
|--------|-------|--------|
| `number` | true | Show line numbers |
| `tabstop` / `shiftwidth` / `softtabstop` | 4 | 4-space indentation |
| `expandtab` | true | Spaces instead of tabs |
| `ignorecase` + `smartcase` | true | Case-insensitive search unless uppercase used |
| `cursorline` | true | Highlight current line |
| `wrap` | false | No line wrapping |
| `termguicolors` | true | True color support |
| `scrolloff` / `sidescrolloff` | 8 | Keep 8 lines/cols of context around cursor |
| `undofile` | true | Persistent undo history across sessions |
| `swapfile` / `backup` | false | No swap or backup files |
| `foldlevel` / `foldlevelstart` | 99 | All folds open by default |
| `pumheight` | 10 | Max 10 items in completion popup |
| `updatetime` | 300ms | Faster CursorHold events |
| `timeoutlen` | 500ms | Key sequence timeout |
| `signcolumn` | yes | Always show sign column |
| `showmode` | false | Mode shown by lualine/noice instead |

---

## Autocommands

| Trigger | Effect |
|---------|--------|
| `BufReadPost` | Restore last cursor position in file |
| `TextYankPost` | Flash highlight on yank + copy to clipboard via OSC52 |
| `VimResized` | Auto-equalize split sizes on terminal resize |
| `VimEnter` (directory arg) | Auto-open neo-tree when nvim is opened on a directory |
| `ColorScheme` | Re-apply diagnostic underline highlights after theme changes |

### OSC52 Clipboard
Yanking (`y`) automatically copies to the local clipboard via OSC52. This works over SSH without any terminal round-trip. Paste (`p`) uses nvim's internal register.

---

## Keymaps

### Leader Key
`<leader>` = `\` (backslash, default)

### Global (always available)

| Mode | Key | Action |
|------|-----|--------|
| Insert | `jk` | Exit insert mode |
| Normal | `<leader>w` | Save file |
| Normal | `<F4>` | Toggle tab width between 2 and 4 |
| Normal | `<leader>pi` | Paste image from clipboard (img-clip) |
| Normal | `<leader>ut` | Toggle undotree (opens on right) |

### Diagnostics

| Mode | Key | Action |
|------|-----|--------|
| Normal | `<space>e` | Open diagnostic float |
| Normal | `<space>q` | Send diagnostics to location list |
| Normal | `[d` | Jump to previous diagnostic |
| Normal | `]d` | Jump to next diagnostic |

### LSP (active when LSP is attached)

| Mode | Key | Action |
|------|-----|--------|
| Normal | `gd` | Go to definition |
| Normal | `gD` | Go to declaration |
| Normal | `gi` | Go to implementation |
| Normal | `gr` | Show references |
| Normal | `K` | Hover documentation |
| Normal | `<C-k>` | Signature help |
| Normal | `<space>D` | Type definition |
| Normal | `<space>rn` | Rename symbol |
| Normal | `<space>ca` | Code action |
| Normal | `<space>f` | Format buffer |
| Normal | `<space>wa` | Add workspace folder |
| Normal | `<space>wr` | Remove workspace folder |
| Normal | `<space>wl` | List workspace folders |
| Visual | `\qf` | Format selected range |

### File Explorer (neo-tree)

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle file tree |
| `<leader>ef` | Reveal current file in tree |
| `<leader>eg` | Git status (floating window) |
| `<leader>eb` | Toggle buffer list |

Inside the tree: `l`/`h` open/close nodes, `v` open in vsplit, `s` open in split, `P` toggle float preview.

### Git (gitsigns — buffer-local)

| Mode | Key | Action |
|------|-----|--------|
| Normal | `]c` | Next hunk |
| Normal | `[c` | Previous hunk |
| Normal | `<leader>hs` | Stage hunk |
| Normal | `<leader>hS` | Stage entire buffer |
| Normal | `<leader>hu` | Undo stage hunk |
| Normal | `<leader>hU` | Unstage buffer |
| Normal | `<leader>hr` | Reset hunk |
| Normal | `<leader>hR` | Reset buffer |
| Normal | `<leader>hp` | Preview hunk |
| Normal | `<leader>hb` | Blame current line |
| Normal | `<leader>hd` | Diff against index |
| Normal | `<leader>hD` | Diff against last commit |
| Normal | `<leader>tb` | Toggle inline blame |
| Normal | `<leader>tw` | Toggle word diff |
| Visual | `<leader>hs` | Stage selected lines |
| Visual | `<leader>hr` | Reset selected lines |
| Op/Vis | `ih` | Select hunk as text object |

### Git (diffview)

| Key | Action |
|-----|--------|
| `<leader>gd` | Open diffview (staged/unstaged changes) |
| `<leader>gh` | File history (current file) |
| `<leader>gH` | File history (entire repo) |
| `<leader>gx` | Close diffview |

### Git (Snacks picker)

| Key | Action |
|-----|--------|
| `<leader>gc` | Git log (repo) |
| `<leader>gC` | Git log (current file) |
| `<leader>gs` | Git status |
| `<leader>gb` | Git branches |

### Find / Picker (Snacks)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fr` | Recent files |
| `<leader>fg` | Live grep |
| `<leader>fw` | Grep word under cursor |
| `<leader>fs` | LSP symbols |
| `<leader>fS` | LSP workspace symbols |
| `<leader>fb` | Buffers |
| `<leader>fj` | Jump list |
| `<leader>f:` | Command history |
| `<leader>fh` | Help tags |
| `<leader>fk` | Keymaps |
| `<leader>fd` | Diagnostics |
| `<leader>ft` | Todo comments |

### Todo Comments

| Key | Action |
|-----|--------|
| `]t` | Next TODO comment |
| `[t` | Previous TODO comment |

### Treesitter — Incremental Selection

| Key | Action |
|-----|--------|
| `gnn` | Start selection |
| `grn` | Expand to next node |
| `grc` | Expand to scope |
| `grm` | Shrink selection |

### Treesitter — Text Objects (Visual / Operator-pending)

| Key | Selects |
|-----|---------|
| `af` / `if` | Around / inside function |
| `ac` / `ic` | Around / inside class |
| `aa` / `ia` | Around / inside parameter |
| `ax` / `ix` | Around / inside conditional |
| `al` / `il` | Around / inside loop |

### Treesitter — Motion

| Key | Action |
|-----|--------|
| `]m` | Next function start |
| `]M` | Next function end |
| `[m` | Previous function start |
| `[M` | Previous function end |
| `]]` | Next class start |
| `[[` | Previous class start |

### Treesitter — Swap

| Key | Action |
|-----|--------|
| `<leader>a` | Swap with next parameter |
| `<leader>A` | Swap with previous parameter |

### Mason

| Key | Action |
|-----|--------|
| `<leader>mi` | Open Mason UI |
| `<leader>mu` | Update Mason registries |

### Debug (nvim-dap)

| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue |
| `<leader>dC` | Run to cursor |
| `<leader>dn` | Step over |
| `<leader>ds` | Step into |
| `<leader>df` | Step out |
| `<leader>dr` | Open REPL |
| `<leader>dl` | Run last config |
| `<leader>du` | Toggle DAP UI |
| `<leader>dx` | Terminate session |
| `<leader>dK` | Hover variable value |

Function keys are active **only during an active debug session** and are unset automatically when the session ends:

| Key | Action |
|-----|--------|
| `F5` | Continue |
| `F9` | Toggle breakpoint |
| `F10` | Step over |
| `F11` | Step into |
| `F12` | Step out |

Adapters installed via Mason: **codelldb** (C/C++ via LLDB), **cpptools** (C/C++ gdbserver attach, GDB 7+), **debugpy** (Python).

Per-project launch configs are read automatically from `.vscode/launch.json`.

### Documentation (Neogen)

| Key | Action |
|-----|--------|
| `<leader>nf` | Generate annotation/docstring |

### Terminal (toggleterm)

| Key | Action |
|-----|--------|
| `<C-\>` | Toggle floating terminal |

### Avante (AI Assistant)

| Key | Action |
|-----|--------|
| `<leader>aa` | Ask Avante |
| `<leader>ae` | Edit with Avante |
| `<leader>at` | Toggle Avante sidebar |
| `<leader>ar` | Refresh Avante |

---

## Plugins

### UI

| Plugin | Purpose |
|--------|---------|
| [catppuccin](https://github.com/catppuccin/nvim) | Colorscheme (mocha flavour). Manages highlight groups for most plugins. |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline with catppuccin palette, powerline separators, git branch, diagnostics, search count, file position |
| [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) | Buffer tabs with LSP diagnostic indicators and slant separators |
| [barbecue.nvim](https://github.com/utilyre/barbecue.nvim) | Winbar with LSP breadcrumb symbols (file → class → function) via nvim-navic |
| [noice.nvim](https://github.com/folke/noice.nvim) | Replaces cmdline, messages, and popupmenu with floating windows. Icons per command type. LSP progress spinner. |
| [nvim-notify](https://github.com/rcarriga/nvim-notify) | Animated notification popups with icons per level |
| [snacks.nvim](https://github.com/folke/snacks.nvim) | Indent guides with animation, smooth scrolling, fuzzy picker |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Popup showing available keymaps after partial input |
| [dressing.nvim](https://github.com/stevearc/dressing.nvim) | Replaces `vim.ui.input` and `vim.ui.select` with bordered floating windows |
| [smear-cursor.nvim](https://github.com/sphamba/smear-cursor.nvim) | Animates cursor movement with a smear trail |

### File Management

| Plugin | Purpose |
|--------|---------|
| [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) | File explorer with git status, LSP diagnostics, buffer list, floating git status panel, indent markers |
| [img-clip.nvim](https://github.com/HakonHarnes/img-clip.nvim) | Paste images from clipboard into buffer (`<leader>pi`) |

### LSP & Completion

| Plugin | Purpose |
|--------|---------|
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP client configuration. Uses new `vim.lsp.config`/`vim.lsp.enable` API on 0.11+, legacy `require('lspconfig')` on 0.10. Inlay hints enabled where supported. |
| [mason.nvim](https://github.com/mason-org/mason.nvim) | LSP/linter/formatter installer |
| [mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim) | Bridges mason with lspconfig. Auto-installs: `clangd`, `lua_ls`, `bashls`, `marksman`, `jsonls`, `yamlls` |
| [schemastore.nvim](https://github.com/b0o/schemastore.nvim) | Provides SchemaStore catalog to jsonls and yamlls for automatic schema detection |
| [nvim-lint](https://github.com/mfussenegger/nvim-lint) | Lightweight linter runner. Runs `checkmake` on Makefile buffers on read/write. |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Completion engine with LSP kind icons, bordered windows, 300ms debounce delay |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Snippet engine with friendly-snippets |
| [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) | LSP completion source |

#### LSP Servers (auto-installed via Mason)
- `clangd` — C/C++ (with background indexing, bundled completions, PCH in memory)
- `lua_ls` — Lua
- `bashls` — Bash/sh
- `marksman` — Markdown
- `jsonls` — JSON (schema validation via SchemaStore; auto-detects schema from filename)
- `yamlls` — YAML (schema validation via SchemaStore; auto-detects GitHub Actions, docker-compose, etc.)

#### LSP Servers (manually configured)
- `sourcekit` — Swift / Objective-C (via Xcode toolchain, `xcrun sourcekit-lsp`)

### Treesitter

| Plugin | Purpose |
|--------|---------|
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting, incremental selection. Auto-installs parsers. Disabled for files >100KB. |
| [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) | Function/class/parameter/loop/conditional text objects and motions |
| [tree-sitter-tcl](https://github.com/lewis6991/tree-sitter-tcl) | TCL language parser |

### Git

| Plugin | Purpose |
|--------|---------|
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git signs in gutter (add/change/delete), inline blame, hunk staging/reset, word diff |
| [diffview.nvim](https://github.com/sindrets/diffview.nvim) | Side-by-side diff view, file history browser, 3-way merge tool |
| [vim-fugitive](https://github.com/tpope/vim-fugitive) | Git commands via `:G` |

### Folding

| Plugin | Purpose |
|--------|---------|
| [nvim-ufo](https://github.com/kevinhwang91/nvim-ufo) | Enhanced folding with virtual text showing number of folded lines |
| [statuscol.nvim](https://github.com/luukvbaal/statuscol.nvim) | Custom status column: fold indicator, signs, line numbers |

### Editing

| Plugin | Purpose |
|--------|---------|
| [nerdcommenter](https://github.com/preservim/nerdcommenter) | Comment/uncomment code |
| [neogen](https://github.com/danymat/neogen) | Generate docstring annotations (`<leader>nf`) |
| [doxygentoolkit](https://github.com/vim-scripts/DoxygenToolkit.vim) | Doxygen comment generation |
| [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | Highlight and navigate TODO/FIXME/HACK/NOTE/WARN/PERF/TEST comments |

### Terminal & Debug

| Plugin | Purpose |
|--------|---------|
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | Floating terminal (`<C-\>`) |
| [nvim-dap](https://github.com/mfussenegger/nvim-dap) | Debug Adapter Protocol core |
| [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) | DAP UI panels (scopes, breakpoints, stacks, console) |
| [nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text) | Inline variable values during debug sessions |

### Markdown / Docs

| Plugin | Purpose |
|--------|---------|
| [glow.nvim](https://github.com/ellisonleao/glow.nvim) | Render markdown in a floating window via `glow` CLI |
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Inline markdown rendering in Avante buffers |

### AI

| Plugin | Purpose |
|--------|---------|
| [avante.nvim](https://github.com/yetone/avante.nvim) | AI coding assistant powered by Gemini 2.5 Flash. Sidebar mode, agentic editing, diff apply. |

### Built-in Packs (nvim 0.12, loaded via `package.path`)

| Pack | Purpose |
|------|---------|
| `nvim.undotree` | Visual undo history tree (`<leader>ut`, opens on right) |

---

## Colorscheme

**Catppuccin Mocha** is the active flavour. To switch:

```vim
:colorscheme catppuccin-latte
:colorscheme catppuccin-frappe
:colorscheme catppuccin-macchiato
:colorscheme catppuccin-mocha
```

Or permanently in `catpuccin.lua`:
```lua
flavour = "macchiato"
```

---

## AI Assistant (Avante)

Provider: **Gemini 2.5 Flash** via `GEMINI_API_KEY` environment variable.

- Sidebar opens on the right (35% width)
- Agentic mode: can read/edit files autonomously
- Diff apply is manual (not auto-applied)
- Visual selection hints suppressed (`selection.hint_display = "none"`)
- Submit prompt: `<CR>` in input box

---

## Completion

- Triggers after **300ms** debounce (reduces popup noise while typing fast)
- LSP kind icons shown for each completion item (Function, Class, Variable, etc.)
- Source labels: `[LSP]`, `[Snip]`, `[Buf]`, `[Path]`
- Bordered completion and documentation windows

### Completion Keymaps

| Key | Action |
|-----|--------|
| `<CR>` | Confirm selection |
| `<C-y>` | Confirm (force select) |
| `<C-e>` | Abort/close |
| `<Up>` / `<C-p>` | Previous item |
| `<Down>` / `<C-n>` | Next item |
| `<C-u>` | Scroll docs up |
| `<C-d>` | Scroll docs down |
| `<Tab>` | Next item / expand snippet / trigger completion |
| `<S-Tab>` | Previous item / jump back in snippet |

---

## Noice Cmdline Icons

> Icons require a Nerd Font in your terminal to render correctly.

| Mode | Nerd Font Codepoint | Trigger |
|------|---------------------|---------|
| Command | `nf-md-apple_keyboard_command` (U+F0E33) | `:` |
| Search down | `nf-fa-search` (U+F002) | `/` |
| Search up | `nf-fa-search` (U+F002) | `?` |
| Shell | `nf-fa-dollar` (U+F155) | `:!` |
| Lua | `nf-seti-lua` (U+E620) | `:lua` |
| Help | `nf-md-help_circle` (U+F059) | `:help` |
| Calculator | `nf-fa-calculator` (U+F1EC) | `=` |
| Input | `nf-md-form_textbox` (U+F193) | `input()` prompts |

---

## Todo Comment Keywords

| Keyword | Aliases | Color |
|---------|---------|-------|
| `FIX:` | FIXME, BUG, FIXIT, ISSUE | Red |
| `TODO:` | — | Blue |
| `HACK:` | — | Yellow |
| `WARN:` | WARNING, XXX | Yellow |
| `PERF:` | OPTIM, PERFORMANCE, OPTIMIZE | Purple |
| `NOTE:` | INFO | Green |
| `TEST:` | TESTING, PASSED, FAILED | Pink |

---

## Plugin Manager

[lazy.nvim](https://github.com/folke/lazy.nvim) — open with `:Lazy`

- Plugins load lazily by default (on command, keymap, filetype, or event)
- Plugin lock file: `lazy-lock.json` (committed — pins exact versions)
- Auto-install on startup if missing

## LSP Installer

[Mason](https://github.com/mason-org/mason.nvim) — open with `:Mason` or `<leader>mi`
