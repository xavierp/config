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
| `Ctrl+Space` | Prefix tmux (phase 2) |
