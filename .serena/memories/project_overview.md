# Project Overview

Dotfiles and machine configuration managed via Nix (nix-darwin + home-manager) on macOS.
Single flake, one command to rebuild everything: `sudo darwin-rebuild switch --flake ~/src/config#macbook`

## Tech Stack
- **Nix** (nix-darwin + home-manager) for declarative system/user config
- **Homebrew** for GUI casks
- **Karabiner-Elements** for keyboard remapping
- **Ghostty** / Kitty as terminal emulators
- **tmux** with vim-tmux-navigator
- **Neovim** with LazyVim (LSP servers via Nix, not Mason)
- **Aerospace** tiling WM (config ready, activation paused)
- **mise** for runtime version management (replaced nvm/rbenv)

## Structure
- `flake.nix` — inputs + darwinConfigurations
- `hosts/macbook.nix` — nix-darwin system settings, casks, keyboard remap
- `home/*.nix` — home-manager modules split by concern (shell, git, ghostty, tmux, neovim, etc.)
- `files/` — config files for aerospace, claude, karabiner, nvim
- `docs/` — cheatsheet and design specs/plans

## Owner
Xavier Pechot — Head of Technology at Pretto, macOS (MacBook Pro M-series)
