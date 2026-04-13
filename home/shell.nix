{ pkgs, ... }:

{
  home.packages = with pkgs; [
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

    # Dev tools
    awscli2
    terraform
    terragrunt
    tflint
    gh
    difftastic
  ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 1000000000;
      save = 1000000000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
      append = true;
    };

    initContent = ''
      # Fix zsh glob errors on *, ?, [
      setopt NO_NOMATCH

      # Keep nvm working (installed outside Nix)
      export NVM_DIR="$HOME/.nvm"
      [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
      [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

      # Keep rbenv working (installed outside Nix)
      eval "$(rbenv init - --no-rehash zsh)"
    '';

    shellAliases = {
      # Shortcuts
      dk = "docker";
      dkc = "docker compose";
      g = "git";
      tf = "terraform";

      # Modern replacements
      cat = "bat";
      ls = "eza -1 --icons";
      ll = "eza -alh --icons --git";
      grep = "rg";
      find = "fd";
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
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
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
