{
  lib,
  pkgs,
  ...
}:
{
  home-manager.sharedModules = lib.singleton ({ config, lib, ... }: {
    programs.keepassxc = {
      enable = true;
      autostart = true;
    };
    home.activation.initKeepassXC = lib.hm.dag.entryAfter ["writeBoundary"] (
      let
        keepassxcSettings = (pkgs.formats.ini {}).generate "keepassxc.ini" {
          General.ConfigVersion = 2;
          Browser.Enabled = true;
          FdoSecrets.Enabled = true;
          GUI = {
            ColorPasswords = true;
            Language = "en_US";
            MinimizeOnClose = true;
            MinimizeOnStartup = true;
            MovableToolbar = false;
            ShowTrayIcon = true;
            TrayIconAppearance = "colorful";
          };
          SSHAgent.Enabled = true;
        };
      in
      ''
        install -Dm644 ${keepassxcSettings} \
          "${config.xdg.configHome}/keepassxc/keepassxc.ini"
      ''
    );
  });
}