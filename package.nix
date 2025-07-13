{ pkgs ? import <nixpkgs> {} }:

let
  airspyDownloads = {
    "x86_64-linux" = {
      url = "https://airspy.com/?ddownload=3758";
      sha256 = "0nwxnbrl65xi2dcinl1fsmzmcm5i804xqyp9zzp3k8ix15bwchcg";
    };
    "aarch64-linux" = {
      url = "https://airspy.com/?ddownload=5793";
      sha256 = "02a1g41wjad30cggkxlsgdpv1mj5pz1xvrr7xqipfyygdil2z7p8";
    };
    "armv7l-linux" = {
      url = "https://airspy.com/?ddownload=3753";
      sha256 = "130sd6i44w5d3hdrcry6x0n283np2xrrl006gh40f5nxmgfnmg7d";
    };
    "x86-linux" = { # This is likely i686-linux, but the flake used x86-linux
      url = "https://airspy.com/?ddownload=6063";
      sha256 = "1jjxvdmmcp925rf67lm9vn1qjybjyq9aq28xiajpss0nhnmlcpap";
    };
  };

  # The original flake used "x86-linux" which is not a standard Nix system string.
  # We'll map i686-linux to it for compatibility with traditional Nix.
  system = if pkgs.system == "i686-linux" then "x86-linux" else pkgs.system;

  airspyBinary = airspyDownloads.${system} or (throw "Unsupported system architecture: ${pkgs.system}");

in
pkgs.stdenv.mkDerivation {
  pname = "airspy-adsb";
  version = "latest";

  src = pkgs.fetchurl {
    inherit (airspyBinary) url sha256;
    name = "airspy_adsb.tgz";
  };

  sourceRoot = "source";
  unpackCmd = ''
    mkdir source
    cd source
    tar xzf $src
  '';

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    mv airspy_adsb $out/bin/
    chmod +x $out/bin/airspy_adsb
  '';

  buildInputs = [ pkgs.libusb1 ];
}
