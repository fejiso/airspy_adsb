{
  description = "NixOS flake for airspy_adsb";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    packages.${nixpkgs.system}.airspy-adsb = let
      # Define the download URLs and their SHA256 hashes for different architectures
      # YOU MUST UPDATE THESE VALUES BASED ON THE LATEST DOWNLOADS AND YOUR ARCHITECTURE!
      airspyDownloads = {
        "x86_64-linux" = {
          url = "https://airspy.com/?ddownload=3758";
          sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # REPLACE THIS WITH THE ACTUAL SHA256 FOR x86_64
        };
        "aarch64-linux" = {
          url = "https://airspy.com/?ddownload=5793";
          sha256 = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="; # REPLACE THIS WITH THE ACTUAL SHA256 FOR aarch64
        };
        "armv7l-linux" = { # Common for Raspberry Pi 3/4
          url = "https://airspy.com/?ddownload=3753";
          sha256 = "sha256-CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC="; # REPLACE THIS WITH THE ACTUAL SHA256 FOR armv7l
        };
        # Add other architectures if needed, e.g., "i686-linux"
      };

      # Select the correct download based on the current system
      airspyBinary = airspyDownloads.${nixpkgs.system} or (throw "Unsupported system architecture: ${nixpkgs.system}");

    in nixpkgs.legacyPackages.${nixpkgs.system}.stdenv.mkDerivation {
      pname = "airspy-adsb";
      version = "latest"; # You might want to hardcode a version like "2.3.4" if available

      src = nixpkgs.legacyPackages.${nixpkgs.system}.fetchurl {
        inherit (airspyBinary) url sha256;
      };

      # The downloaded file is a tar.gz, so we need to unpack it.
      # It typically contains a single binary named 'airspy_adsb'.
      sourceRoot = "."; # The tarball usually extracts into the current directory
      unpackCmd = "tar xzf $src"; # Specify the unpack command explicitly if default fails

      installPhase = ''
        mkdir -p $out/bin
        mv airspy_adsb $out/bin/
        # Make sure the binary is executable
        chmod +x $out/bin/airspy_adsb
      '';

      # Add any necessary runtime dependencies.
      # Airspy devices typically need libusb.
      buildInputs = [ nixpkgs.legacyPackages.${nixpkgs.system}.libusb1 ];
      # You might also need other libraries depending on the exact build of airspy_adsb,
      # e.g., librtlsdr, libairspy. Check the official Airspy installation instructions for dependencies.
      # If you get missing shared library errors, add them here.
    };

    nixosModules.airspy-adsb = { config, lib, pkgs, ... }: with lib; {
      options.services.airspy-adsb = {
        enable = mkEnableOption "airspy_adsb service";
        deviceSerial = mkOption {
          type = types.str;
          default = "";
          description = ''
            Optional: Specify the serial number of the Airspy device if you have multiple.
            Leave empty for automatic detection if only one device is connected.
          '';
        };
        args = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "Additional arguments to pass to airspy_adsb.";
          example = [ "-g" "21" "-p" "-w" "5" ];
        };
      };

      config = mkIf config.services.airspy-adsb.enable {
        # Use the package defined within this flake
        systemd.services.airspy-adsb = {
          description = "Airspy ADS-B Receiver";
          documentation = [ "https://airspy.com/download/" ];
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          serviceConfig = {
            ExecStart = let
              deviceArg = if config.services.airspy-adsb.deviceSerial != ""
                          then [ "-s" config.services.airspy-adsb.deviceSerial ]
                          else [ ];
            in "${self.packages.${pkgs.system}.airspy-adsb}/bin/airspy_adsb ${escapeShellArgs (deviceArg ++ config.services.airspy-adsb.args)}";
            Restart = "on-failure";
            RestartSec = 5;
            User = "airspy-adsb";
            Group = "airspy-adsb";
            # Ensure the service user has proper permissions to access USB devices
            # This is crucial. If you run into "permission denied", this is likely why.
            # You might need to adjust udev rules or add the 'airspy-adsb' user to a group like 'plugdev'
            # See the configuration.nix example below for hints.
          };
        };

        users.users.airspy-adsb = {
          isSystemUser = true;
          group = "airspy-adsb";
          # Add the user to a group that has access to USB devices if necessary.
          # For example, on many systems:
          # extraGroups = [ "plugdev" ];
        };

        users.groups.airspy-adsb = {};

        # Add udev rules if needed for device access.
        # This is highly recommended for persistent permissions.
        # Example rule (you'll need to find your device's Vendor ID and Product ID):
        # services.udev.extraRules = ''
        #   ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="60a7", MODE="0660", GROUP="airspy-adsb"
        # '';
        # Find idVendor and idProduct with `lsusb -v` when the Airspy is plugged in.
        # The MODE and GROUP grant permissions specifically to the `airspy-adsb` group.
      };
    };
  };
}
