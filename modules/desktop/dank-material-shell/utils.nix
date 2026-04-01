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
              common.default = [
                "gnome"
                "gtk"
              ];
              niri = {
                default = [
                  "gnome"
                  "gtk"
                ];
                "org.freedesktop.impl.portal.ScreenCast" = [
                  "gnome"
                ];
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
                common.default = [
                  "gnome"
                  "gtk"
                ];
                niri = {
                  default = [
                    "gnome"
                    "gtk"
                  ];
                  "org.freedesktop.impl.portal.ScreenCast" = [
                    "gnome"
                  ];
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
      # Gtk/ Qt themes
      {
        programs.dconf.enable = true;
        home-manager.sharedModules = lib.singleton {
          home.packages = with pkgs; [
            inter
            gnome-themes-extra
            papirus-icon-theme
            bibata-cursors
          ];
          qt = {
            enable = true;
            platformTheme.name = lib.mkForce "gtk3";
          };

          home.sessionVariables = {
            CLUTTER_BACKEND = "wayland";
            SDL_VIDEODRIVER = "wayland";
            GSK_RENDERER = "ngl";
            GDK_BACKEND = "wayland,x11,*";
            GDK_DPI_SCALE = "1";
            GDK_SCALE = "1";
            QT_AUTO_SCREEN_SCALE_FACTOR = "1";
            QT_QPA_PLATFORM = "wayland;xcb";
            QT_QPA_PLATFORMTHEME = "gtk3";
            QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
            QT_MEDIA_BACKEND = "ffmpeg";
            QT_FFMPEG_DECODING_HW_DEVICE_TYPES = "vaapi"; # Alternatives: drm, qsv, cuda,
            QT_FFMPEG_ENCODING_HW_DEVICE_TYPES = "vaapi"; # vdpau, opencl, vulkan
            ELECTRON_OZONE_PLATFORM_HINT = "auto";
          };

          programs.niri.settings.spawn-at-startup = lib.singleton (
            let
              dts = pkgs.writeShellApplication {
                name = "dynamic-theme-switcher";
                runtimeInputs = [ (pkgs.python3.withPackages (ps: with ps; [ pydbus pygobject3 ])) ];
                text = ''
                  export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk4}/share/gsettings-schemas/${pkgs.gtk4.name}:$XDG_DATA_DIRS"
                  export GIO_EXTRA_MODULES="${pkgs.dconf.lib}/lib/gio/modules:${pkgs.gvfs}/lib/gio/modules"

                  while true; do
                    echo "[dynamic-theme-switcher]: starting..."
                    python3 ${./dynamic-theme-switcher.py} || true
                    echo "[dynamic-theme-switcher]: restarting in 2s..."
                    sleep 2
                  done
                '';
              };
            in {
              sh = "${lib.getExe dts} 2>&1 | logger -t dynamic-theme-switcher";
            }
          );
        };
      }
      # TODO: configure other apps like media player, docs reader
    ]
  );
}
