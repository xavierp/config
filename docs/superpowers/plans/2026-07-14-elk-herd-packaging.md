# elk-herd Nix Packaging Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Packager elk-herd v3.3.4 (web app Elm pour instruments Elektron) en derivation Nix reproductible, installée via home-manager, avec une commande `elk-herd` qui sert l'app en local et ouvre Chrome.

**Architecture:** Une derivation `site` reproduit les étapes de `make-prod.sh` upstream dans la sandbox (deps Elm offline via elm2nix/`fetchElmDeps`, assets externes en `fetchurl` pinnés, `elm make --optimize` + terser), un `writeShellScriptBin` fournit le launcher, `symlinkJoin` assemble les deux. Un module home-manager `home/elk-herd.nix` installe le package.

**Tech Stack:** Nix (nix-darwin + home-manager), Elm 0.19.1, elm2nix 0.4.0, terser 5.46.1, python3 http.server (launcher).

**Spec:** `docs/superpowers/specs/2026-07-14-elk-herd-install-design.md`

## Global Constraints

- nixpkgs pinné du flake : `github:cachix/devenv-nixpkgs/8f24a228a782e24576b155d1e39f0d914b380691`, système `aarch64-darwin`. Disponibilités vérifiées : `elmPackages.elm` 0.19.1, `elmPackages.fetchElmDeps`, `terser` 5.46.1 (top-level, PAS `nodePackages.terser` — supprimé), `elm2nix` 0.4.0.
- Version upstream pinnée : tag `v3.3.4` (commit 056f496b4a6dd6d0cc836d45356be38fe6114868).
- Hashes SRI préfetchés (2026-07-14) — à utiliser tels quels :
  - src GitHub : `sha256-kje7c5x+St50TNnqu062eJnj18p1qKtSL3wElpBw2PU=`
  - jQuery 3.4.1 : `sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=`
  - Bootstrap 4.3.1 dist zip : `sha256-iI/9MLfhkjgeL2qUjKBGaf3MLMwroBbeANOMjjB5MyM=`
  - Source Code Pro TTF zip : `sha256-DIW6yQ0VwEC4KTmqkryEBEIPzMAuN7vLnJOn8hq7UsY=`
- **Quirk flake** : tout nouveau fichier (y compris `registry.dat`, binaire) doit être `git add`é AVANT `darwin-rebuild build`, sinon le flake ne le voit pas.
- Le build Nix n'a pas d'accès réseau : aucun `curl`/`elm` fetch pendant les phases de build.
- Commits : anglais, conventional commits. Jamais de trailer Co-Authored-By.
- Commandes de validation : `darwin-rebuild build --flake ~/src/config#macbook` (jamais `switch` sans Xavier).
- Divergences assumées vs upstream `make-prod.sh` (documentées dans le spec) : pas de source-maps, pas d'artefacts `.gz` (utiles uniquement pour un serveur web public).

## Référence : ce que fait le build upstream (relevé dans le repo à v3.3.4)

`get-ext.sh` télécharge et place :
- `https://code.jquery.com/jquery-3.4.1.min.js` → `assets/ext/jquery-3.4.1.min.js`
- zip Bootstrap → `assets/ext/bootstrap-4.3.1.bundle.min.js` (depuis `bootstrap-4.3.1-dist/js/bootstrap.bundle.min.js`) et `assets/ext/bootstrap-4.3.1.min.css` (depuis `bootstrap-4.3.1-dist/css/bootstrap.min.css`)
- zip Source Code Pro → `assets/ext/SourceCodePro-Semibold.ttf` (depuis `TTF/SourceCodePro-Semibold.ttf`)

`make-prod.sh` :
1. `ln -sf Debug.elm.prod src/SysEx/Debug.elm` (dans le repo, le symlink pointe sur `Debug.elm.dev`)
2. `elm make --optimize src/Main.elm --output build/main-prod.js`
3. `cat assets/*.js build/main-prod.js > build/main.js` (concatène `assets/portage.js`, le glue JS des ports, AVANT le code Elm — `index.html` appelle `hookup_ports(app)`)
4. terser en deux passes : `terser IN --compress '<opts>' | terser --mangle --output OUT`
5. idem pour `src/Help.elm` (sans concaténation)
6. packaging : `distribution/elk-herd/` = `assets/` (moins `assets/*.js` top-level, incorporés), `build/main.js`, `build/help.js`, `index.html`, `help.html`

---

### Task 1: Générer les lockfiles Elm (elm-srcs.nix + registry.dat)

**Files:**
- Create: `pkgs/elk-herd/elm-srcs.nix` (généré)
- Create: `pkgs/elk-herd/registry.dat` (généré, binaire)

**Interfaces:**
- Produces: `pkgs/elk-herd/elm-srcs.nix` — attrset Nix `{ "<author>/<pkg>" = { sha256 = "..."; version = "..."; }; ... }` consommé par `import ./elm-srcs.nix` dans Task 2. `pkgs/elk-herd/registry.dat` — snapshot binaire du registry Elm, consommé par `registryDat = ./registry.dat;`.

- [ ] **Step 1: Cloner elk-herd v3.3.4 dans un répertoire temporaire**

```bash
workdir=$(mktemp -d)
git clone --quiet --depth 1 --branch v3.3.4 https://github.com/mzero/elk-herd "$workdir/elk-herd"
```

Attendu : warning git `refs/tags/v3.3.4 ... is not a commit!` (tag annoté) — bénin. `ls "$workdir/elk-herd/elm.json"` existe.

- [ ] **Step 2: Générer elm-srcs.nix et registry.dat avec elm2nix (nixpkgs pinné)**

```bash
NP=github:cachix/devenv-nixpkgs/8f24a228a782e24576b155d1e39f0d914b380691
cd "$workdir/elk-herd"
nix shell "$NP#elm2nix" -c elm2nix convert > elm-srcs.nix
nix shell "$NP#elm2nix" -c elm2nix snapshot
ls -la elm-srcs.nix registry.dat
```

Attendu : les deux fichiers existent, `registry.dat` fait plusieurs centaines de Ko. (`elm2nix snapshot` télécharge le registry courant — le contenu exact varie selon la date, c'est normal ; seul compte qu'il contienne les versions d'`elm.json`.)

- [ ] **Step 3: Vérifier la forme d'elm-srcs.nix**

```bash
grep -E '"elm/(core|browser|bytes)"' elm-srcs.nix
nix eval --impure --expr "builtins.length (builtins.attrNames (import $workdir/elk-herd/elm-srcs.nix))"
```

Attendu : les 3 packages matchent ; le count est 15 (10 deps directes + 3 indirectes + 2 test). 13 acceptable si elm2nix exclut les test-deps.

- [ ] **Step 4: Copier dans le config repo**

```bash
mkdir -p ~/src/config/pkgs/elk-herd
cp "$workdir/elk-herd/elm-srcs.nix" "$workdir/elk-herd/registry.dat" ~/src/config/pkgs/elk-herd/
```

- [ ] **Step 5: Commit**

```bash
cd ~/src/config
git add pkgs/elk-herd/elm-srcs.nix pkgs/elk-herd/registry.dat
git commit -m "chore(pkgs): add elm2nix lockfiles for elk-herd v3.3.4"
```

---

### Task 2: Écrire la derivation `pkgs/elk-herd/default.nix`

**Files:**
- Create: `pkgs/elk-herd/default.nix`

**Interfaces:**
- Consumes: `./elm-srcs.nix` et `./registry.dat` (Task 1).
- Produces: un package callPackage-able `pkgs/elk-herd` avec `$out/bin/elk-herd` (launcher) et `$out/share/elk-herd/` (site statique : `index.html`, `help.html`, `assets/`, `build/main.js`, `build/help.js`). Consommé par `pkgs.callPackage ../pkgs/elk-herd { }` en Task 3.

- [ ] **Step 1: Écrire `pkgs/elk-herd/default.nix`**

Contenu complet :

```nix
{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, elmPackages
, terser
, unzip
, python3
, writeShellScriptBin
, symlinkJoin
}:

let
  version = "3.3.4";

  # Assets externes — ce que get-ext.sh télécharge (versions figées par upstream)
  jquery = fetchurl {
    url = "https://code.jquery.com/jquery-3.4.1.min.js";
    hash = "sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=";
  };
  bootstrapZip = fetchurl {
    url = "https://github.com/twbs/bootstrap/releases/download/v4.3.1/bootstrap-4.3.1-dist.zip";
    hash = "sha256-iI/9MLfhkjgeL2qUjKBGaf3MLMwroBbeANOMjjB5MyM=";
  };
  sourceCodeProZip = fetchurl {
    url = "https://github.com/adobe-fonts/source-code-pro/releases/download/2.042R-u%2F1.062R-i%2F1.026R-vf/TTF-source-code-pro-2.042R-u_1.062R-i.zip";
    hash = "sha256-DIW6yQ0VwEC4KTmqkryEBEIPzMAuN7vLnJOn8hq7UsY=";
  };

  # Options de compression identiques à make-prod.sh (run_terser)
  terserOpts = "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe";

  site = stdenv.mkDerivation {
    pname = "elk-herd-site";
    inherit version;

    src = fetchFromGitHub {
      owner = "mzero";
      repo = "elk-herd";
      rev = "v${version}";
      hash = "sha256-kje7c5x+St50TNnqu062eJnj18p1qKtSL3wElpBw2PU=";
    };

    nativeBuildInputs = [ elmPackages.elm terser unzip ];

    # Peuple ELM_HOME hors-ligne avec les deps d'elm.json
    preConfigure = elmPackages.fetchElmDeps {
      elmPackages = import ./elm-srcs.nix;
      elmVersion = "0.19.1";
      registryDat = ./registry.dat;
    };

    # Reproduit get-ext.sh (sans réseau) puis make-prod.sh
    # (sans source-maps ni .gz, inutiles en local)
    buildPhase = ''
      runHook preBuild

      mkdir -p assets/ext build
      cp ${jquery} assets/ext/jquery-3.4.1.min.js
      unzip -q ${bootstrapZip} -d ext-tmp
      cp ext-tmp/bootstrap-4.3.1-dist/js/bootstrap.bundle.min.js assets/ext/bootstrap-4.3.1.bundle.min.js
      cp ext-tmp/bootstrap-4.3.1-dist/css/bootstrap.min.css assets/ext/bootstrap-4.3.1.min.css
      unzip -q ${sourceCodeProZip} -d fonts-tmp
      cp fonts-tmp/TTF/SourceCodePro-Semibold.ttf assets/ext/

      ln -sf Debug.elm.prod src/SysEx/Debug.elm

      elm make --optimize src/Main.elm --output build/main-prod.js
      cat assets/*.js build/main-prod.js > build/main.js
      terser build/main.js --compress '${terserOpts}' | terser --mangle --output build/main-min.js

      elm make --optimize src/Help.elm --output build/help-prod.js
      terser build/help-prod.js --compress '${terserOpts}' | terser --mangle --output build/help-min.js

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      appdir=$out/share/elk-herd
      mkdir -p "$appdir/build"
      cp -rp assets "$appdir/"
      rm "$appdir"/assets/*.js   # incorporés dans build/main.js
      cp build/main-min.js "$appdir/build/main.js"
      cp build/help-min.js "$appdir/build/help.js"
      cp index.html help.html "$appdir/"

      runHook postInstall
    '';
  };

  # Sert le site en localhost (contexte sécurisé => permission WebMIDI/SysEx OK)
  launcher = writeShellScriptBin "elk-herd" ''
    port="''${1:-8676}"
    url="http://localhost:$port/"

    ${python3}/bin/python3 -m http.server "$port" --bind 127.0.0.1 \
      --directory ${site}/share/elk-herd &
    server_pid=$!
    trap 'kill "$server_pid" 2>/dev/null' EXIT INT TERM

    echo "elk-herd: $url  (Ctrl-C pour arrêter)"
    sleep 1
    open -a "Google Chrome" "$url" 2>/dev/null || open "$url"
    wait "$server_pid"
  '';

in
symlinkJoin {
  name = "elk-herd-${version}";
  paths = [ launcher site ];
  meta = with lib; {
    description = "Device manager for Elektron instruments (Digitakt, Model:Samples, Analog Rytm)";
    homepage = "https://github.com/mzero/elk-herd";
    license = licenses.bsd2;
    platforms = platforms.darwin; # le launcher utilise `open` ; le site lui-même est portable
    mainProgram = "elk-herd";
  };
}
```

Points d'attention pour l'implémenteur :
- `''${1:-8676}` : échappement Nix voulu — produit `${1:-8676}` dans le script shell final. Ne pas "corriger".
- `terser` est le package top-level, PAS `nodePackages.terser`.
- Le `ln -sf` remplace le symlink `Debug.elm.dev` présent dans le src (make-prod.sh fait pareil).

- [ ] **Step 2: Builder le package directement (sans passer par le flake)**

```bash
RESULT="${TMPDIR:-/tmp}/elk-herd-result"
nix build --impure -L -o "$RESULT" --expr \
  '(builtins.getFlake "github:cachix/devenv-nixpkgs/8f24a228a782e24576b155d1e39f0d914b380691").legacyPackages.aarch64-darwin.callPackage /Users/x/src/config/pkgs/elk-herd { }'
```

Attendu : build OK (compte quelques minutes la première fois : compilation Elm + deps). En cas d'erreur de hash `fetchElmDeps`, vérifier que `elm-srcs.nix`/`registry.dat` viennent bien du tag v3.3.4 (Task 1).

- [ ] **Step 3: Vérifier le contenu du résultat**

```bash
RESULT="${TMPDIR:-/tmp}/elk-herd-result"
ls "$RESULT/bin" "$RESULT/share/elk-herd" "$RESULT/share/elk-herd/assets/ext"
head -c 200 "$RESULT/share/elk-herd/build/main.js"; echo
```

Attendu :
- `bin/` contient `elk-herd` ; `share/elk-herd/` contient `index.html`, `help.html`, `assets/`, `build/`
- `assets/ext/` contient `jquery-3.4.1.min.js`, `bootstrap-4.3.1.bundle.min.js`, `bootstrap-4.3.1.min.css`, `SourceCodePro-Semibold.ttf`
- `assets/` ne contient PAS de `.js` top-level (portage.js incorporé)
- `main.js` commence par du JS minifié contenant `hookup_ports` (glue des ports, concaténée avant le code Elm)

- [ ] **Step 4: Smoke test du launcher**

```bash
RESULT="${TMPDIR:-/tmp}/elk-herd-result"
"$RESULT/bin/elk-herd" 8677 & LAUNCHER_PID=$!
sleep 3
curl -s http://localhost:8677/ | head -3
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:8677/build/main.js
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:8677/assets/ext/bootstrap-4.3.1.min.css
kill "$LAUNCHER_PID"
```

Attendu : `<!DOCTYPE HTML>` dans les 3 premières lignes, puis `200`, `200`. (Le launcher aura aussi ouvert Chrome — fermer l'onglet, c'est le test de Task 4 qui compte.)

- [ ] **Step 5: Commit**

```bash
cd ~/src/config
git add pkgs/elk-herd/default.nix
git commit -m "feat(pkgs): add elk-herd package (Elm build from source)"
```

---

### Task 3: Module home-manager + validation flake

**Files:**
- Create: `home/elk-herd.nix`
- Modify: `home/default.nix:4-15` (liste `imports`)

**Interfaces:**
- Consumes: `pkgs.callPackage ../pkgs/elk-herd { }` (Task 2).
- Produces: `elk-herd` sur le PATH du profil home-manager après switch.

- [ ] **Step 1: Écrire `home/elk-herd.nix`**

Contenu complet :

```nix
{ pkgs, ... }:

{
  # elk-herd — device manager pour instruments Elektron (Digitakt…)
  # Web app Elm servie en localhost, WebMIDI => Chrome uniquement.
  home.packages = [ (pkgs.callPackage ../pkgs/elk-herd { }) ];
}
```

- [ ] **Step 2: L'importer dans `home/default.nix`**

Dans la liste `imports`, ajouter `./elk-herd.nix` après `./devenv.nix` :

```nix
  imports = [
    ./shell.nix
    ./git.nix
    ./ghostty.nix
    ./claude.nix
    ./karabiner.nix
    ./tmux.nix
    ./neovim.nix
    ./aerospace.nix
    ./runtimes.nix
    ./devenv.nix
    ./elk-herd.nix
  ];
```

- [ ] **Step 3: git add AVANT le build flake (quirk tracked-files)**

```bash
cd ~/src/config
git add home/elk-herd.nix home/default.nix
git status --short
```

Attendu : `A  home/elk-herd.nix`, `M  home/default.nix` (et rien d'untracked sous `pkgs/`).

- [ ] **Step 4: Valider le build système complet**

```bash
darwin-rebuild build --flake ~/src/config#macbook
```

Attendu : exit 0. Le package est déjà dans le store (Task 2), seule l'éval home-manager est nouvelle.

- [ ] **Step 5: Commit**

```bash
git commit -m "feat(home): install elk-herd"
```

---

### Task 4: Switch + validation finale

**Files:** aucun (activation + tests).

**Interfaces:**
- Consumes: le profil home-manager (Task 3).

- [ ] **Step 1: Switch (sudo — à faire par Xavier si la session ne peut pas)**

```bash
sudo darwin-rebuild switch --flake ~/src/config#macbook
```

Si le sudo interactif ne passe pas dans la session, demander à Xavier de taper `! sudo darwin-rebuild switch --flake ~/src/config#macbook`.

- [ ] **Step 2: Vérifier la commande sur le PATH**

```bash
which elk-herd
```

Attendu : `/Users/x/.nix-profile/bin/elk-herd` (ou chemin de profil équivalent).

- [ ] **Step 3: Test fonctionnel Chrome**

```bash
elk-herd
```

Attendu : Chrome s'ouvre sur `http://localhost:8676/`, l'UI elk-herd se charge (logo elk, panneau de connexion MIDI), pas d'erreur bloquante dans la console. Critère spec n°2. Ctrl-C arrête proprement le serveur.

- [ ] **Step 4: Clore — critère matériel hors périmètre**

Le test avec l'instrument Elektron branché (SysEx) est manuel, par Xavier, hors périmètre du plan (critère spec n°3).

---

## Notes de maintenance (hors tasks)

- **Bump de version** : changer `version` + `hash` du src dans `default.nix`, re-dérouler Task 1 sur le nouveau tag si `elm.json` a changé, vérifier `get-ext.sh` upstream pour de nouveaux assets, puis Tasks 2–3 (build + validation).
- **Extraction flake public** (hors scope, prévu par le spec) : `pkgs/elk-herd/` est self-contained — le déplacer dans un repo dédié avec un `flake.nix` exposant `packages.aarch64-darwin.elk-herd` et `apps`.
