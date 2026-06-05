{
  description = "Xavier's macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devenv.url = "github:cachix/devenv";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, devenv, ... }: {
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      stdenv.hostPlatform.system = "aarch64-darwin";
      modules = [
        ./hosts/macbook.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.extraSpecialArgs = { inherit devenv; };
          home-manager.users.x = import ./home/default.nix;
        }
      ];
    };
  };
}
