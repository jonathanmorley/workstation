# Workstation

> Bootstrap a workstation

## Setup (MacOS)

1. Install [nix](https://nixos.org/download.html)
2. Install [nix-darwin](https://github.com/LnL7/nix-darwin#install)
3. Clone the repository to `~/.nixpkgs`: `git clone git@github.com:jonathanmorley/nixpkgs.git ~/.nixpkgs`
4. Rebuild: `darwin-rebuild switch --flake ~/.nixpkgs`
5. Check alias works (new terminal): `darwin-switch`

## Resources

- https://gist.github.com/jmatsushita/5c50ef14b4b96cb24ae5268dab613050
- https://github.com/malob/nixpkgs
