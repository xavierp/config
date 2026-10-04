{ pkgs, ... }:

let
  # Entraînement à l'oreille : joue un intervalle au hasard sans le nom du
  # fichier ni la réponse parlée en fin de piste, Entrée pour révéler.
  #   intervals        → tous les dossiers mélangés
  #   intervals 1|2|3  → uniquement le dossier dont le nom commence par ce numéro
  intervals = pkgs.writeShellApplication {
    name = "intervals";
    runtimeInputs = with pkgs; [ coreutils findutils ];
    text = ''
      root="''${INTERVALS_DIR:-$HOME/Downloads/intervalles audio}"
      filter="''${1:-all}"

      if [ "$filter" = "all" ]; then
        dirs=("$root")
      else
        mapfile -t dirs < <(find "$root" -mindepth 1 -maxdepth 1 -type d -name "$(printf '%02d' "$filter") *")
        if [ "''${#dirs[@]}" -eq 0 ]; then
          echo "Aucun dossier '$filter' dans $root :" >&2
          find "$root" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort >&2
          exit 1
        fi
      fi

      mapfile -t sounds < <(find "''${dirs[@]}" -type f -name '*.mp3')
      if [ "''${#sounds[@]}" -eq 0 ]; then
        echo "Aucun mp3 trouvé dans ''${dirs[*]}" >&2
        exit 1
      fi

      echo "''${#sounds[@]} sons — Entrée : réponse · r : réécouter · q : quitter"
      while true; do
        sound=$(printf '%s\n' "''${sounds[@]}" | shuf -n 1)
        while true; do
          # Les fichiers enchaînent intervalle (fin ≤ 3,05 s) puis réponse
          # parlée (début ≥ 3,46 s) : on ne joue que l'intervalle.
          /usr/bin/afplay -t 3.3 "$sound"
          read -rp "? " key
          case "$key" in
            r) continue ;;
            q) exit 0 ;;
            *) break ;;
          esac
        done
        echo "→ $(basename "$(dirname "$sound")") / $(basename "$sound" .mp3)"
        echo
      done
    '';
  };
in
{
  home.packages = with pkgs; [
    intervals

    # Modern replacements
    bat          # cat replacement with syntax highlighting
    eza          # ls replacement with icons and git
    fd           # find replacement
    ripgrep      # grep replacement
    tldr         # simplified man pages

    # Utilities
    jq
    yq-go
    wget
    tree
    watch
    gnused
    gnupg        # pinentry-mac déjà câblé dans le gpg-agent de nixpkgs

    # Session management
    sesh

    # Dev tools
    awscli2
    terragrunt
    tflint
    gh
    difftastic
    gws          # Google Workspace CLI
    nixd         # Nix LSP (utilisé par Zed)
    # gcloud + gke auth plugin (suit le flake, remplace le cask gcloud-cli)
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])

    # PostgreSQL client tools (pg_dump, psql, etc.)
    postgresql_18

    # PDF tooling (pdftotext, pdfinfo, etc.)
    poppler-utils

    # Media
    ffmpeg
  ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    completionInit = "autoload -U compinit && compinit -C";

    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
      export PATH="$PATH:/Users/x/.local/bin"
    '';

    history = {
      size = 1000000000;
      save = 1000000000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
      append = true;
    };

    initContent = ''
      # Auto-attach to tmux via sesh (skip if already inside tmux)
      if [[ -z "$TMUX" && "$TERM_PROGRAM" == "ghostty" ]]; then
        selected=$(sesh list | fzf --reverse --prompt='session > ')
        exec sesh connect "''${selected:-main}"
      fi

      # Fix zsh glob errors on *, ?, [
      setopt NO_NOMATCH
    '';

    shellAliases = {
      # Shortcuts
      dk = "docker";
      dkc = "docker compose";
      g = "git";
      tf = "terraform";

      # bat/eza/rg/fd installés mais pas aliasés sur cat/ls/grep/find :
      # comportement standard par défaut, outils modernes à la demande
      ll = "eza -alh --icons --git";
    };
  };

  # Zoxide (smart cd)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Fzf (fuzzy finder)
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidget.command = "fd --type f --hidden --follow --exclude .git";
    changeDirWidget.command = "fd --type d --hidden --follow --exclude .git";
  };

  # Direnv (per-directory env)
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = "$username$hostname$directory$git_branch$git_state$git_status$cmd_duration$line_break$python$character";

      directory.style = "blue";

      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
        vimcmd_symbol = "[❮](green)";
      };

      git_branch = {
        format = "[$branch]($style)";
        style = "bright-black";
      };

      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
        style = "cyan";
        conflicted = "​";
        untracked = "​";
        modified = "​";
        staged = "​";
        renamed = "​";
        deleted = "​";
        stashed = "≡";
      };

      git_state = {
        format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
        style = "bright-black";
      };

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "yellow";
      };

      python = {
        format = "[$virtualenv]($style) ";
        style = "bright-black";
      };

    };
  };
}
