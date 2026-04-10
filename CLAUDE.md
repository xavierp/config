# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is this repo

Dotfiles and machine configuration managed via Nix (nix-darwin + home-manager) on macOS.
Single flake, one `darwin-rebuild switch --flake .` to rebuild everything.

## Architecture

```
config/
├── flake.nix          # inputs (nixpkgs, nix-darwin, home-manager) + darwinConfigurations
├── hosts/
│   └── macbook.nix    # nix-darwin: system settings, casks, keyboard remap
├── home/
│   ├── default.nix    # home-manager: imports all modules
│   ├── shell.nix      # zsh + modern CLI tools + aliases
│   ├── git.nix        # git config (1Password signing, difftastic, delta)
│   ├── ghostty.nix    # terminal config
│   └── claude.nix     # Claude Code config symlinks
├── files/claude/      # source files for Claude Code configs
└── docs/
    └── cheatsheet.md  # quick reference for tools and shortcuts
```

## Key commands

```bash
# Rebuild system after changes
darwin-rebuild switch --flake .

# Update flake inputs (nixpkgs, home-manager, nix-darwin)
nix flake update

# Check flake validity
nix flake check
```

## Design decisions

- **Nix flake** (not classic nix-darwin config) for reproducibility and lockfile
- **nixpkgs unstable** for latest CLI tool versions
- **home-manager as nix-darwin module** (not standalone) — single rebuild command
- **Hybrid approach**: Nix for CLI tools, Homebrew casks (piloted by nix-darwin) for GUI apps
- **No Karabiner**: Caps Lock → Ctrl remapped natively via nix-darwin/hidutil
- **nvm/rbenv kept outside Nix** for now to avoid breaking dev workflows

## Conventions

- Nix files split by concern (shell.nix, git.nix, etc.), not one monolithic config
- When adding a new tool: add to the relevant `.nix` file, not to brew
- When adding a GUI app: add to the casks list in `hosts/macbook.nix`
- Commit messages in English, conventional commits (feat, fix, chore)

## Current status

- Phase 1: Nix foundation + shell + modern CLI tools + config versioning (in progress)
- Phase 2: tmux + LazyVim + full dev environment (planned)
- Design spec: `docs/superpowers/specs/2026-04-10-nix-dotfiles-design.md`
