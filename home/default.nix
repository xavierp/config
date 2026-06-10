{ config, pkgs, ... }:

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
    ./devenv.nix
  ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # Sesh (tmux session manager)
  xdg.configFile."sesh/sesh.toml".source = ../files/sesh/sesh.toml;

  # Global markdownlint config (disable line-length rule)
  home.file.".markdownlint-cli2.jsonc".text = builtins.toJSON {
    config = { line-length = false; };
  };

  # Scripts
  home.file.".local/bin/tmux-url-picker" = {
    source = ../files/scripts/tmux-url-picker;
    executable = true;
  };

  # Obsidian CLI: symlink the binary bundled in the app onto PATH.
  # Replaces Obsidian's built-in registration, which fails here because it
  # tries to write to ~/.zprofile (a read-only symlink into the Nix store).
  home.file.".local/bin/obsidian".source =
    config.lib.file.mkOutOfStoreSymlink
      "/Applications/Obsidian.app/Contents/MacOS/obsidian-cli";

}
