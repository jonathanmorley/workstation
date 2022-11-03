{
  description = "Jonathan's darwin system";

  inputs = {
    # Package sets
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-21.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # System management
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # User management
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, darwin, home-manager, ... }: {
    darwinConfigurations."FVFFT3XKQ6LR" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        # `nix-darwin` config
        ./darwin-configuration.nix

        # `home-manager` module
        home-manager.darwinModules.home-manager
        {
          # `home-manager` config
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.jonathan = import ./home.nix;
        }
      ];
    };
 };
}