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
- **Debugging** — nvim-dap with codelldb (LLDB), cpptools (gdbserver), debugpy (Python) and bash-debug-adapter (Bash via bashdb); DAP UI auto-opens on session start
- **Snippet support** — LuaSnip with VSCode-compatible friendly-snippets
- **Image paste** — paste images from clipboard into buffers via img-clip (`<leader>pi`). Local sessions only: img-clip reads the clipboard of the machine nvim runs on (pngpaste, wl-paste or xclip), so it does not work over SSH
- **Annotation generation** — Neogen generates docstrings/doxygen comments (`<leader>nf`)
- **Todo tracking** — todo-comments.nvim highlights and navigates TODO/FIXME/NOTE/HACK/WARN across the codebase
- **Terminal** — toggleterm floating terminal (`<C-\>`)
- **Remote file editing** — netrw is left enabled for `scp://host/path` style remote files alongside neo-tree
- **Animated cursor** — smear-cursor.nvim animates cursor movement with a smear trail
- **Clean mode** — single keymap (`<leader>ul`) toggles all layout guides off/on (indent lines, git signs, fold column, inlay hints, diagnostic virtual text, color column)
- **jsonc support** — `.vscode/*.json` files (launch.json, tasks.json) treated as JSON with Comments; LSP loads correctly for them

---

## Assumptions

- Primarily designed for **macOS** but also works on **Linux** (used over SSH); Homebrew paths are macOS-specific, Mason binaries install platform-correctly on both
- Your terminal uses a **Nerd Font** — all icons (gitsigns, lualine, cmp, noice, neo-tree) depend on it ([Iosevka Nerd Font](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Iosevka) recommended)
- **Swift/Objective-C** LSP (`sourcekit`) is macOS-only and is skipped automatically on Linux
- `bashdb` must be installed separately for Bash debugging (`brew install bashdb` on macOS, `apt/dnf/pacman install bashdb` on Linux)
- `GEMINI_API_KEY` is set in your shell environment for Avante AI features
- Tab width is **4 spaces** by default; toggle to 2 with `<F4>`
- The **leader key** is `\` (backslash)
- Only catppuccin, snacks.nvim and barbecue.nvim (with its nvim-navic and nvim-web-devicons dependencies) load during startup. bufferline, lualine, noice, nvim-notify, smear-cursor and which-key load on `VeryLazy`, just after the first screen is drawn. Everything else loads on first use (command, key, filetype or buffer event)
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
2. Treesitter parsers are built the first time a supported file is opened (the `:TSUpdate` build hook
   only updates parsers that are already installed). This needs the `tree-sitter` CLI (0.26.1 or later)
   and a C compiler on `$PATH`
3. Mason auto-installs LSP servers (`clangd`, `lua_ls`, `bashls`, `pyright`, `marksman`, `jsonls`, `yamlls`) the first time a
   supported file is opened, and debug adapters (`codelldb`, `cpptools`, `debugpy`, `bash-debug-adapter`) the first
   time a debug key or `:Dap*` command is used. `checkmake` is not auto-installed (`:MasonInstall checkmake`)
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
- `tree-sitter` CLI 0.26.1+ (builds Treesitter parsers)
- `rg` (ripgrep) — Snacks grep pickers and todo search
- Node.js + npm, python3 (with `venv`) and `unzip` — used by Mason to install pyright, bashls, jsonls,
  yamlls, debugpy and the adapter archives
- `GEMINI_API_KEY` environment variable (for Avante AI assistant)

Optional:
- `gdb` — cpptools debugging (`miDebuggerPath = "gdb"`)
- `bashdb` — Bash debugging
- `glow` — `:Glow` markdown preview. Without it `:Glow` is not defined (glow.nvim would otherwise download an unverified release binary)
- `claude` CLI — claude-code.nvim
- `cargo` — only if avante's prebuilt native libraries have to be rebuilt

---

## Structure

```
~/.config/nvim/
├── init.lua                  # Entry point: loads core modules and lazy.nvim
├── lua/
│   ├── core/
│   │   ├── options.lua       # Editor options, diagnostic display config
│   │   ├── keymaps.lua       # Global keymaps
│   │   ├── autocmds.lua      # Autocommands (yank/OSC52, cursor restore, resize, no-undo for secrets, neo-tree on dir, diagnostic highlights)
│   │   ├── globals.lua       # Global variables
│   │   └── local.lua         # Optional loader for gitignored machine-local overrides
│   └── plugins/              # One file per plugin (or plugin group), loaded via lazy.nvim
├── lazy-lock.json            # Pinned plugin commits
├── .luarc.json               # lua_ls settings for editing this config
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
| color column | 100 (80 for C/C++/Rust) | Vertical line at the length limit, shown only while a visible line exceeds it (smartcolumn.nvim) |

---

## Autocommands

| Trigger | Effect |
|---------|--------|
| `BufReadPost` | Restore last cursor position in file (not for git commit/rebase message buffers) |
| `BufWritePre` (`/tmp/*`, `*.gpg`, `*.env`, `*/.ssh/*`, …) | Disable persistent undo for scratch/secret files |
| `TextYankPost` | Flash highlight on yank + copy `y` yanks to clipboard via OSC52 |
| `VimResized` | Auto-equalize split sizes on terminal resize |
| `VimEnter` (directory arg) | Auto-open neo-tree when nvim is opened on a directory |
| `ColorScheme` | Re-apply diagnostic underline highlights after theme changes |
| `FileType` (`fugitiveblame`) | Blank winbar so the blame window lines up with the barbecue winbar |

### OSC52 Clipboard
Yanking (`y`) into the unnamed, `+` or `*` register automatically copies to the local clipboard via OSC52; deletes, changes and yanks replayed by a macro do not. This works over SSH without any terminal round-trip. Paste (`p`) uses nvim's internal register.

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
| Normal | `<leader>ul` | Toggle all layout guides (clean mode) |
| Normal/Visual | `<leader>c<Space>` | Toggle comment (built-in `gcc`/`gc`) |

### Diagnostics

| Mode | Key | Action |
|------|-----|--------|
| Normal | `<space>e` | Open diagnostic float |
| Normal | `<space>q` | Send diagnostics to location list |
| Normal | `[d` | Jump to previous diagnostic (Neovim built-in) |
| Normal | `]d` | Jump to next diagnostic (Neovim built-in) |

### LSP (active when LSP is attached)

| Mode | Key | Action |
|------|-----|--------|
| Normal | `gd` | Go to definition |
| Normal | `gD` | Go to declaration |
| Normal | `gi` | Go to implementation |
| Normal | `grr` | Show references (built-in) |
| Normal | `grn` | Rename symbol (built-in) |
| Normal/Visual | `gra` | Code action (built-in) |
| Normal | `gri` | Go to implementation (built-in) |
| Normal | `grt` | Type definition (built-in) |
| Normal | `grx` | Run codelens (built-in) |
| Normal | `gO` | Document symbols (built-in) |
| Normal | `K` | Hover documentation |
| Normal | `<C-k>` | Signature help |
| Normal | `<space>D` | Type definition |
| Normal | `<space>rn` | Rename symbol |
| Normal | `<space>ca` | Code action |
| Normal | `<space>f` | Format buffer |
| Normal | `<space>wa` | Add workspace folder |
| Normal | `<space>wr` | Remove workspace folder |
| Normal | `<space>wl` | List workspace folders |
| Visual | `\qf` | Format selected lines |

### File Explorer (neo-tree)

| Key | Action |
|-----|--------|
| `<leader>ee` | Toggle file tree |
| `<leader>ef` | Reveal current file in tree |
| `<leader>eg` | Git status (floating window) |
| `<leader>eb` | Toggle buffer list |

Inside the tree: `l`/`h` open/close nodes, `v` open in vsplit, `s` open in split, `P` toggle float preview.

### Git (gitsigns — buffer-local)

| Mode | Key | Action |
|------|-----|--------|
| Normal | `]c` | Next hunk |
| Normal | `[c` | Previous hunk |
| Normal | `<leader>hs` | Stage hunk (unstages if already staged) |
| Normal | `<leader>hS` | Stage entire buffer |
| Normal | `<leader>hu` | Toggle stage (alias of `<leader>hs`; stages an unstaged hunk) |
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

In the 3-way merge view:

| Mode | Key | Action |
|------|-----|--------|
| Normal/Visual | `g<` | Take diff from left (ours) |
| Normal/Visual | `g>` | Take diff from right (theirs) |

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
| `<leader>fw` | Grep word under cursor (Normal) / selection (Visual) |
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
| `gnn` | Start selection (Normal) |
| `grn` | Expand to next node (Visual; Normal `grn` is LSP rename) |
| `grc` | Expand to scope (Visual) |
| `grm` | Shrink selection (Visual) |

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
| `<leader>sa` | Swap with next parameter |
| `<leader>sA` | Swap with previous parameter |

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

Adapters installed via Mason: **codelldb** (C/C++ via LLDB), **cpptools** (C/C++ gdbserver attach, GDB 7+), **debugpy** (Python), **bash-debug-adapter** (Bash via bashdb; requires `brew install bashdb` on macOS or `apt/dnf/pacman install bashdb` on Linux).

Per-project launch configs are read automatically from `.vscode/launch.json` and take **priority over global configs**. `.vscode/*.json` files are treated as jsonc (JSON with Comments) so inline comments don't cause errors.

### Documentation (Neogen)

| Key | Action |
|-----|--------|
| `<leader>nf` | Generate annotation/docstring |

### Terminal (toggleterm)

| Key | Action |
|-----|--------|
| `<C-\>` | Toggle floating terminal (Normal, Insert and inside the terminal) |
| `<C-\><C-n>` | Inside the terminal: Terminal-Normal mode (scroll back, yank). `<C-\>` alone toggles after `timeoutlen` |

### Avante (AI Assistant)

| Mode | Key | Action |
|------|-----|--------|
| Normal/Visual | `<leader>aa` | Ask Avante |
| Normal/Visual | `<leader>an` | New ask |
| Normal/Visual | `<leader>az` | Zen mode |
| Visual | `<leader>ae` | Edit selection |
| Normal | `<leader>at` | Toggle sidebar |
| Normal | `<leader>ar` | Refresh |
| Normal | `<leader>af` | Focus sidebar |
| Normal | `<leader>aS` | Stop request |
| Normal | `<leader>ad` | Toggle debug |
| Normal | `<leader>aC` | Toggle selection |
| Normal | `<leader>as` | Toggle suggestion |
| Normal | `<leader>aR` | Show repo map |
| Normal | `<leader>a?` | Select model |
| Normal | `<leader>ah` | Select history |
| Normal | `<leader>aM` | Select ACP model |
| Normal | `<leader>am` | Select ACP mode |
| Normal | `<leader>aB` | Add all buffers |

### Claude Code

| Key | Action |
|-----|--------|
| `<C-,>` | Toggle Claude Code terminal |
| `<leader>cC` | Continue last conversation |
| `<leader>cV` | Verbose mode |

---

## Plugins

### UI

| Plugin | Purpose |
|--------|---------|
| [catppuccin](https://github.com/catppuccin/nvim) | Colorscheme (mocha flavour). Manages highlight groups for most plugins. |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline with catppuccin palette, powerline separators, git branch, diff, diagnostics, filename, filetype, file position |
| [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) | Buffer tabs with LSP diagnostic indicators and slant separators |
| [barbecue.nvim](https://github.com/utilyre/barbecue.nvim) | Winbar with LSP breadcrumb symbols (file → class → function) via nvim-navic |
| [noice.nvim](https://github.com/folke/noice.nvim) | Replaces cmdline, messages, and popupmenu with floating windows. Icons per command type. LSP progress spinner. |
| [nvim-notify](https://github.com/rcarriga/nvim-notify) | Animated notification popups with icons per level |
| [snacks.nvim](https://github.com/folke/snacks.nvim) | Indent guides with animation, smooth scrolling, fuzzy picker, `vim.ui.input`/`vim.ui.select`, bigfile and quickfile, buffer delete |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Popup showing available keymaps after partial input |
| [smear-cursor.nvim](https://github.com/sphamba/smear-cursor.nvim) | Animates cursor movement with a smear trail |
| [smartcolumn.nvim](https://github.com/m4xshen/smartcolumn.nvim) | Colour column at 100 (80 for C/C++/Rust), shown only when a line exceeds it |

### File Management

| Plugin | Purpose |
|--------|---------|
| [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) | File explorer with git status, LSP diagnostics, buffer list, floating git status panel, indent markers |
| [img-clip.nvim](https://github.com/HakonHarnes/img-clip.nvim) | Paste images from clipboard into buffer (`<leader>pi`) |

### LSP & Completion

| Plugin | Purpose |
|--------|---------|
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP client configuration. Uses the `vim.lsp.config`/`vim.lsp.enable` API. Inlay hints enabled where supported. |
| [mason.nvim](https://github.com/mason-org/mason.nvim) | LSP/linter/formatter installer |
| [mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim) | Bridges mason with lspconfig. Auto-installs: `clangd`, `lua_ls`, `bashls`, `pyright`, `marksman`, `jsonls`, `yamlls` |
| [schemastore.nvim](https://github.com/b0o/schemastore.nvim) | Provides SchemaStore catalog to jsonls and yamlls for automatic schema detection |
| [nvim-lint](https://github.com/mfussenegger/nvim-lint) | Lightweight linter runner. Runs `checkmake` (if installed) on Makefile buffers on read/write. |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Completion engine with LSP kind icons, bordered windows, 300ms debounce delay |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Snippet engine with friendly-snippets |
| [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) | LSP completion source |
| [cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip) | LuaSnip completion source |
| [nvim-navic](https://github.com/SmiteshP/nvim-navic) | LSP symbol context for the barbecue winbar |

#### LSP Servers (auto-installed via Mason)
- `clangd` — C/C++ (with background indexing, bundled completions, PCH in memory)
- `lua_ls` — Lua
- `bashls` — Bash/sh
- `pyright` — Python (type checking, go-to-definition, inlay hints)
- `marksman` — Markdown
- `jsonls` — JSON (schema validation via SchemaStore; auto-detects schema from filename)
- `yamlls` — YAML (schema validation via SchemaStore; auto-detects GitHub Actions, docker-compose, etc.)

#### LSP Servers (manually configured)
- `sourcekit` — Swift / Objective-C (via Xcode toolchain, `xcrun sourcekit-lsp`)

### Treesitter

| Plugin | Purpose |
|--------|---------|
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | `main` branch; parsers built with the `tree-sitter` CLI. Starts Neovim's built-in highlighting; incremental selection reimplemented in the config. Auto-installs parsers. The `cpp` parser is built from the public [smartpde/tree-sitter-cpp-google](https://github.com/smartpde/tree-sitter-cpp-google) fork. Highlighting skipped for files >500KB. |
| [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) | Function/class/parameter/loop/conditional text objects and motions |

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
| [statuscol.nvim](https://github.com/luukvbaal/statuscol.nvim) | Custom status column: fold indicator, signs, line numbers. Line-number clicks disabled; left-click on a git sign previews the hunk |

### Editing

| Plugin | Purpose |
|--------|---------|
| [neogen](https://github.com/danymat/neogen) | Generate docstring annotations (`<leader>nf`) |
| [doxygentoolkit](https://github.com/vim-scripts/DoxygenToolkit.vim) | Doxygen comment generation |
| [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | Highlight and navigate TODO/FIXME/HACK/NOTE/WARN/PERF/TEST comments |

### Terminal & Debug

| Plugin | Purpose |
|--------|---------|
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | Floating terminal (`<C-\>`) |
| [nvim-dap](https://github.com/mfussenegger/nvim-dap) | Debug Adapter Protocol core |
| [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) | DAP UI panels (scopes, breakpoints, stacks, watches, REPL, console) |
| [nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text) | Inline variable values during debug sessions |
| [mason-nvim-dap.nvim](https://github.com/jay-babu/mason-nvim-dap.nvim) | Installs the debug adapters via Mason |

### Markdown / Docs

| Plugin | Purpose |
|--------|---------|
| [glow.nvim](https://github.com/ellisonleao/glow.nvim) | Render markdown in a floating window via `glow` CLI |
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Inline markdown rendering in markdown and Avante buffers |

### AI

| Plugin | Purpose |
|--------|---------|
| [avante.nvim](https://github.com/yetone/avante.nvim) | AI coding assistant powered by Gemini 2.5 Flash. Sidebar mode, agentic editing (asks before shell commands and file edits; read-only tools run without a prompt), diff apply. |
| [claude-code.nvim](https://github.com/greggh/claude-code.nvim) | Claude Code CLI in a terminal window (`<C-,>`) |

### Built-in Packs (nvim 0.12, loaded with `:packadd` on first use)

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
- Agentic mode: can read and edit files. Shell commands and file writes need confirmation; read-only tools (view, ls, grep, glob) do not. *Allow Always* applies for the rest of the session
- Diff apply is manual (not auto-applied)
- Visual selection hints suppressed (`selection.hint_display = "none"`)
- Submit prompt: `<CR>` in Normal mode or `<C-s>` in Insert mode (in the input box)

---

## Completion

- Triggers after **300ms** debounce (reduces popup noise while typing fast)
- LSP kind icons shown for each completion item (Function, Class, Variable, etc.)
- Sources: LSP (`[LSP]`, from the 1st character) and LuaSnip (`[Snip]`, from the 2nd)
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
| `<Tab>` | Next item / expand or jump forward in snippet / trigger completion after a word character |
| `<S-Tab>` | Previous item / jump back in snippet |

---

## Noice Cmdline Icons

> Icons require a Nerd Font in your terminal to render correctly.

| Mode | Nerd Font Codepoint | Trigger |
|------|---------------------|---------|
| Command | `nf-md-apple_keyboard_command` (U+F0633) | `:` |
| Search down | `nf-fa-search` (U+F002) | `/` |
| Search up | `nf-fa-star` (U+F005) | `?` |
| Shell | `nf-fa-terminal` (U+F120) | `:!` |
| Lua | `nf-seti-lua` (U+E620) | `:lua` |
| Help | `nf-md-help` (U+F02D6) | `:help` |
| Calculator | `nf-fa-calculator` (U+F1EC) | `=` |
| Input | `nf-md-keyboard_outline` (U+F097B) | `input()` prompts |

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

- Each plugin spec declares its own trigger (command, keymap, filetype or event); three plugins are eager (see Assumptions)
- Plugin lock file: `lazy-lock.json` (committed — pins exact versions)
- Auto-install on startup if missing

## LSP Installer

[Mason](https://github.com/mason-org/mason.nvim) — open with `:Mason` or `<leader>mi`
