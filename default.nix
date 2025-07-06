{ pkgs ? import <nixpkgs> {} }:

{
  packages.airspy-adsb = import ./package.nix { inherit pkgs; };
  nixosModules.airspy-adsb = import ./module.nix;
}