{ pkgs, devenv, ... }:

{
  programs.devenv = {
    enable = true;
    # garde ta branche patchée — sinon le module prend pkgs.devenv (sans le fix TMPDIR)
    package = devenv.packages.${pkgs.system}.devenv;
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
