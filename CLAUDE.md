# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is this repo

Dotfiles and machine configuration managed via Nix (nix-darwin + home-manager) on macOS.
Single flake, one `sudo darwin-rebuild switch --flake ~/src/config#macbook` to rebuild everything.

## Architecture

```
config/
├── flake.nix              # inputs (nixpkgs, nix-darwin, home-manager) + darwinConfigurations."macbook"
├── hosts/
│   └── macbook.nix        # nix-darwin: system settings, casks, keyboard remap, primaryUser
├── home/
│   ├── default.nix        # home-manager: imports all modules
│   ├── shell.nix          # zsh + modern CLI tools (zoxide, fzf, bat, eza, rg, fd, direnv, starship)
│   ├── git.nix            # git config (1Password SSH signing, difftastic, delta, aliases)
│   ├── ghostty.nix        # terminal config (nord, super+ keybinds for tmux)
│   ├── kitty.nix          # kitty terminal (alternative, same keybinds)
│   ├── claude.nix         # Claude Code config symlinks
│   ├── karabiner.nix      # Karabiner-Elements config (activation script, writable copy)
│   ├── aerospace.nix      # Aerospace TWM config symlink
│   ├── tmux.nix           # tmux (prefix C-space, vim-tmux-navigator, catppuccin, resurrect)
│   └── neovim.nix         # neovim + LSP servers + LazyVim config symlink
├── files/
│   ├── aerospace/         # Aerospace TWM config (ctrl+alt bindings)
│   ├── claude/            # Claude Code settings.json, mcp.json
│   ├── karabiner/         # Karabiner-Elements config (Hyper key + left Alt remap)
│   └── nvim/              # LazyVim config (init.lua, plugins, keymaps)
└── docs/
    ├── cheatsheet.md      # quick reference for all tools and shortcuts
    └── superpowers/       # design specs and implementation plans
```

## Key commands

```bash
# Validate build after every modification (no sudo, always run this)
darwin-rebuild build --flake ~/src/config#macbook

# Rebuild system after changes (sudo required)
sudo darwin-rebuild switch --flake ~/src/config#macbook

# IMPORTANT: new .nix files must be `git add`ed before rebuild (flakes only see tracked files)

# Update flake inputs
nix flake update
```

## Critical quirks

- **Determinate Nix**: `nix.enable = false` in macbook.nix — Determinate manages the daemon, nix-darwin must not
- **system.primaryUser = "x"** required for homebrew module
- **CapsLock → Hyper**: Karabiner-Elements sends Cmd+Ctrl+Opt+Shift on CapsLock. No bindings yet — reserved for future use.
- **Left Alt → Ctrl+Alt**: Karabiner adds Ctrl to left_option presses so Aerospace can distinguish left/right Alt. Right Alt unchanged (special chars).
- **Ghostty super+ keybinds**: Cmd+hjkl sends Ctrl+hjkl (vim-tmux-navigator), Cmd+t/w/s/f/n/1-9/[/] sends tmux prefix + action. Must use `super+` prefix (not `cmd+`) and `super+digit_N` for numbers to override Ghostty defaults.
- **Ghostty macOS tab menu**: `home.activation.ghosttyDefaults` runs `defaults write` to disable macOS "Show Previous/Next Tab" menu shortcuts.
- **Karabiner config**: must be a regular file (not symlink) — home.activation copies it.
- **Aerospace TWM**: tiling WM, binds `ctrl+alt-*` (physical left Alt + key). Config at `files/aerospace/aerospace.toml`. Cask currently commented out — needs macOS Spaces settings tuned first.
- **home-manager.backupFileExtension = "bak"**: old dotfiles get .bak suffix instead of blocking
- **Mason disabled**: LSP servers installed via Nix in neovim.nix, not via Mason
- **nvm/rbenv**: still managed outside Nix (sourced in shell.nix initContent)
- **homebrew.onActivation.cleanup = "none"**: set to "zap" once cask list is verified

## Conventions

- Nix files split by concern, not monolithic
- New CLI tool: add to relevant `.nix` file in home/
- New GUI app: add to casks list in `hosts/macbook.nix`
- New nvim plugin: add lua file in `files/nvim/lua/plugins/`
- Commit messages: English, conventional commits (feat, fix, chore)

## Status

- Phase 1: done (Nix + shell + CLI tools + git + ghostty + claude configs)
- Phase 2: done (tmux + LazyVim + LSP servers + vim-tmux-navigator)
- Phase 3: in progress (Hyper key done, Ghostty keybinds done, Aerospace config ready but paused, Obsidian + server *arr planned)
- Design spec: `docs/superpowers/specs/2026-04-10-nix-dotfiles-design.md`
- Plans: `docs/superpowers/plans/`
