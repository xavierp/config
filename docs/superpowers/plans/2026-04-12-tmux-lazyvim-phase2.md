# Tmux + LazyVim Phase 2 Implementation Plan

> **Status: COMPLETE** — All tasks done. tmux with catppuccin + sesh, LazyVim with LSP via Nix, vim-tmux-navigator. Post-plan: pane borders, status bar top, catppuccin mocha neovim theme.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Set up tmux as primary window manager and LazyVim as IDE replacement, with seamless Ctrl+hjkl navigation between tmux panes and neovim splits.

**Architecture:** Tmux configured via home-manager `programs.tmux` with plugins from nixpkgs. LazyVim installed as regular Lua config files managed by home-manager `xdg.configFile` — Nix installs neovim and LSP servers, lazy.nvim manages neovim plugins at runtime. vim-tmux-navigator bridges both.

**Tech Stack:** tmux, neovim, LazyVim, lazy.nvim, vim-tmux-navigator, tree-sitter, LSP servers (ruby-lsp, typescript-language-server, terraform-ls, pyright, bash-language-server, marksman)

---

## File Structure

```
config/
├── home/
│   ├── tmux.nix              # tmux config via home-manager
│   ├── neovim.nix            # neovim + LSP servers via home-manager
│   └── default.nix           # add imports for tmux.nix, neovim.nix
├── files/
│   └── nvim/                 # LazyVim config (Lua files)
│       ├── init.lua          # bootstrap lazy.nvim + LazyVim
│       ├── lazyvim.json      # enabled extras
│       └── lua/
│           ├── config/
│           │   ├── keymaps.lua   # custom keybindings
│           │   ├── options.lua   # custom options
│           │   └── autocmds.lua  # custom autocommands
│           └── plugins/
│               ├── tmux-navigator.lua  # vim-tmux-navigator plugin
│               ├── theme.lua           # nord theme
│               └── overrides.lua       # any LazyVim overrides
└── docs/
    └── cheatsheet.md         # update with tmux/nvim shortcuts
```

---

### Task 1: Tmux configuration

**Files:**
- Create: `home/tmux.nix`
- Modify: `home/default.nix`

- [x] **Step 1: Create home/tmux.nix**

```nix
{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    prefix = "C-Space";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 50000;
    mouse = true;
    keyMode = "vi";
    terminal = "tmux-256color";
    sensibleOnTop = true;

    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      yank
      {
        plugin = catppuccin;
        extraConfig = ''
          # Use nord-inspired colors with catppuccin framework
          set -g @catppuccin_flavor "frappe"
          set -g @catppuccin_window_status_style "rounded"

          # Status bar modules
          set -g @catppuccin_status_modules_right "battery session date_time"
          set -g @catppuccin_date_time_text "%H:%M"
        '';
      }
      battery
      resurrect
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10'
        '';
      }
    ];

    extraConfig = ''
      # True color support
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -ag terminal-overrides ",ghostty:RGB"

      # Split panes with intuitive keys
      bind v split-window -h -c "#{pane_current_path}"
      bind s split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # New window keeps current path
      bind c new-window -c "#{pane_current_path}"

      # Resize panes with Ctrl+hjkl (hold prefix)
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Quick reload
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded"

      # Vi copy mode
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"

      # Don't rename windows automatically
      set -g allow-rename off

      # Activity monitoring
      setw -g monitor-activity on
      set -g visual-activity off
    '';
  };
}
```

- [x] **Step 2: Add tmux import to home/default.nix**

Add `./tmux.nix` to the imports list in `home/default.nix`:

```nix
  imports = [
    ./shell.nix
    ./git.nix
    ./ghostty.nix
    ./claude.nix
    ./tmux.nix
  ];
```

- [x] **Step 3: Stage, rebuild, and verify**

```bash
git add home/tmux.nix home/default.nix
sudo darwin-rebuild switch --flake '/Users/x/src/config#macbook'
```

Open a new terminal and run:

```bash
tmux new -s test
```

Expected:
- Status bar visible at bottom with session name, battery, time
- `Ctrl+Space` then `v` splits vertically
- `Ctrl+Space` then `s` splits horizontally
- `Ctrl+h/j/k/l` moves between panes
- `Ctrl+Space` then `[` enters copy mode (vi keys)
- Mouse scrolling works

Run: `tmux kill-session -t test`

- [x] **Step 4: Commit**

```bash
git add home/tmux.nix home/default.nix
git commit -m "feat: add tmux configuration with vim-tmux-navigator

Prefix Ctrl+Space, vi copy mode, catppuccin status bar with battery,
vim-tmux-navigator for Ctrl+hjkl pane navigation, resurrect/continuum
for session persistence."
```

---

### Task 2: Neovim + LSP servers via Nix

**Files:**
- Create: `home/neovim.nix`
- Modify: `home/default.nix`
- Modify: `home/shell.nix` (remove neovim from packages, it moves to neovim.nix)

- [x] **Step 1: Create home/neovim.nix**

```nix
{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # LSP servers and tools installed via Nix (not Mason)
  home.packages = with pkgs; [
    # LSP servers
    lua-language-server
    ruby-lsp
    typescript-language-server
    terraform-ls
    pyright
    bash-language-server
    marksman              # markdown LSP
    nodePackages.vscode-json-languageserver
    yaml-language-server

    # Formatters & linters
    stylua
    prettierd
    rubocop
    ruff                  # python linter/formatter
    shfmt                 # bash formatter
    shellcheck            # bash linter

    # Tools needed by neovim plugins
    gcc                   # treesitter compilation
    gnumake
    nodejs                # needed by some LSP servers
    unzip                 # needed by Mason fallback
    ripgrep               # telescope search
    fd                    # telescope file finder
  ];
}
```

- [x] **Step 2: Remove neovim from home/shell.nix packages**

In `home/shell.nix`, remove `neovim` from the `home.packages` list (it's now managed by `programs.neovim` in neovim.nix):

Remove this line from the `home.packages` block:
```
    neovim
```

- [x] **Step 3: Add neovim import to home/default.nix**

Add `./neovim.nix` to the imports list:

```nix
  imports = [
    ./shell.nix
    ./git.nix
    ./ghostty.nix
    ./claude.nix
    ./tmux.nix
    ./neovim.nix
  ];
```

- [x] **Step 4: Stage, rebuild, and verify**

```bash
git add home/neovim.nix home/neovim.nix home/default.nix home/shell.nix
sudo darwin-rebuild switch --flake '/Users/x/src/config#macbook'
```

Open a new terminal and verify LSP servers are available:

```bash
ruby-lsp --version
typescript-language-server --version
terraform-ls --version
pyright --version
bash-language-server --version
marksman --version
nvim --version
```

All should return version numbers without errors.

- [x] **Step 5: Commit**

```bash
git add home/neovim.nix home/default.nix home/shell.nix
git commit -m "feat: add neovim with LSP servers for ruby, typescript, terraform, python, bash, markdown"
```

---

### Task 3: LazyVim configuration files

**Files:**
- Create: `files/nvim/init.lua`
- Create: `files/nvim/lazyvim.json`
- Create: `files/nvim/lua/config/options.lua`
- Create: `files/nvim/lua/config/keymaps.lua`
- Create: `files/nvim/lua/config/autocmds.lua`
- Create: `files/nvim/lua/plugins/tmux-navigator.lua`
- Create: `files/nvim/lua/plugins/theme.lua`
- Create: `files/nvim/lua/plugins/overrides.lua`
- Modify: `home/neovim.nix` (add xdg.configFile symlinks)

- [x] **Step 1: Create files/nvim/init.lua**

```lua
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    return
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim with LazyVim
require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- Import LazyVim extras (configured in lazyvim.json)
    { import = "lazyvim.plugins.extras.lang.ruby" },
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.terraform" },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    { import = "lazyvim.plugins.extras.lang.docker" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    -- Import custom plugins
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  checker = {
    enabled = true,
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
```

- [x] **Step 2: Create files/nvim/lazyvim.json**

```json
{
  "extras": [
    "lazyvim.plugins.extras.lang.ruby",
    "lazyvim.plugins.extras.lang.typescript",
    "lazyvim.plugins.extras.lang.terraform",
    "lazyvim.plugins.extras.lang.python",
    "lazyvim.plugins.extras.lang.json",
    "lazyvim.plugins.extras.lang.yaml",
    "lazyvim.plugins.extras.lang.docker",
    "lazyvim.plugins.extras.lang.markdown"
  ],
  "news": {
    "NEWS.md": ""
  },
  "version": 7
}
```

- [x] **Step 3: Create files/nvim/lua/config/options.lua**

```lua
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Use system clipboard
vim.opt.clipboard = "unnamedplus"

-- Line numbers
vim.opt.relativenumber = true

-- Scroll offset
vim.opt.scrolloff = 8

-- Disable swap files (git handles recovery)
vim.opt.swapfile = false

-- Tell LSPs to use Nix-installed binaries (skip Mason)
vim.g.lazyvim_picker = "telescope"
```

- [x] **Step 4: Create files/nvim/lua/config/keymaps.lua**

```lua
-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- Nothing custom yet — LazyVim defaults + vim-tmux-navigator handle everything
-- Ctrl+h/j/k/l: navigate panes (handled by vim-tmux-navigator)
-- Space: leader key (LazyVim default)
```

- [x] **Step 5: Create files/nvim/lua/config/autocmds.lua**

```lua
-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Nothing custom yet
```

- [x] **Step 6: Create files/nvim/lua/plugins/tmux-navigator.lua**

```lua
return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Navigate left (tmux/nvim)" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Navigate down (tmux/nvim)" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Navigate up (tmux/nvim)" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right (tmux/nvim)" },
    },
  },
}
```

- [x] **Step 7: Create files/nvim/lua/plugins/theme.lua**

```lua
return {
  -- Use nord theme to match Ghostty
  {
    "shaunsingh/nord.nvim",
    lazy = false,
    priority = 1000,
  },
  -- Tell LazyVim to use nord
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nord",
    },
  },
}
```

- [x] **Step 8: Create files/nvim/lua/plugins/overrides.lua**

```lua
return {
  -- Disable Mason (we install LSP servers via Nix)
  { "williamboman/mason.nvim", enabled = false },
  { "williamboman/mason-lspconfig.nvim", enabled = false },
}
```

- [x] **Step 9: Add nvim config symlink to home/neovim.nix**

Replace the contents of `home/neovim.nix` with:

```nix
{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # LazyVim config files
  xdg.configFile."nvim" = {
    source = ../files/nvim;
    recursive = true;
  };

  # LSP servers and tools installed via Nix (not Mason)
  home.packages = with pkgs; [
    # LSP servers
    lua-language-server
    ruby-lsp
    typescript-language-server
    terraform-ls
    pyright
    bash-language-server
    marksman
    nodePackages.vscode-json-languageserver
    yaml-language-server

    # Formatters & linters
    stylua
    prettierd
    rubocop
    ruff
    shfmt
    shellcheck

    # Tools needed by neovim plugins
    gcc
    gnumake
    nodejs
    unzip
    ripgrep
    fd
  ];
}
```

- [x] **Step 10: Stage, rebuild, and verify**

```bash
git add files/nvim/ home/neovim.nix
sudo darwin-rebuild switch --flake '/Users/x/src/config#macbook'
```

Open a new terminal and run:

```bash
nvim
```

Expected: LazyVim boots, lazy.nvim downloads plugins (first time, needs internet). Wait for it to finish. You should see the LazyVim dashboard with the nord theme.

Test LSP:
1. Open a Ruby file: `nvim /tmp/test.rb` → type `def hello` → should get completion
2. Open a TS file: `nvim /tmp/test.ts` → type `const x: str` → should get completion
3. Press `Space` → which-key menu should appear showing available commands

Test vim-tmux-navigator inside tmux:
1. `tmux new -s test`
2. `nvim`
3. `Ctrl+Space, v` to split tmux pane
4. `Ctrl+h` and `Ctrl+l` should move between the nvim window and the tmux pane

- [x] **Step 11: Commit**

```bash
git add files/nvim/ home/neovim.nix
git commit -m "feat: add LazyVim configuration with LSP and vim-tmux-navigator

LazyVim with extras: ruby, typescript, terraform, python, json, yaml,
docker, markdown. Nord theme, Mason disabled (LSP via Nix), and
vim-tmux-navigator for seamless Ctrl+hjkl pane navigation."
```

---

### Task 4: Update cheatsheet

**Files:**
- Modify: `docs/cheatsheet.md`

- [x] **Step 1: Add tmux and neovim sections to docs/cheatsheet.md**

Append the following to the end of `docs/cheatsheet.md`:

```markdown

## Tmux

### Basics

| Raccourci | Action |
|---|---|
| `Ctrl+Space` | Prefix (avant toute commande tmux) |
| `Prefix, c` | Nouveau window |
| `Prefix, v` | Split vertical |
| `Prefix, s` | Split horizontal |
| `Prefix, x` | Fermer le pane courant |
| `Prefix, &` | Fermer le window courant |
| `Prefix, d` | Detacher la session |
| `Prefix, r` | Recharger la config tmux |

### Navigation

| Raccourci | Action |
|---|---|
| `Ctrl+h` | Pane gauche (aussi dans nvim) |
| `Ctrl+j` | Pane bas (aussi dans nvim) |
| `Ctrl+k` | Pane haut (aussi dans nvim) |
| `Ctrl+l` | Pane droite (aussi dans nvim) |
| `Prefix, 1-9` | Aller au window N |
| `Prefix, n` | Window suivant |
| `Prefix, p` | Window precedent |

### Resize

| Raccourci | Action |
|---|---|
| `Prefix, H` | Agrandir a gauche |
| `Prefix, J` | Agrandir en bas |
| `Prefix, K` | Agrandir en haut |
| `Prefix, L` | Agrandir a droite |

### Copy mode (vi)

| Raccourci | Action |
|---|---|
| `Prefix, [` | Entrer en copy mode |
| `v` | Commencer la selection |
| `y` | Copier (et quitter copy mode) |
| `q` | Quitter copy mode |

### Sessions

| Commande | Action |
|---|---|
| `tmux new -s nom` | Nouvelle session |
| `tmux ls` | Lister les sessions |
| `tmux a -t nom` | Rattacher a une session |
| `tmux kill-session -t nom` | Supprimer une session |

## Neovim (LazyVim)

### Navigation

| Raccourci | Action |
|---|---|
| `Space` | Leader key (ouvre which-key) |
| `Space f f` | Trouver un fichier (telescope) |
| `Space f g` | Chercher du texte (grep) |
| `Space e` | Explorateur de fichiers |
| `Space b b` | Switcher entre buffers |
| `Space ,` | Buffers recents |

### LSP

| Raccourci | Action |
|---|---|
| `gd` | Aller a la definition |
| `gr` | References |
| `K` | Documentation hover |
| `Space c a` | Code actions |
| `Space c r` | Renommer symbole |
| `Space c f` | Formatter le fichier |
| `]d` / `[d` | Diagnostic suivant / precedent |

### Editing

| Raccourci | Action |
|---|---|
| `gcc` | Toggle commentaire (ligne) |
| `gc` (visual) | Toggle commentaire (selection) |
| `Space u w` | Toggle word wrap |
| `Space u n` | Toggle numeros de ligne |

### Git

| Raccourci | Action |
|---|---|
| `Space g g` | Lazygit |
| `Space g b` | Git blame (ligne) |
| `]h` / `[h` | Hunk suivant / precedent |

### Windows/Splits

| Raccourci | Action |
|---|---|
| `Space w v` | Split vertical |
| `Space w s` | Split horizontal |
| `Space w d` | Fermer le split |
| `Ctrl+h/j/k/l` | Naviguer entre splits/panes tmux |
```

- [x] **Step 2: Commit**

```bash
git add docs/cheatsheet.md
git commit -m "docs: add tmux and neovim shortcuts to cheatsheet"
```

---

### Task 5: Final push

**Files:** None

- [x] **Step 1: Push all changes**

```bash
git push origin feat/nix-darwin-bootstrap
```

- [x] **Step 2: Verify in tmux + nvim together**

Open Ghostty, start tmux:

```bash
tmux new -s dev
```

Open neovim in the config repo:

```bash
nvim ~/src/config/flake.nix
```

Verify the full workflow:
1. Nord theme active in both tmux status bar and nvim
2. `Ctrl+Space, v` → new tmux pane next to nvim
3. `Ctrl+h` → move to nvim pane, `Ctrl+l` → move back
4. In nvim: `Space f f` → telescope file finder
5. In nvim: open a `.nix` file → syntax highlighting works
6. Detach: `Ctrl+Space, d` → reattach: `tmux a -t dev` → session preserved
