{
  description = "A Nix flake for airspy_adsb.nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.airspy-adsb = nixpkgs.legacyPackages.x86_64-linux.callPackage ./package.nix { };
    defaultPackage.x86_64-linux = self.packages.x86_64-linux.airspy-adsb;

    nixosModules.airspy-adsb = import ./modules/module.nix;
  };
}