{
  description = "Jonathan's Configurations";

  inputs = {
    # NixPkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-21.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Nix Darwin
    darwin.url = "github:jonathanmorley/nix-darwin/fix-cacerts-with-spaces";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Extra Packages
    pkgs.url = "./pkgs";
    rtx.url = "github:jdxcode/rtx";
    rtx.inputs.nixpkgs.follows = "nixpkgs-unstable";
    firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
  };

  outputs = { self, nixpkgs, darwin, home-manager, rtx, pkgs, firefox-darwin, ... }:
    let
      darwinModules = [./darwin.nix];
      homeModules = { publicKey, profiles, ... }: [
        home-manager.darwinModules.home-manager {
          nixpkgs.overlays = [ pkgs.overlay rtx.overlay firefox-darwin.overlay ];
          nixpkgs.config.allowUnfree = true;

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit publicKey profiles; };
          home-manager.users.jonathan = import ./home.nix;
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
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMaD+wDTOJWGZa2PdaPVPTEsq1gte3zGOCI6DrUfk65k";
          };
        };

        # Cvent MacBook Air
        "FVFFT3XKQ6LR" = darwin.lib.darwinSystem rec {
          system = "aarch64-darwin";
          specialArgs.profiles = ["cvent"];

          modules = darwinModules ++ homeModules {
            profiles = specialArgs.profiles;
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN0l85pYmr5UV3FTMAQnmZYyv1wVNeKej4YnIP8sk5fW";
          };
        };
      };
    };
}