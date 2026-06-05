{ pkgs, ... }:

{
  # Nix settings (Determinate Nix manages the daemon, so nix.enable = false)
  nix.enable = false;
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Fix race condition au boot entre les deux LaunchDaemons Determinate :
  # systems.determinate.nix-daemon (RunAtLoad) peut démarrer AVANT que
  # systems.determinate.nix-store ait déverrouillé+monté /nix (volume chiffré →
  # latence de déverrouillage). Quand le daemon perd la course, il crashe sur le
  # volume système read-only ("failed to ensure state directory") et ne crée
  # jamais son socket → Nix mort jusqu'à relance manuelle. Ce guard attend le
  # mount de /nix puis (re)lance le daemon. N'utilise que des binaires du volume
  # système (/bin/sh, wait4path, launchctl) pour pouvoir tourner avant le mount.
  launchd.daemons.determinate-daemon-after-mount.serviceConfig = {
    RunAtLoad = true;
    ProgramArguments = [
      "/bin/sh"
      "-c"
      "/bin/wait4path /nix/store && { /bin/launchctl bootstrap system /Library/LaunchDaemons/systems.determinate.nix-daemon.plist 2>/dev/null; /bin/launchctl kickstart -k system/systems.determinate.nix-daemon; }"
    ];
    StandardOutPath = "/var/log/determinate-daemon-after-mount.log";
    StandardErrorPath = "/var/log/determinate-daemon-after-mount.log";
  };

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
      cleanup = "none";
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
      "docker-desktop"
      "firefox"
      "font-fira-code-nerd-font"
      "gcloud-cli"
      "ghostty"
      "gimp"
      "google-chrome"
      "jellyfin-media-player"
      "linear"
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

  # macOS defaults
  system.defaults.NSGlobalDomain = {
    AppleShowAllExtensions = true;
    NSAutomaticWindowAnimationsEnabled = false;
    "com.apple.swipescrolldirection" = false;
  };

  system.defaults.finder = {
    AppleShowAllFiles = true;
    ShowPathbar = true;
    FXPreferredViewStyle = "Nlsv";
  };

  system.defaults.dock = {
    autohide = true;
    autohide-time-modifier = 0.0;
    launchanim = false;
    mru-spaces = false;
    show-recents = false;
    show-process-indicators = true;
    tilesize = 46;
    expose-group-apps = true;
  };

  # Touch ID pour sudo (+ reattach pour tmux)
  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;

  # Required for nix-darwin
  system.primaryUser = "x";
  system.stateVersion = 6;

  # User
  users.users.x = {
    name = "x";
    home = "/Users/x";
  };
}
