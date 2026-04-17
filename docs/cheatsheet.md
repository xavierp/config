# Cheatsheet — Modern CLI & Nix

## Rebuild config

```bash
darwin-rebuild switch --flake ~/src/config#macbook   # appliquer les changements (sudo requis)
nix flake update                                      # mettre a jour nixpkgs, home-manager, nix-darwin
```

## Navigation (zoxide)

| Commande | Action |
|---|---|
| `z foo` | Sauter dans le dossier le plus frequent contenant "foo" |
| `z foo bar` | Affiner avec plusieurs mots |
| `zi foo` | Mode interactif (fzf) |

## Fuzzy finder (fzf)

| Raccourci | Action |
|---|---|
| `Ctrl+R` | Recherche fuzzy dans l'historique |
| `Ctrl+T` | Picker de fichiers (insere le chemin) |
| `Alt+C` | cd fuzzy dans un sous-dossier |
| `**<Tab>` | Completion fuzzy (ex: `vim **<Tab>`) |

## Recherche

| Commande | Action |
|---|---|
| `rg "pattern"` | Chercher dans les fichiers (ripgrep) |
| `rg "pattern" -t ruby` | Chercher seulement dans les fichiers Ruby |
| `rg "pattern" -l` | Lister seulement les fichiers qui matchent |
| `fd "pattern"` | Trouver des fichiers par nom |
| `fd -e rb` | Trouver les fichiers .rb |
| `fd "pattern" --type d` | Trouver des dossiers |

## Visualisation

| Commande | Action |
|---|---|
| `bat fichier.rb` | cat avec syntax highlighting |
| `bat -l json` | Forcer le langage |
| `eza -alh --git` | ls detaille avec statut git |
| `eza --tree --level=2` | Arborescence |
| `tldr tar` | Pages man simplifiees |

## Direnv

| Commande | Action |
|---|---|
| `echo "use nix" > .envrc` | Creer un env Nix par projet |
| `direnv allow` | Autoriser le .envrc du dossier courant |
| `direnv deny` | Revoquer l'autorisation |

## Git aliases

| Alias | Commande |
|---|---|
| `g s` | `git status -s` |
| `g lg` | Log graph colore |
| `g ai` | `git add -p` (interactive) |
| `g ci` | `git commit` |
| `g ca` | Add all + commit |
| `g pub` | Push + set upstream |
| `g co <branch>` | Checkout |
| `g go <branch>` | Checkout ou cree la branche |
| `g d` | Diff |
| `g dm` | Supprimer les branches mergees |
| `g amend` | Amend sans changer le message |
| `g wip` | Commit WIP rapide |

## Keyboard layers

| Touche physique | Role | Gere par |
|---|---|---|
| `CapsLock` | Hyper (Cmd+Ctrl+Opt+Shift) — reserve, pas de bindings | Karabiner |
| `Left Alt + key` | Aerospace TWM (workspaces, tiling) | Aerospace |
| `Right Alt + key` | Caracteres speciaux macOS (€, accents) | macOS |
| `Cmd + key` | tmux operations + navigation panes (Ghostty only) | Ghostty |
| `Ctrl + h/j/k/l` | vim-tmux-navigator (envoye par Ghostty via Cmd+hjkl) | tmux + nvim |
| `Space` | Leader neovim | LazyVim |

## Tmux via Cmd (Ghostty)

### Navigation

| Raccourci | Action |
|---|---|
| `Cmd+H` | Pane gauche (aussi dans nvim) |
| `Cmd+J` | Pane bas (aussi dans nvim) |
| `Cmd+K` | Pane haut (aussi dans nvim) |
| `Cmd+L` | Pane droite (aussi dans nvim) |
| `Cmd+1-9` | Aller au window N |
| `Cmd+[` | Window precedent |
| `Cmd+]` | Window suivant |

### Operations

| Raccourci | Action |
|---|---|
| `Cmd+T` | Nouveau window |
| `Cmd+W` | Fermer le pane courant |
| `Cmd+S` | Split vertical |
| `Cmd+Shift+S` | Split horizontal |
| `Cmd+F` | Session switcher (tmux-sessionizer) |
| `Cmd+N` | Nouvelle session |

### Tmux prefix (fallback / SSH)

| Raccourci | Action |
|---|---|
| `Ctrl+Space` | Prefix tmux (pour SSH ou fallback) |
| `Prefix, v` | Split vertical |
| `Prefix, s` | Split horizontal |
| `Prefix, x` | Fermer le pane courant |
| `Prefix, n` | Nouveau window |
| `Prefix, N` | Window suivant |
| `Prefix, p` | Window precedent |
| `Prefix, d` | Detacher la session |
| `Prefix, r` | Recharger la config tmux |
| `Prefix, f` | Session switcher |

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

## Aerospace TWM (Left Alt — paused, a configurer)

| Raccourci | Action |
|---|---|
| `Left Alt + H/J/K/L` | Focus window |
| `Left Alt + Shift + H/J/K/L` | Move window |
| `Left Alt + 1-9` | Switch workspace |
| `Left Alt + Shift + 1-9` | Move window to workspace |
| `Left Alt + F` | Fullscreen toggle |
| `Left Alt + Shift + F` | Float toggle |
| `Left Alt + /` | Layout toggle (tiles) |
| `Left Alt + -/=` | Resize |
| `Left Alt + Tab` | Previous workspace |
| `Left Alt + Enter` | Ouvrir Ghostty |

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
