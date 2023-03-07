{
  description = "Jonathan's Configurations";

  inputs = {
    # NixPkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-21.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Nix Darwin
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Extra Packages
    rtx.url = "github:jonathanmorley/rtx/nix-macos";
    rtx.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, darwin, home-manager, rtx, ... }:
    let
      darwinModules = [./darwin.nix];
      homeModules = { profile, ... }: [
        home-manager.darwinModules.home-manager {
          nixpkgs.overlays = [ rtx.overlay ];
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit profile; };
          home-manager.users.jonathan = import ./home.nix;
        }
      ];
    in
    {
      darwinConfigurations = rec {
        # Work MacBook Air
        "FVFFT3XKQ6LR" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = darwinModules ++ homeModules { profile = "cvent"; };
        };
      };
    };
}