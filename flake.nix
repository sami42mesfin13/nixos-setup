{
  description = "ilyamiro's NixOS configuration (flake)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations.ilyamiro = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      # Pass 'self' into all NixOS modules so we can reference the flake root path
      specialArgs = { inherit self; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.homeManager
        {
          home-manager.useGlobalPkgs    = true;
          home-manager.useUserPackages  = true;
          home-manager.backupFileExtension = "backup";
          # Pass 'self' into all home-manager modules too
          home-manager.extraSpecialArgs = { inherit self; };
          home-manager.users.ilyamiro  = { imports = [ ./home.nix ]; };
        }
      ];
    };
  };
}
