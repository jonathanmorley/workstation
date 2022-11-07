# Workstation

> Bootstrap a workstation

## Setup (MacOS)

1. Install [nix](https://nixos.org/download.html)
2. Install [nix-darwin](https://github.com/LnL7/nix-darwin#manual-install)
```
# Add the `/run` directory
echo -e "run\tprivate/var/run" | sudo tee -a /etc/synthetic.conf
/System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t

# Add the nix-darwin channel
nix-channel --add https://github.com/LnL7/nix-darwin/archive/master.tar.gz darwin
nix-channel --update
```
3. Clone and open the repository
```
git clone https://github.com/jonathanmorley/nixpkgs.git ~/.nixpkgs
cd ~/.nixpkgs
```
4. Bootstrap `nix build --extra-experimental-features 'nix-command flakes' .#darwinConfigurations.bootstrap-x86.system`
5. Add host to config file
6. Run `./result/sw/bin/darwin-rebuild switch --flake ~/.nixpkgs`

## Resources

- https://gist.github.com/jmatsushita/5c50ef14b4b96cb24ae5268dab613050
- https://github.com/malob/nixpkgs
