{
  inputs,
  lib,
  pkgs,
  specs,
  ...
}:
{
  imports = [
    inputs.dank-material-shell.nixosModules.greeter
  ];

  config = lib.mkIf (specs.desktop.variant == "dank-material-shell") (
    lib.mkMerge [
      # Display Manager
      {
        programs.dank-material-shell.greeter = {
          enable = true;
          compositor.name = specs.desktop.backend;
          # configFiles = [
          #   "${cfg.configHome}/.config/DankMaterialShell/settings.json"
          #   "${cfg.configHome}/.local/state/DankMaterialShell/session.json"
          #   "${cfg.configHome}/.cache/DankMaterialShell/dms-colors.json"
          # ];
          logs = {
            save = true;
            path = "/tmp/dms-greeter.log";
          };
        };
      }
      # XDG Spec
      {
        xdg = {
          autostart.enable = true;
          icons.enable = true;
          menus.enable = true;
          mime.enable = true;
          sounds.enable = true;
          portal = {
            enable = true;
            extraPortals = with pkgs; [
              xdg-desktop-portal-gtk
              xdg-desktop-portal-gnome
            ];
            config = {
              common.default = [ "gtk" "gnome" ];
              niri = {
                default = [ "gtk" "gnome" ];
                "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
                "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
              };
            };
          };
        };
        home-manager.sharedModules = lib.singleton {
          xdg = {
            enable = true;
            autostart.enable = true;
            mime.enable = true;
            mimeApps.enable = true;
            portal = {
              enable = true;
              extraPortals = with pkgs; [
                xdg-desktop-portal-gtk
                xdg-desktop-portal-gnome
              ];
              config = {
                common.default = [ "gtk" "gnome" ];
                niri = {
                  default = [ "gtk" "gnome" ];
                  "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
                  "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
                };
              };
            };
            userDirs = {
              enable = true;
              desktop = null;
              templates = null;
              createDirectories = true;
            };
          };
        };
      }
      # TODO: configure other apps like media player, docs reader
    ]
  );
}
