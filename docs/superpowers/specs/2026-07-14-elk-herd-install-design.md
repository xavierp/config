# elk-herd — packaging Nix (design)

**Date:** 2026-07-14
**Statut:** validé par Xavier

## Contexte

[elk-herd](https://github.com/mzero/elk-herd) est un device manager pour instruments
Elektron (Digitakt, Digitakt II, Model:Samples, Analog Rytm) : gestion de samples,
projets et patterns via WebMIDI, dans Chrome uniquement. C'est une web app Elm
statique — pas de binaire, pas de package nixpkgs ni de formule brew.

L'auteur fournit une version hébergée (https://electric.kitchen/crunch/elk-herd/) et
une archive offline. Xavier veut néanmoins un **build from source packagé Nix**,
intégré au config repo dans un premier temps, extractible plus tard en flake public.

## Décision

**Approche retenue :** derivation Nix reproduisant les étapes de `make-prod.sh`
dans la sandbox (build offline), tous les téléchargements déclarés et pinnés.
Approches rejetées : exécuter les scripts upstream patchés (fragile), fixed-output
derivation avec réseau (impur, non publiable).

**Version pinnée :** tag `v3.3.4` (2025-08-03, dernière release).

## Architecture

```
config/
├── pkgs/
│   └── elk-herd/
│       ├── default.nix      # la derivation (src, deps, build, launcher)
│       ├── elm-srcs.nix     # deps Elm pinnées (généré par elm2nix)
│       └── registry.dat     # snapshot du registry Elm (généré par elm2nix)
└── home/
    └── elk-herd.nix         # module home-manager : ajoute le package
```

### Derivation (`pkgs/elk-herd/default.nix`)

- `src = fetchFromGitHub { owner = "mzero"; repo = "elk-herd"; rev = "v3.3.4"; }`
- **Deps Elm offline** : `elmPackages.fetchElmDeps` (mécanisme standard nixpkgs)
  alimenté par `elm-srcs.nix` + `registry.dat` générés avec `elm2nix` depuis le
  `elm.json` du tag pinné. Elm 0.19.1, 10 deps directes.
- **Assets externes pinnés en `fetchurl`** (ce que `get-ext.sh` télécharge) :
  jQuery 3.4.1, Bootstrap 4.3.1, police Source Code Pro. URLs et emplacements
  exacts relevés dans `get-ext.sh` au moment de l'implémentation.
- **Build** (réécriture des étapes de `make-prod.sh`) :
  `elm make --optimize` → minification `terser` → assemblage du site statique.
  Les étapes exactes (concaténation d'assets, gzip éventuel) sont relevées dans le
  script au moment de l'implémentation ; les artefacts `.gz` destinés au serving
  web ne sont pas nécessaires pour l'usage local et peuvent être omis.
- **Outputs** :
  - `$out/share/elk-herd/` — le site statique complet
  - `$out/bin/elk-herd` — launcher

### Launcher `elk-herd`

Script shell wrappé qui :
1. sert `$out/share/elk-herd` sur `http://localhost:<port>` (port fixe, ex. 8676,
   configurable par argument) — contexte sécurisé garanti pour la permission
   WebMIDI/SysEx nécessaire au dialogue avec l'instrument ;
2. ouvre Chrome sur cette URL (`open -a "Google Chrome" http://localhost:<port>`) ;
3. reste au premier plan tant que le serveur tourne (Ctrl-C pour arrêter).

Serveur statique : le plus léger disponible dans nixpkgs sans dépendance lourde
(`python3 -m http.server` en bind 127.0.0.1 par défaut, sauf meilleure option).

### Intégration home-manager

`home/elk-herd.nix` (découpage par concern, convention du repo) :
`home.packages = [ (pkgs.callPackage ../pkgs/elk-herd { }) ];`
importé depuis `home/default.nix`.

## Maintenance

- **Bump de version** : changer `rev` + `hash` du src, régénérer
  `elm-srcs.nix`/`registry.dat` si `elm.json` a changé, vérifier `get-ext.sh` pour
  de nouveaux assets, `darwin-rebuild build` pour valider.
- **Publication future** : `pkgs/elk-herd/` est self-contained → extraction vers un
  repo flake standalone (`packages.<system>.elk-herd` + `apps`), le config repo le
  consommerait alors comme input. Hors scope de cette itération.

## Risques

- **`elm` 0.19.1 sur aarch64-darwin** (confiance moyenne) : dispo dans nixpkgs mais
  selon les versions, binaire x86_64 via Rosetta. À vérifier en premier pendant
  l'implémentation ; fallback : wrapper du binaire officiel Elm.
- **`terser` dans nixpkgs** : dispo (`nodePackages.terser` ou équivalent), à
  confirmer. Fallback : `esbuild --minify` (résultat équivalent pour du JS généré
  par Elm) — divergence documentée si utilisée.
- **`elm2nix`** : outil à exécuter une fois hors sandbox pour générer les fichiers
  pinnés ; dispo dans nixpkgs.

## Critères de succès

1. `darwin-rebuild build --flake ~/src/config#macbook` passe.
2. Après `switch`, la commande `elk-herd` ouvre Chrome sur l'app fonctionnelle
   (l'UI se charge, pas d'erreur console bloquante).
3. Test matériel (connexion à l'instrument Elektron) : validation manuelle par
   Xavier — hors périmètre automatisable.
