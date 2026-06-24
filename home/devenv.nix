{ pkgs, devenv, ... }:

{
  programs.devenv = {
    enable = true;
    # garde ta branche patchée — sinon le module prend pkgs.devenv (sans le fix TMPDIR)
    package = devenv.packages.${pkgs.system}.devenv;
    # enableZshIntegration est déjà true par défaut (tu utilises programs.zsh)
  };
}
