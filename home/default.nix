{ pkgs, ... }:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./ghostty.nix
    ./claude.nix
  ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
