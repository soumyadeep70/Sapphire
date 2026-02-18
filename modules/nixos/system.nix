{
  lib,
  config,
  ...
}:
let
  cfg = config.sapphire.nixos.system;
in
{
  options.sapphire.nixos.system = {
    hostName = lib.mkOption {
      type = lib.types.strMatching "^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$";
      default = "nixos";
      description = "The hostname of the system";
      example = "atlas";
    };
    machineId = lib.mkOption {
      type = lib.types.addCheck lib.types.str (
        v:
        let
          isLowerHex = (lib.match "^[0-9a-f]+$" v) != null;
          isLength = lib.stringLength v == 32;
        in
        isLowerHex && isLength
      );
      description = "The unique machine ID of the system, a single hexadecimal, 32-character, lowercase ID";
      example = "9471422d94d34bb8807903179fb35f11";
    };
    locale = lib.mkOption {
      type = lib.types.str;
      default = "en_US.UTF-8";
      description = "Define the locale";
      example = "bn_IN.UTF-8";
    };
    timeZone = lib.mkOption {
      type = lib.types.strMatching "^[A-Za-z]+(/[A-Za-z_]+)+$";
      default = "UTC";
      description = "Set the timezone";
      example = "Asia/Kolkata";
    };
    stateVersion = lib.mkOption {
      type = lib.types.strMatching "^[0-9]{2}\.[0-9]{2}$";
      description = "Nixos system stateversion. See `system.stateVersion` nixos option";
      example = "25.11";
    };
  };

  config = {
    networking = {
      inherit (cfg) hostName;
      hostId = lib.substring 0 8 cfg.machineId;
    };

    environment.etc.machine-id.text = cfg.machineId;

    time.timeZone = cfg.timeZone;

    i18n.defaultLocale = cfg.locale;
    i18n.extraLocaleSettings = {
      LC_ADDRESS = cfg.locale;
      LC_IDENTIFICATION = cfg.locale;
      LC_MEASUREMENT = cfg.locale;
      LC_MONETARY = cfg.locale;
      LC_NAME = cfg.locale;
      LC_NUMERIC = cfg.locale;
      LC_PAPER = cfg.locale;
      LC_TELEPHONE = cfg.locale;
      LC_TIME = cfg.locale;
      LC_COLLATE = cfg.locale;
    };

    sapphire.nixos.storage.impermanence.system = {
      dirs = [
        "/var/lib/nixos"
        "/var/lib/bluetooth"
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/timers"
        "/var/lib/systemd/timesync"
        "/var/lib/libvirt"
        "/var/lib/tpm2-tss"
      ];
      files = [
        "/var/lib/systemd/random-seed"
      ];
    };

    system = { inherit (cfg) stateVersion; };
  };
}
