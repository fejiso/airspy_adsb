{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.airspy-adsb;
  pkg = import ../package.nix { inherit pkgs; };

in
{
  options.services.airspy-adsb = {
    enable = mkEnableOption "airspy_adsb service";

    serial = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Device serial number.";
    };

    timeout = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "Aircraft timeout in seconds.";
    };

    gain = mkOption {
      type = types.nullOr (types.either types.int (types.enum ["auto"]));
      default = null;
      description = "RF gain: 0..21 or auto.";
    };

    fecBits = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "Forward Error Correction (FEC) bits.";
    };

    preambleFilter = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "Preamble filter: 1..60.";
    };

    cpuTarget = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "CPU processing time target (percentage): 5..95.";
    };

    maxPreambleFilter = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "Maximum preamble filter when using CPU target 1..60.";
    };

    nonCrcPreambleFilter = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "non-CRC Preamble filter: 1..preamble_filter.";
    };

    whitelistThreshold = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "Whitelist threshold: 1..20.";
    };

    clients = mkOption {
      type = types.listOf (types.submodule (
        {
          options = {
            host = mkOption { type = types.str; };
            port = mkOption { type = types.port; };
            format = mkOption {
              type = types.enum ["AVR" "AVR-STRICT" "ASAVR" "Beast"];
              default = "Beast";
            };
          };
        }
      ));
      default = [];
      description = "List of push clients to connect to.";
    };

    listeners = mkOption {
      type = types.listOf (types.submodule (
        {
          options = {
            port = mkOption { type = types.port; };
            format = mkOption {
              type = types.enum ["AVR" "AVR-STRICT" "ASAVR" "Beast"];
              default = "Beast";
            };
          };
        }
      ));
      default = [];
      description = "List of listeners to create.";
    };

    mlatFrequency = mkOption {
      type = types.nullOr (types.enum [12 20 24]);
      default = null;
      description = "MLAT frequency in MHz: 12, 20 or 24 (Airspy R2 only).";
    };

    verbatim = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Verbatim mode.";
    };

    dxMode = mkOption {
      type = types.bool;
      default = false;
      description = "Enable DX mode.";
    };

    reduceIF = mkOption {
      type = types.bool;
      default = false;
      description = "Reduce the IF bandwidth to 4 MHz.";
    };

    rssiMode = mkOption {
      type = types.nullOr (types.enum ["snr" "rms"]);
      default = null;
      description = "RSSI mode: snr (ref = 42 dB), rms.";
    };

    ignoreDfTypes = mkOption {
      type = types.nullOr (types.either (types.enum ["none"]) (types.listOf types.int));
      default = null;
      description = ''Ignore these DF types (e.g. [24 25 26 27 28 29 30 31]).'';
    };

    biasTee = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Bias-Tee.";
    };

    bitPacking = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Bit Packing.";
    };

    verbose = mkOption {
      type = types.bool;
      default = false;
      description = "Verbose mode.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.airspy-adsb = {
      description = "Airspy ADS-B Receiver";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = let
          args =
            (optional (cfg.serial != null) "-s ${cfg.serial}") ++ 
            (optional (cfg.timeout != null) "-t ${toString cfg.timeout}") ++ 
            (optional (cfg.gain != null) "-g ${toString cfg.gain}") ++ 
            (optional (cfg.fecBits != null) "-f ${toString cfg.fecBits}") ++ 
            (optional (cfg.preambleFilter != null) "-e ${toString cfg.preambleFilter}") ++ 
            (optional (cfg.cpuTarget != null) "-C ${toString cfg.cpuTarget}") ++ 
            (optional (cfg.maxPreambleFilter != null) "-E ${toString cfg.maxPreambleFilter}") ++ 
            (optional (cfg.nonCrcPreambleFilter != null) "-P ${toString cfg.nonCrcPreambleFilter}") ++ 
            (optional (cfg.whitelistThreshold != null) "-w ${toString cfg.whitelistThreshold}") ++ 
            (map (client: "-c ${client.host}:${toString client.port}:${client.format}") cfg.clients) ++ 
            (map (listener: "-l ${toString listener.port}:${listener.format}") cfg.listeners) ++ 
            (optional (cfg.mlatFrequency != null) "-m ${toString cfg.mlatFrequency}") ++ 
            (optional cfg.verbatim "-n") ++ 
            (optional cfg.dxMode "-x") ++ 
            (optional cfg.reduceIF "-r") ++ 
            (optional (cfg.rssiMode != null) "-R ${cfg.rssiMode}") ++ 
            (optional (cfg.ignoreDfTypes != null) "-D ${if isList cfg.ignoreDfTypes then concatStringsSep "," (map toString cfg.ignoreDfTypes) else "none"}") ++ 
            (optional cfg.biasTee "-b") ++ 
            (optional cfg.bitPacking "-p") ++ 
            (optional cfg.verbose "-v");
        in "${pkg}/bin/airspy_adsb ${escapeShellArgs args}";
        Restart = "on-failure";
        RestartSec = 5;
        User = "airspy-adsb";
        Group = "airspy-adsb";
      };
    };

    users.users.airspy-adsb = {
      isSystemUser = true;
      group = "airspy-adsb";
    };

    users.groups.airspy-adsb = {};
  };
}
