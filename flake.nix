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

  outputs = { self, nixpkgs, darwin, home-manager, ... }:
    let
      inherit (darwin.lib) darwinSystem;

      primaryUserInfo = {
        username = "jonathan";
        fullName = "Jonathan Morley";
        email = "morley.jonathan@gmail.com";
      };

      # Modules shared by most `nix-darwin` personal configurations.
      darwinModules = [
        ./darwin-configuration.nix
        ./modules/darwin/users.nix
      ] ++ [
        # `home-manager` module
        home-manager.darwinModules.home-manager
          ({ config, ... }:
            {
              users.users.${config.users.primaryUser.username}.home = "/Users/${config.users.primaryUser.username}";
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${config.users.primaryUser.username} = import ./home.nix;
              home-manager.extraSpecialArgs = {
                users = config.users;
                ssh = {
                  signingProgram = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
                  identityAgent = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
                };
              };
            }
          )
      ];
    in
    {
      darwinConfigurations = rec {
        # Mininal configurations to bootstrap systems
        bootstrap-x86 = darwinSystem {
          system = "x86_64-darwin";
          modules = [ ./darwin-configuration.nix ];
        };

        bootstrap-arm = darwinSystem {
          system = "aarch64-darwin";
          modules = [ ./darwin-configuration.nix ];
        };

        # Config with small modifications needed/desired for CI with GitHub workflow
        githubCI = darwinSystem {
          system = "x86_64-darwin";
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

        # Work MacBook Air
        "FVFFT3XKQ6LR" = darwinSystem {
          system = "aarch64-darwin";

          modules = darwinModules ++ [
            ({ lib, ... }: {
              users.primaryUser = primaryUserInfo // {
                email = "jmorley@cvent.com";
                publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPBkddsoU1owq/A9W4CuaUY+cYA5otZ2ejivt6CbwSyi";
              };
            })
          ];
        };
      };
    };
}