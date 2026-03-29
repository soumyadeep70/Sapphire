{
  lib,
  pkgs,
  specs,
  ...
}:
{
  config = lib.mkMerge [
    # Firmwares
    {
      hardware.enableAllFirmware = true;
      services.fwupd.enable = true;
      sapphire.storage.impermanence.system = {
        dirs = [
          "/var/lib/fwupd/gnupg"
          "/var/lib/fwupd/metadata"
          "/var/lib/fwupd/pki"
        ];
        files = [
          "/var/lib/fwupd/pending.db"
        ];
      };
    }
    # Graphics Drivers
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      environment.systemPackages = with pkgs; [
        mission-center
      ];
    }
    # Bluetooth
    {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = false;
      };
    }
    # Multimedia (Audio, Screen Sharing)
    {
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
        wireplumber.enable = true;
      };
      services.pulseaudio.enable = lib.mkForce false;
      security.rtkit.enable = lib.mkDefault true;
      sapphire.storage.impermanence.users.shared.dirs = [
        "@stateHome/wireplumber"
      ];
    }
    # Printing
    {
      services.printing.enable = true;
    }
    # DDC/CI protocol
    {
      hardware.i2c.enable = true;
      environment.systemPackages = [ pkgs.ddcutil ];
      users.users = lib.genAttrs (builtins.attrNames specs.users) (_: {
        extraGroups = [ "i2c" ];
      });
    }
  ];
}
