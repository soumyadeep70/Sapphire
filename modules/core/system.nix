{
  lib,
  config,
  specs,
  ...
}:
{
  networking = {
    inherit (specs.system) hostName;
    hostId = lib.substring 0 8 specs.system.machineId;
  };

  environment.etc.machine-id.text = specs.system.machineId;

  time.timeZone = specs.system.timeZone;

  i18n.defaultLocale = specs.system.locale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = specs.system.locale;
    LC_IDENTIFICATION = specs.system.locale;
    LC_MEASUREMENT = specs.system.locale;
    LC_MONETARY = specs.system.locale;
    LC_NAME = specs.system.locale;
    LC_NUMERIC = specs.system.locale;
    LC_PAPER = specs.system.locale;
    LC_TELEPHONE = specs.system.locale;
    LC_TIME = specs.system.locale;
    LC_COLLATE = specs.system.locale;
  };

  sapphire.storage.impermanence.system = {
    dirs = [
      "/var/lib/nixos"
      "/var/lib/bluetooth"
      "/var/lib/systemd/coredump"
      "/var/lib/systemd/timers"
      "/var/lib/systemd/timesync"
      "/var/lib/tpm2-tss"
    ];
    files = [
      "/var/lib/systemd/random-seed"
    ];
  };

  system = { inherit (specs.system) stateVersion; };
}
