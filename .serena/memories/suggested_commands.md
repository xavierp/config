# Suggested Commands

## Build & Deploy
```bash
# Validate build (no sudo, always run after changes)
darwin-rebuild build --flake ~/src/config#macbook

# Apply changes (sudo required)
sudo darwin-rebuild switch --flake ~/src/config#macbook

# Update flake inputs
nix flake update
```

## Critical Notes
- New `.nix` files must be `git add`ed before rebuild (flakes only see tracked files)
- `nix.enable = false` in macbook.nix — Determinate Nix manages the daemon
- `system.primaryUser = "x"` required for homebrew module

## Git
- Conventional commits in English (feat, fix, chore)
- Branches: `feat/`, `fix/`, `chore/` + short description

## System Utilities (macOS/Darwin)
- `git`, `ls`, `find`, `grep` — standard (GNU coreutils not assumed)
- `brew search <name>` — verify cask names before adding to macbook.nix
- `defaults write/read` — macOS preference domains
