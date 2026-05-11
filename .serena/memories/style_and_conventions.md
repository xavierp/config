# Style & Conventions

## Nix Code
- Files split by concern, not monolithic
- New CLI tool → add to relevant `.nix` in `home/`
- New GUI app → add to casks list in `hosts/macbook.nix`
- New nvim plugin → add lua file in `files/nvim/lua/plugins/`
- `home-manager.backupFileExtension = "bak"` — old dotfiles get .bak suffix

## Naming
- English in code
- French comments only for complex business context (not applicable here)

## Commit Messages
- Conventional commits (feat, fix, chore, refactor, docs)
- English
- No trailing summaries after task completion
