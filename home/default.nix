{ pkgs, ... }:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./ghostty.nix
    ./claude.nix
    ./tmux.nix
    ./neovim.nix
  ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # Ensure Caps Lock → Ctrl remap persists at login
  launchd.agents.caps-lock-remap = {
    enable = true;
    config = {
      Label = "com.user.caps-lock-remap";
      ProgramArguments = [
        "/usr/bin/hidutil"
        "property"
        "--set"
        ''{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}''
      ];
      RunAtLoad = true;
    };
  };
}
