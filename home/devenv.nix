{ pkgs, devenv, ... }:

{
  programs.devenv = {
    enable = true;
    # devenv depuis le flake input (main) plutôt que pkgs.devenv, plus à jour
    package = devenv.packages.${pkgs.stdenv.hostPlatform.system}.devenv;
    enableZshIntegration = false;   # on gère le hook nous-mêmes pour pouvoir le garder
  };

  # Guard Claude Code : sous un teammate, le shell interactif n'a pas DEVENV_ROOT
  # et le precmd lancerait un `devenv shell` bloquant qui s'intercale avant le process.
  # Aligné sur finspot/pretto PR 46497.
  programs.zsh.initContent = ''
    if [[ -z "''${CLAUDECODE:-}" ]]; then
      eval "$(devenv hook zsh)"
    fi
  '';
}
