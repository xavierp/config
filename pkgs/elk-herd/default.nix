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
