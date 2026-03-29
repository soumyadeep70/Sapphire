{
  lib,
  config,
  pkgs,
  ...
}:
{
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

    plymouth = {
      enable = true;
      theme = "circle_hud";
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override {
          selected_themes = [ "circle_hud" ];
        })
      ];
    };
  };

  environment.systemPackages = [ pkgs.efibootmgr ];
}
