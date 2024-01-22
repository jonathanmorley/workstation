{
  description = "Jonathan's Configurations";

  inputs = {
    # NixPkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Nix Darwin
    darwin.url = "github:jonathanmorley/nix-darwin/fix-cacerts-with-spaces";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Oktaws
    oktaws.url = "github:jonathanmorley/oktaws";
  };

  outputs = { self, nixpkgs, darwin, home-manager, oktaws, ... }:
    let
      darwinModules = [./darwin.nix];
      homeModules = { profiles, username, ... }: [
        home-manager.darwinModules.home-manager {
          nixpkgs.overlays = [ oktaws.overlay ];
          nixpkgs.config.allowUnfree = true;

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit profiles username; };
          home-manager.users."${username}" = import ./home.nix;
        }
      ];
    in
    {
      darwinConfigurations = rec {
        # GitHub CI
        "ci" = darwin.lib.darwinSystem rec {
          system = "x86_64-darwin";
          specialArgs.profiles = [];

          modules = darwinModules ++ homeModules {
            profiles = specialArgs.profiles;
            username = "runner";
          };
        };

        # Cvent MacBook Air
        "FVFFT3XKQ6LR" = darwin.lib.darwinSystem rec {
          system = "aarch64-darwin";
          specialArgs.profiles = ["cvent"];

          modules = darwinModules ++ homeModules {
            profiles = specialArgs.profiles;
            username = "jonathan";
          };
        };

        # Cvent MacBook Pro
        "C02C9B4MMD6R" = darwin.lib.darwinSystem rec {
          system = "x86_64-darwin";
          specialArgs.profiles = ["cvent"];

          modules = darwinModules ++ homeModules {
            profiles = specialArgs.profiles;
            username = "jmorley";
          };
        };
      };
    };
}