{
  specs,
  ...
}:
{
  environment.etc.machine-id.text = specs.core.system.machineId;

  time.timeZone = specs.core.system.timeZone;

  i18n.defaultLocale = specs.core.system.locale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = specs.core.system.locale;
    LC_IDENTIFICATION = specs.core.system.locale;
    LC_MEASUREMENT = specs.core.system.locale;
    LC_MONETARY = specs.core.system.locale;
    LC_NAME = specs.core.system.locale;
    LC_NUMERIC = specs.core.system.locale;
    LC_PAPER = specs.core.system.locale;
    LC_TELEPHONE = specs.core.system.locale;
    LC_TIME = specs.core.system.locale;
    LC_COLLATE = specs.core.system.locale;
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

  system = { inherit (specs.core.system) stateVersion; };
}
