# Noname's NixOS Flake

## Usage

- fill in `./hosts/modules/secret.nix`
- run `git add -N -f ./hosts/modules/secret.nix`
- run `sudo nixos-rebuild switch --flake .#nixos`
