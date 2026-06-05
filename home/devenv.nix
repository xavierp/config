{ pkgs, devenv, ... }:

let
  devenvPkg = devenv.packages.${pkgs.system}.devenv;
in
{
  home.packages = [ devenvPkg ];

  programs.zsh.initContent = ''
    eval "$(devenv hook zsh)"
  '';
}
