{ pkgs, ... }:

{
  # Nix settings (Determinate Nix manages the daemon, so nix.enable = false)
  nix.enable = false;
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    vim
  ];

  # Homebrew (for GUI apps / casks only)
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    casks = [
      "1password"
      "1password-cli"
      # "aerospace"  # TODO: re-enable once macOS Spaces settings are tuned
      "karabiner-elements"
      "alacritty"
      "bruno"
      "chromium"
      "dash"
      "datagrip"
      "discord"
      "docker"
      "docker-desktop"
      "firefox"
      "font-fira-code-nerd-font"
      "gcloud-cli"
      "ghostty"
      "gimp"
      "google-chrome"
      "jellyfin-media-player"
      "linear-linear"
      "macfuse"
      "nordvpn"
      "obsidian"
      "protonvpn"
      "raycast"
      "session-manager-plugin"
      "sigmaos"
      "slack"
      "soulseek"
      "spotify"
      "tor-browser"
      "visual-studio-code"
      "vlc"
      "whatsapp"
    ];
  };

  # Required for nix-darwin
  system.primaryUser = "x";
  system.stateVersion = 6;

  # User
  users.users.x = {
    name = "x";
    home = "/Users/x";
  };
}
