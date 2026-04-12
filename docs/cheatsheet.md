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

## Keyboard

| Touche | Action |
|---|---|
| `Caps Lock` | Agit comme `Ctrl` (remap systeme) |
| `Ctrl+Space` | Prefix tmux |
| `Ctrl+h/j/k/l` | Navigation entre panes tmux ET splits nvim |

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
