# Design : Migration nvm/rbenv → mise

**Date** : 2026-04-17
**Statut** : done

## Contexte

nvm (Node) et rbenv (Ruby) sont installés via Homebrew et sourcés manuellement dans `home/shell.nix`.
Ils fonctionnent mais créent un trou dans la gestion déclarative Nix — une machine neuve nécessite une réinstallation manuelle.

Python et Terraform sont aussi gérés par Homebrew en dehors de Nix.

## Décision

Remplacer nvm, rbenv, et la gestion Homebrew de Python/Terraform par **mise** (ex-rtx), installé et configuré via le module home-manager `programs.mise`.

### Pourquoi mise

- Un seul outil remplace nvm + rbenv + pyenv + tfenv
- Package Nix propre (`pkgs.mise`), module home-manager avec activation zsh intégrée
- Lit nativement `.nvmrc`, `.ruby-version`, `.python-version`, `.tool-versions` — zéro changement dans les repos Pretto
- Config déclarative TOML, cohérent avec l'approche Nix du repo

### Approches écartées

- **nvm/rbenv via Nix** : nvm n'a pas de vrai package Nix (script shell), rbenv + ruby-build posent des soucis. Bricolage pour gain minime.
- **Pure Nix devShells par projet** : demande un `flake.nix` par repo Pretto, lourd pour les collègues qui n'utilisent pas Nix.

## Architecture

### Nouveau fichier : `home/mise.nix`

```nix
{ pkgs, ... }:

{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;

    globalConfig = {
      tools = {
        node = "25";
        ruby = "4";
        python = "3.14";
        terraform = "1";
      };
    };
  };
}
```

mise résout automatiquement vers la dernière patch de chaque version (25.x.x, 4.x.x, etc.).

### Modifications : `home/shell.nix`

1. **Supprimer** le bloc de sourcing nvm/rbenv dans `initContent` (lignes 52-58) :
   - `export NVM_DIR` + sourcing nvm.sh + completion
   - `eval "$(rbenv init ...)"`

2. **Retirer** `terraform` de `home.packages` (mise le gère).

### Modifications : `home/default.nix`

Ajouter `./mise.nix` aux imports.

## Comportement attendu

| Contexte | Résolution de version |
|---|---|
| Shell global (pas de fichier projet) | Versions déclarées dans `globalConfig.tools` |
| Projet avec `.nvmrc` / `.ruby-version` | mise override automatiquement avec la version du projet |
| Projet avec `.tool-versions` | idem, format natif mise |
| `darwin-rebuild switch` | mise installé, config globale écrite, activation zsh en place |

## Hors scope

- **Cleanup Homebrew** : suppression de nvm, rbenv, ruby-build, node, node@24, python@3.14 — fait manuellement après validation
- **Nettoyage `~/.nvm/` et `~/.rbenv/`** : idem, après validation
- **Migration des collègues Pretto** : pas concerné, mise est local à cette machine

## Validation

1. `darwin-rebuild switch` réussit
2. `mise doctor` ne remonte pas d'erreur
3. `node --version`, `ruby --version`, `python3 --version`, `terraform --version` retournent les bonnes versions
4. Dans un dossier avec `.nvmrc` ou `.ruby-version`, mise switch automatiquement
