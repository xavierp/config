{ pkgs, ... }:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./ghostty.nix
    ./claude.nix
    ./karabiner.nix
    ./tmux.nix
    ./neovim.nix
    ./aerospace.nix
  ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # Scripts
  home.file.".local/bin/tmux-sessionizer" = {
    source = ../files/scripts/tmux-sessionizer;
    executable = true;
  };

}
