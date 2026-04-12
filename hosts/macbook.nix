{ pkgs, ... }:

{
  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages (minimal for bootstrap)
  environment.systemPackages = with pkgs; [
    vim
  ];

  # Required for nix-darwin
  system.stateVersion = 6;

  # User
  users.users.x = {
    name = "x";
    home = "/Users/x";
  };
}
