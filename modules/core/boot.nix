{
  pkgs,
  ...
}:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;

    kernelParams = [
      "quiet"
      "splash"
      "udev.log_level=3"
      "boot.shell_on_fail"
      "lsm=landlock,lockdown,yama,integrity,apparmor,bpf"
    ];

    consoleLogLevel = 0;

    initrd = {
      enable = true;
      systemd.enable = true;
    };

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
      # theme = "circle_hud";
      # themePackages = [
      #   (pkgs.adi1090x-plymouth-themes.override {
      #     selected_themes = [ "circle_hud" ];
      #   })
      # ];
    };
  };

  environment.systemPackages = [ pkgs.efibootmgr ];
}
