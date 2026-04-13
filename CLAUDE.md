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
│   ├── default.nix        # home-manager: imports all modules + caps lock launchd agent
│   ├── shell.nix          # zsh + modern CLI tools (zoxide, fzf, bat, eza, rg, fd, direnv, starship)
│   ├── git.nix            # git config (1Password SSH signing, difftastic, delta, aliases)
│   ├── ghostty.nix        # terminal config (nord, ctrl+space=unbind for tmux)
│   ├── claude.nix         # Claude Code config symlinks
│   ├── tmux.nix           # tmux (prefix C-space, vim-tmux-navigator, catppuccin, resurrect)
│   └── neovim.nix         # neovim + LSP servers + LazyVim config symlink
├── files/
│   ├── claude/            # Claude Code settings.json, mcp.json
│   └── nvim/              # LazyVim config (init.lua, plugins, keymaps)
└── docs/
    ├── cheatsheet.md      # quick reference for all tools and shortcuts
    └── superpowers/       # design specs and implementation plans
```

## Key commands

```bash
# Rebuild system after changes (sudo required)
sudo darwin-rebuild switch --flake ~/src/config#macbook

# IMPORTANT: new .nix files must be `git add`ed before rebuild (flakes only see tracked files)

# Update flake inputs
nix flake update
```

## Critical quirks

- **Determinate Nix**: `nix.enable = false` in macbook.nix — Determinate manages the daemon, nix-darwin must not
- **system.primaryUser = "x"** required for homebrew module
- **Ghostty ctrl+space**: `keybind = ctrl+space=unbind` needed so tmux prefix works
- **Caps Lock → tmux prefix**: hidutil maps CapsLock to F13, Ghostty converts F13 to NUL byte (= Ctrl+Space), tmux sees its C-space prefix
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
- Phase 3: planned (Aerospace TWM, Obsidian config, server *arr + home automation)
- Design spec: `docs/superpowers/specs/2026-04-10-nix-dotfiles-design.md`
- Plans: `docs/superpowers/plans/`
