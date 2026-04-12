{ pkgs, ... }:

{
  # Nix settings (Determinate Nix manages the daemon, so nix.enable = false)
  nix.enable = false;
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
