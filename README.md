# airspy_adsb

airspy_adsb v2.2-RC31

Nix package and module for airspy_adsb. Because who doesn't love tracking planes? It's like birdwatching, but more metal.

## Usage

### As a Nix Package

To build and run `airspy_adsb` directly as a Nix package, you can use:

```bash
nix build .#airspy_adsb
./result/bin/airspy_adsb -h 
```

### As a NixOS Module

For a more permanent installation, you can enable the `airspy_adsb` module in your NixOS configuration.

Add the following to your `configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  imports = [
    github:fejiso/airspy_adsb/module.nix
  ];

  services.airspy_adsb = {
    enable = true;
    
  };

  # Don't forget to rebuild and switch!
  # sudo nixos-rebuild switch
}
```

After rebuilding your system, `airspy_adsb` will be soaring through your system, collecting data like a diligent flight attendant collects boarding passes.

## NixOS Module Options

Here are the configurable options for the `airspy_adsb` NixOS module, found under `services.airspy-adsb`:

- `enable`: Enable airspy_adsb service. (Type: boolean, Default: false)
- `serial`: Device serial number. (Type: string or null, Default: null)
- `timeout`: Aircraft timeout in seconds. (Type: integer or null, Default: null)
- `gain`: RF gain: 0..21 or auto. (Type: integer, "auto", or null, Default: null)
- `fecBits`: Forward Error Correction (FEC) bits. (Type: integer or null, Default: null)
- `preambleFilter`: Preamble filter: 1..60. (Type: integer or null, Default: null)
- `cpuTarget`: CPU processing time target (percentage): 5..95. (Type: integer or null, Default: null)
- `maxPreambleFilter`: Maximum preamble filter when using CPU target 1..60. (Type: integer or null, Default: null)
- `nonCrcPreambleFilter`: non-CRC Preamble filter: 1..preamble_filter. (Type: integer or null, Default: null)
- `whitelistThreshold`: Whitelist threshold: 1..20. (Type: integer or null, Default: null)
- `clients`: List of push clients to connect to. (Type: list of submodules, Default: [])
  - `host`: Hostname or IP address of the client. (Type: string)
  - `port`: Port number of the client. (Type: port)
  - `format`: Output format. (Type: enum ["AVR" "AVR-STRICT" "ASAVR" "Beast"], Default: "Beast")
- `listeners`: List of listeners to create. (Type: list of submodules, Default: [])
  - `port`: Port number for the listener. (Type: port)
  - `format`: Output format. (Type: enum ["AVR" "AVR-STRICT" "ASAVR" "Beast"], Default: "Beast")
- `mlatFrequency`: MLAT frequency in MHz: 12, 20 or 24 (Airspy R2 only). (Type: enum [12 20 24] or null, Default: null)
- `verbatim`: Enable Verbatim mode. (Type: boolean, Default: false)
- `dxMode`: Enable DX mode. (Type: boolean, Default: false)
- `reduceIF`: Reduce the IF bandwidth to 4 MHz. (Type: boolean, Default: false)
- `rssiMode`: RSSI mode: snr (ref = 42 dB), rms. (Type: enum ["snr" "rms"] or null, Default: null)
- `ignoreDfTypes`: Ignore these DF types (e.g. [24 25 26 27 28 29 30 31]). (Type: list of integers, "none", or null, Default: null)
- `biasTee`: Enable Bias-Tee. (Type: boolean, Default: false)
- `bitPacking`: Enable Bit Packing. (Type: boolean, Default: false)
- `verbose`: Verbose mode. (Type: boolean, Default: false)

## Contributing

Contributions are welcome!
