# Fix — race condition boot Determinate Nix (daemon avant mount /nix)

> Handoff de session Claude Code — 2026-06-01. Reprendre avec `claude --resume` (ou `claude -c`) dans `~/src/config`.

## TL;DR cause racine (prouvée par les logs)

`devenv up` échouait avec `cannot connect to socket '/nix/var/nix/daemon-socket/socket'`.
Ce n'est **pas** devenv. C'est une **race au boot entre deux LaunchDaemons Determinate**, tous deux `RunAtLoad`, sans ordre garanti :

- `systems.determinate.nix-daemon` → lance le daemon (`determinate-nixd daemon`)
- `systems.determinate.nix-store`  → déverrouille + monte `/nix` (`determinate-nixd init`)

Preuve, dernier boot (`/var/log/determinate-nix-daemon.log` + `-init.log`) :

```
11:37:44.6Z  daemon : Error: failed to ensure state directory / Read-only file system (os 30)  ← crash
11:37:45.5Z  init   : Unlocking and mounting /nix → Unlocked and mounted                       ← 0,9s trop tard
```

Le daemon démarre avant le mount → son state dir tombe sur le volume **système read-only** → crash → pas de socket → Nix mort. **Le chiffrement du volume `/nix` (FileVault: Yes) élargit la fenêtre** (latence de déverrouillage). Intermittent : les jours d'avant le daemon gagnait la course.

## Faits machine

- Determinate Nix **3.17.3** (nix 2.33.3). `nix.enable = false` dans nix-darwin (Determinate gère le daemon).
- `/nix` = APFS `disk3s7`, name **"Nix Store"**, UUID **171AFE52-2D61-4DDB-A6E3-DF8BDC5AABB0**, **FileVault: Yes**.
- Daemon socket : `/var/run/nix-daemon.socket` ; symlink compat `/nix/var/nix/daemon-socket/socket → /var/run/nix-daemon.socket`.
- Override Nix : `/etc/nix/nix.custom.conf` (fichier béni Determinate, `!include`). Contient juste `extra-trusted-users = x`.
- devenv : `~/.nix-profile/bin/devenv` 2.1.2, installé via `nix profile` (paquet normal, n'a PAS touché au volume).
- Projet devenv : `~/src/finspot/pretto`, worktree `.worktrees/devx-again`.

## Décision : fix durable = upgrade Determinate PUIS guard daemon (garder le chiffrement)

Option "decrypt /nix" écartée (changement de posture sécu, inutile). Guard = seul fix déterministe.

## État au moment du handoff

- [x] **FAIT** : guard ajouté dans `hosts/macbook.nix` → `launchd.daemons.determinate-daemon-after-mount`
      (`wait4path /nix/store` puis bootstrap+kickstart du daemon Determinate). **Pas encore build/switch.**
- [ ] Blocs 1→3 ci-dessous pas encore lancés (sorties à coller dans la session).
- [ ] `darwin-rebuild switch` pas encore fait.
- [ ] reboot de validation pas encore fait.

## Runbook — TU ES ICI → reprendre au bloc 1

Le daemon est down → tout Nix (dont `darwin-rebuild`) est mort tant que le bloc 1 n'est pas passé.

```bash
# 1. Débloquer le daemon maintenant
sudo launchctl bootstrap system /Library/LaunchDaemons/systems.determinate.nix-daemon.plist 2>/dev/null
sudo launchctl kickstart -k system/systems.determinate.nix-daemon
sleep 1 && ls -la /var/run/nix-daemon.socket && nix store info

# 2. Vérifier la clé dans le trousseau SYSTÈME (prérequis mount au boot)
sudo security find-generic-password -s "Nix Store" /Library/Keychains/System.keychain 2>&1 | grep -E "svce|acct|keychain"
#   trouvé → OK ; "could not be found" → à corriger avant de compter sur l'auto-mount

# 3. Upgrade Determinate (corrige peut-être l'ordre upstream)
sudo determinate-nixd upgrade
nix store info

# 4. Installer le guard (build sans sudo d'abord)
darwin-rebuild build  --flake ~/src/config#macbook
sudo darwin-rebuild switch --flake ~/src/config#macbook

# 5. Valider au boot (safe maintenant : le guard gère la race)
sudo reboot
#   au retour, SANS rien faire à la main :
ls -la /var/run/nix-daemon.socket && cat /var/log/determinate-daemon-after-mount.log && nix store info
```

Socket présent direct au boot + `devenv up` OK sans intervention = **au carré**.

## Follow-ups séparés (après validation du boot)

1. **Token FlakeHub mort** — `auth failure: Permanent` toutes les heures dans le daemon log.
   Casse les fetch `cache.flakehub.com` / `api.flakehub.com` (utilisés par le nixpkgs-weekly pin + le bootstrap devenv).
   À investiguer : `determinate-nixd login` / état d'auth Determinate.
2. **devenv cachix absent** — ajouter dans `/etc/nix/nix.custom.conf` (sudo) :
   ```
   extra-substituters = https://devenv.cachix.org
   extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
   ```
   Puis `sudo launchctl kickstart -k system/systems.determinate.nix-daemon` pour recharger.
3. Bruit sans rapport : `mise WARN missing: node@24.15.0` → `mise install` dans le projet.
