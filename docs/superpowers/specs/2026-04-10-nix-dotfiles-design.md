# Nix Dotfiles — Phase 1 Design

## Objectif

Reprendre le controle des dotfiles et de la configuration machine via Nix (nix-darwin + home-manager) sur macOS. Phase 1 se concentre sur la fondation Nix et la migration d'un subset safe de CLI tools, sans toucher a neovim/tmux (phase 2).

## Principes

- **Declaratif** : un repo, un `darwin-rebuild switch --flake .`, tout est la
- **Prudent** : on migre d'abord les outils safe, on garde nvm/rbenv en place
- **Hybride** : Nix pour les CLI, Homebrew (pilote par nix-darwin) pour les GUI apps
- **Moderne** : remplacement des outils classiques par des alternatives modernes (zoxide, fzf, ripgrep, fd, bat, eza)

## Scope Phase 1

### Inclus
- Nix + nix-darwin + home-manager (flake)
- Zsh configure via home-manager (plugins, aliases, history, glob fixes)
- Modern CLI tooling (zoxide, fzf, ripgrep, fd, bat, eza, direnv, tldr)
- Caps Lock → Ctrl (remap systeme via nix-darwin)
- Git config declarative (signing 1Password, aliases, difftastic, delta)
- Ghostty config versionnee
- Claude Code configs versionnees et symlinkees
- Casks Homebrew declares dans nix-darwin
- Cheatsheet des outils et raccourcis

### Exclu (phase 2+)
- Neovim (LazyVim) + tmux setup complet
- vim-tmux-navigator (Ctrl+hjkl entre panes)
- Migration nvm → Nix nodejs
- Migration rbenv → Nix ruby
- Aerospace (TWM macOS)
- Obsidian config
- Serveur *arr + home automation

## Architecture

### Structure du repo

```
config/
├── flake.nix              # inputs (nixpkgs, nix-darwin, home-manager) + darwinConfigurations
├── flake.lock             # lockfile des versions
├── hosts/
│   └── macbook.nix        # nix-darwin: system settings, homebrew casks, caps lock remap
├── home/
│   ├── default.nix        # home-manager: importe tous les modules
│   ├── shell.nix          # zsh + modern CLI tools + aliases
│   ├── git.nix            # gitconfig declaratif
│   ├── ghostty.nix        # config Ghostty
│   └── claude.nix         # symlinks configs Claude Code
├── files/
│   └── claude/            # fichiers source Claude Code
│       ├── settings.json
│       ├── mcp.json
│       └── keybindings.json
├── docs/
│   └── cheatsheet.md      # cheatsheet des outils et raccourcis
└── CLAUDE.md
```

### Flake (flake.nix)

**Inputs :**
- `nixpkgs` (unstable — pour avoir les dernieres versions des CLI tools)
- `nix-darwin`
- `home-manager`

**Outputs :**
- Une seule `darwinConfigurations."macbook"` qui importe `hosts/macbook.nix`
- home-manager integre comme module nix-darwin (pas standalone)
- Rebuild : `darwin-rebuild switch --flake .`

### System (hosts/macbook.nix)

**Keyboard :**
- `system.keyboard.remapCapsLockToControl = true`

**Homebrew casks (declaratifs) :**
```
1password, alacritty, bruno, chromium, dash, datagrip, discord, docker,
docker-desktop, firefox, font-fira-code, gcloud-cli, ghostty, gimp,
google-chrome, jellyfin-media-player, macfuse, nordvpn, obsidian,
protonvpn, raycast, session-manager-plugin, sigmaos, slack, soulseek,
spotify, tor-browser, visual-studio-code, vlc, whatsapp
```
- `onActivation.cleanup = "zap"` — desinstalle ce qui n'est plus liste
- `onActivation.autoUpdate = true`

**Nix maintenance :**
- Garbage collection hebdomadaire automatique (`nix.gc.automatic = true`)

### Shell (home/shell.nix)

**Zsh config :**
- `programs.zsh.enable = true`
- `autosuggestion.enable = true` (zsh-autosuggestions)
- `syntaxHighlighting.enable = true` (zsh-syntax-highlighting)
- History : 1B lignes, ignore dups, ignore space, share entre sessions
- `setopt NO_NOMATCH` pour eviter les erreurs de glob sur `*`, `?`, `[`
- Completion activee (`compinit`)

**Starship prompt :**
- `programs.starship.enable = true`
- Config reprise de l'existant : directory, git branch/status, cmd duration, character (purple/red/green)

**Modern CLI tools (tous via Nix) :**

| Outil | Remplace | Integration shell |
|---|---|---|
| zoxide | `cd` (fuzzy) | `z foo` pour naviguer par frequence/recence |
| fzf | — | Ctrl+R (history), Ctrl+T (fichiers), Alt+C (cd) |
| bat | `cat` | Alias `cat=bat` |
| eza | `ls` | Alias `ls=eza -1 --icons`, `ll=eza -alh --icons --git` |
| ripgrep | `grep` | Alias `grep=rg` |
| fd | `find` | Recherche rapide, respecte .gitignore |
| direnv | — | Hook zsh, charge `.envrc` par dossier |
| tldr | `man` | Pages man simplifiees |

**Autres paquets Nix :**
- jq, yq, wget, tree, watch, gnused
- awscli2, terraform, terragrunt, tflint
- git, gh, difftastic, delta
- neovim (binaire seulement, config en phase 2)

**Aliases :**
```
dk    = docker
dkc   = docker compose
g     = git
tf    = terraform
cat   = bat
ls    = eza -1 --icons
ll    = eza -alh --icons --git
grep  = rg
find  = fd
```

**Ce qui reste hors Nix (phase 1) :**
- nvm (gere node, trop risque a migrer maintenant)
- rbenv (gere ruby, idem)
- Les deux restent dans le PATH via zprofile, on les migrera en phase 2

### Git (home/git.nix)

- `programs.git.enable = true`
- User : Xavier Pechot / xavp75@gmail.com
- Signing : SSH via 1Password (`op-ssh-sign`), cle ed25519
- Diff : difftastic comme outil externe
- Pager : delta pour les diffs dans le terminal
- Aliases : tous les alias actuels repris (lg, s, go, dm, ai, pub, co, br, fib, fit, fic, fim, etc.)
- `extensions.worktreeConfig = true`

### Ghostty (home/ghostty.nix)

Config versionnee via `xdg.configFile."ghostty/config"` :
- Theme : nord
- Font : JetBrains Mono Nerd Font, size 12
- Opacite 0.95, cursor block, copy-on-select
- Ligatures (calt, liga)
- Scrollback 10000, shell-integration detect

### Claude Code (home/claude.nix)

Fichiers sources dans `files/claude/`, symlinkes vers `~/.claude/` :
- `settings.json`
- `mcp.json`
- `keybindings.json`

Tout le reste de `~/.claude/` (cache, sessions, history, plugins) reste hors du repo.

### Cheatsheet (docs/cheatsheet.md)

Document de reference rapide :
- Navigation : `z` (zoxide), `Ctrl+T` (fzf fichiers), `Alt+C` (fzf cd)
- Recherche : `rg` (ripgrep), `fd`
- Visualisation : `bat`, `eza`, `tldr`
- Fzf : `Ctrl+R` (history), `**<tab>` (completion fuzzy)
- Git aliases essentiels
- Rebuild config : `darwin-rebuild switch --flake .`
- Sera complete en phase 2 avec tmux/nvim

## Strategie d'installation

1. Installer Nix (multi-user) via le Determinate Systems installer
2. Activer les flakes
3. Premier `darwin-rebuild switch --flake .` avec un subset minimal (juste zsh + quelques outils)
4. Valider que rien n'est casse
5. Ajouter progressivement les outils et configs
6. Desactiver/desinstaller les equivalents brew au fur et a mesure

## Decisions notables

- **nixpkgs unstable** plutot que stable : on veut les dernieres versions des CLI tools, pas de serveurs en prod a stabiliser
- **home-manager comme module nix-darwin** (pas standalone) : un seul rebuild, pas deux commandes
- **Pas de Karabiner** : le remap Caps Lock → Ctrl est natif via nix-darwin/hidutil
- **Delta ajoute** en complement de difftastic : delta pour le pager git (staged, log), difftastic pour `git diff` structurel
- **nvm/rbenv gardes en phase 1** : risque de casser les workflows de dev Pretto, migration en phase 2
- **`onActivation.cleanup = "zap"`** pour les casks : ce qui n'est pas declare est desinstalle — force a maintenir la liste a jour

## Phase 2 (preview)

- Tmux : prefix `Ctrl+Space`, panes vim-style (hjkl), status bar minimaliste
- LazyVim : LSP Ruby, TypeScript, Terraform. Plugins telescope, treesitter, git signs
- vim-tmux-navigator : `Ctrl+hjkl` seamless entre panes tmux et splits nvim
- Migration nvm → `programs.nodejs` via Nix
- Migration rbenv → Nix ruby
- Cheatsheet complete avec raccourcis tmux/nvim
