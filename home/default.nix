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
    ./mise.nix
  ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # Sesh (tmux session manager)
  xdg.configFile."sesh/sesh.toml".source = ../files/sesh/sesh.toml;

  # Scripts
  home.file.".local/bin/tmux-url-picker" = {
    source = ../files/scripts/tmux-url-picker;
    executable = true;
  };

}
