{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.sapphire.nixos.hardware;
in
{
  options.sapphire.nixos.hardware = {
    enableAllFirmware = lib.mkEnableOption "all firmwares";
    enableFwupd = lib.mkEnableOption "fwupd (firmware updater)";
    enableGraphicsDrivers = lib.mkEnableOption "graphics support (opengl/ vulkan)";
    enableBluetooth = lib.mkEnableOption "bluetooth";
    enableMultimedia = lib.mkEnableOption "audio, screen capture/ recording";
    enableUtils = lib.mkEnableOption "some hardware utilities (e.g. ddcutil)";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enableAllFirmware {
      hardware.enableAllFirmware = true;
    })
    (lib.mkIf cfg.enableFwupd {
      services.fwupd.enable = true;

      sapphire.nixos.system = {
        extraPersistentDirs = [
          "/var/lib/fwupd/gnupg"
          "/var/lib/fwupd/metadata"
          "/var/lib/fwupd/pki"
        ];
        extraPersistentFiles = [
          "/var/lib/fwupd/pending.db"
        ];
      };
    })
    (lib.mkIf cfg.enableGraphicsDrivers {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    })
    (lib.mkIf cfg.enableBluetooth {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = false;
      };
      services.blueman.enable = true;
    })
    (lib.mkIf cfg.enableMultimedia {
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
        wireplumber.enable = true;
      };
      services.pulseaudio.enable = lib.mkForce false;
      sapphire.nixos.users.shared.extraPersistentDirs = [
        "@stateHome/wireplumber"
      ];
    })
    (lib.mkIf cfg.enableUtils {
      hardware.i2c.enable = true;
      environment.systemPackages = [ pkgs.ddcutil ];
      # TODO: add users "i2c" group if required
    })
  ];
}
