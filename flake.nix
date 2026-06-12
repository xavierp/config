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
    # TEMP: branche du fix DEVENV_RUNTIME/TMPDIR — revenir sur github:cachix/devenv
    # une fois https://github.com/cachix/devenv/pull/2927 mergée
    devenv.url = "github:cachix/devenv/fix/runtime-dir-tmpdir-2923";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, devenv, ... }: {
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
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
