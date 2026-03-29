{
  inputs,
  inputs',
  config,
  lib,
  specs,
  ...
}:
{
  config = lib.mkIf (specs.desktop.backend == "niri") {
    # TODO: move these deps
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;

    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
    };

    nix.settings = {
      substituters = [
        "https://niri.cachix.org"
      ];
      trusted-public-keys = [
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      ];
    };

    # install niri
    environment.systemPackages = [
      inputs'.niri-flake.packages.niri-unstable
    ];
    services.displayManager.sessionPackages = [
      inputs'.niri-flake.packages.niri-unstable
    ];

    # niri settings
    home-manager.sharedModules = lib.singleton {
      imports = [
        inputs.niri-flake.homeModules.config
        inputs.dank-material-shell.homeModules.niri
      ];

      programs.dank-material-shell.niri = {
        enableKeybinds = true;
        enableSpawn = true;
        includes.enable = false;
      };

      programs.niri.package = inputs'.niri-flake.packages.niri-unstable;

      programs.niri.settings = {
        input = {
          keyboard = {
            repeat-delay = 300;
            repeat-rate = 25;
            numlock = true;
          };

          mouse = {
            accel-profile = "adaptive";
            accel-speed = 0.2;
            scroll-button-lock = true;
          };

          # tablet, touch touchpad, trackball, trackpoint not configured

          workspace-auto-back-and-forth = true;
          warp-mouse-to-focus = {
            enable = true;
            mode = "center-xy";
          };
          focus-follows-mouse.enable = true;
        };

        outputs = lib.mapAttrs' (_: v: {
          name = v.identifier;
          value = {
            mode = {
              inherit (v.mode) width height refresh;
            };
            inherit (v) scale position;
            transform = {
              inherit (v.transform) flipped rotation;
            };
            variable-refresh-rate = "on-demand";
          };
        }) config.sapphire.desktop.settings.monitors;

        cursor = {
          theme = "Bibata-Modern-Ice";
          size = 24;
        };

        layout = {
          gaps = 16;
          center-focused-column = "never";
          background-color = "#1a1b26";

          preset-column-widths = [
            { proportion = 0.33333; }
            { proportion = 0.5; }
            { proportion = 0.66667; }
            { proportion = 1.0; }
          ];

          default-column-width = {
            proportion = 0.5;
          };

          focus-ring = {
            enable = true;
            width = 2;

            active = {
              gradient = {
                from = "#f00f";
                to = "#0f05";
                angle = 45;
                in' = "oklch longer hue";
                relative-to = "workspace-view";
              };
            };

            inactive = {
              color = "#ffffff00";
            };
          };

          border.enable = false;

          shadow = {
            enable = true;
            draw-behind-window = false;
            softness = 40;
            spread = 5;
            offset = {
              x = 0;
              y = 5;
            };
            color = "#0007";
          };
        };

        prefer-no-csd = true;

        overview = {
          backdrop-color = "#1a1b26";
          workspace-shadow = {
            enable = true;
            softness = 50;
            spread = 20;
            offset = {
              x = 0;
              y = 10;
            };
            color = "#0007";
          };
        };

        clipboard.disable-primary = true;
        config-notification.disable-failed = true;
        hotkey-overlay.skip-at-startup = true;

        binds = {
          "Mod+T".action.spawn = [ "ghostty" "+new-window" ];
          "Mod+Shift+S".action.spawn = [ "dms" "screenshot" ];
          "Print".action.spawn = [ "dms" "screenshot" "full" ];
          "Mod+E".action.spawn = [ "nautilus" "--new-window" ];

          "Mod+O" = {
            repeat = false;
            action.toggle-overview = [ ];
          };
          "Mod+Q" = {
            repeat = false;
            action.close-window = [ ];
          };

          "Mod+H".action.focus-column-left = [ ];
          "Mod+J".action.focus-window-or-workspace-down = [ ];
          "Mod+K".action.focus-window-or-workspace-up = [ ];
          "Mod+L".action.focus-column-right = [ ];

          "Mod+Alt+H".action.move-column-left = [ ];
          "Mod+Alt+J".action.move-window-down-or-to-workspace-down = [ ];
          "Mod+Alt+K".action.move-window-up-or-to-workspace-up = [ ];
          "Mod+Alt+L".action.move-column-right = [ ];

          "Mod+Left".action.focus-column-first = [ ];
          "Mod+Right".action.focus-column-last = [ ];
          "Mod+Alt+Left".action.move-column-to-first = [ ];
          "Mod+Alt+Right".action.move-column-to-last = [ ];

          "Mod+1".action.focus-workspace = 1;
          "Mod+2".action.focus-workspace = 2;
          "Mod+3".action.focus-workspace = 3;
          "Mod+4".action.focus-workspace = 4;
          "Mod+5".action.focus-workspace = 5;
          "Mod+6".action.focus-workspace = 6;
          "Mod+7".action.focus-workspace = 7;
          "Mod+8".action.focus-workspace = 8;
          "Mod+9".action.focus-workspace = 9;

          "Mod+Alt+1".action.move-column-to-workspace = 1;
          "Mod+Alt+2".action.move-column-to-workspace = 2;
          "Mod+Alt+3".action.move-column-to-workspace = 3;
          "Mod+Alt+4".action.move-column-to-workspace = 4;
          "Mod+Alt+5".action.move-column-to-workspace = 5;
          "Mod+Alt+6".action.move-column-to-workspace = 6;
          "Mod+Alt+7".action.move-column-to-workspace = 7;
          "Mod+Alt+8".action.move-column-to-workspace = 8;
          "Mod+Alt+9".action.move-column-to-workspace = 9;

          # "Mod+Comma".action.consume-or-expel-window-left = [ ];
          "Mod+Period".action.consume-or-expel-window-right = [ ];

          "Mod+R".action.switch-preset-column-width = [ ];
          # "Mod+M".action.maximize-column = [ ];
          "Mod+Alt+M".action.expand-column-to-available-width = [ ];
          "Mod+F".action.fullscreen-window = [ ];
          "Mod+C".action.center-column = [ ];
          "Mod+Alt+C".action.center-visible-columns = [ ];
          "Mod+Minus".action.set-column-width = "-10%";
          "Mod+Equal".action.set-column-width = "+10%";
          "Mod+Alt+Minus".action.set-window-height = "-10%";
          "Mod+Alt+Equal".action.set-window-height = "+10%";
          "Mod+Alt+F".action.toggle-window-floating = [ ];
          "Mod+Alt+T".action.switch-focus-between-floating-and-tiling = [ ];
          "Mod+W".action.toggle-column-tabbed-display = [ ];

          "Mod+Escape" = {
            allow-inhibiting = false;
            action.toggle-keyboard-shortcuts-inhibit = [ ];
          };
        };

        window-rules = [
          {
            geometry-corner-radius = {
              top-left = 8.0;
              top-right = 8.0;
              bottom-left = 8.0;
              bottom-right = 8.0;
            };
            clip-to-geometry = true;
            draw-border-with-background = false;
          }
          {
            matches = [
              { app-id = "firefox"; }
            ];
            open-maximized = true;
          }
          {
            matches = [
              {
                app-id = "firefox$";
                title = "^Picture-in-Picture$";
              }
              {
                app-id = "zen";
                title = "^Picture-in-Picture$";
              }
            ];
            open-floating = true;
            open-focused = false;
            default-floating-position = {
              x = 32;
              y = 32;
              relative-to = "bottom-right";
            };
            default-column-width = {
              proportion = 0.3;
            };
            default-window-height = {
              proportion = 0.3;
            };
          }
          {
            matches = [
              { app-id = "confirm"; }
              { app-id = "pavucontrol"; }
              { app-id = "blueman"; }
              { app-id = "nm-connection-editor"; }
              { app-id = "org.gnome.PowerStats"; }
              { app-id = "cpupower"; }
              { app-id = "jamesdsp"; }
              { app-id = "easyeffects"; }
              { app-id = "Hello"; }
              { app-id = "xdg-desktop-portal-gtk"; }
              { app-id = "system-config-printer"; }
              { app-id = "ghostty_journalctl"; }
              { title = ".*Extension.*Bitwarden.*"; }
              { app-id = "brave-keep"; }
            ];
            open-floating = true;
            default-column-width = {
              proportion = 0.45;
            };
            default-window-height = {
              proportion = 0.45;
            };
          }
        ];
      };
    };
  };
}
