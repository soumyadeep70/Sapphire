{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.sapphire.nixos.boot;
in
{
  options.sapphire.nixos.boot.enable = lib.mkEnableOption "boot config (systemd-boot)";

  config = lib.mkIf cfg.enable {
    boot = {
      initrd = {
        enable = true;
        systemd.enable = true;
      };

      kernelPackages = pkgs.linuxPackages_zen;

      loader = {
        timeout = 3;
        efi.canTouchEfiVariables = true;
        systemd-boot = {
          enable = true;
          configurationLimit = 10;
          memtest86.enable = true;
        };
      };
    };

    environment.systemPackages = [ pkgs.efibootmgr ];
  };
}
