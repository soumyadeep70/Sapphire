{
  inputs,
  config,
  lib,
  ...
}:
let
  cfg = config.sapphire.desktop.niri.settings;
in
{
  options.sapphire.desktop.niri.settings = {
    monitors = lib.mkOption {
      type =
        with lib.types;
        attrsOf (submodule {
          options =
            { name, ... }:
            {
              identifier = lib.mkOption {
                type = lib.types.str;
                default = name;
                description = ''
                  connector name (eg. HDMI-A-1) or monitor manufacturer,
                  model, and serial, separated by a single space each
                  (eg. BNQ BenQ GW2790 S1R0259701Q).
                  Defaults to the attribute key name
                '';
                example = "eDP-1";
              };
              mode = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    width = lib.mkOption {
                      type = lib.types.int;
                      description = "Pixel width of the monitor";
                    };
                    height = lib.mkOption {
                      type = lib.types.int;
                      description = "Pixel height of the monitor";
                    };
                    refresh = lib.mkOption {
                      type = lib.types.float;
                      description = "Refresh rate of the monitor";
                    };
                  };
                };
                description = "monitor mode";
              };
              scale = lib.mkOption {
                type = lib.types.float;
                default = 1.0;
                description = "monitor resolution scaling";
                example = "1.5";
              };
              transform = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    flipped = lib.mkOption {
                      type = lib.types.bool;
                      default = false;
                      description = "Whether  to flip the output";
                      example = true;
                    };
                    rotation = lib.mkOption {
                      type = lib.types.enum [
                        0
                        90
                        180
                        270
                      ];
                      default = 0;
                      description = "Counter-clockwise rotation of this output in degrees";
                      example = 270;
                    };
                  };
                };
                default = { };
                description = "monitor output transform";
              };
              position = lib.mkOption {
                type =
                  with lib.types;
                  nullOr (submodule {
                    options = {
                      x = lib.mkOption {
                        type = lib.types.int;
                        description = "the x co-ordinate";
                      };
                      y = lib.mkOption {
                        type = lib.types.int;
                        description = "the y co-ordinate";
                      };
                    };
                  });
                default = null;
                description = "Position of the output in the global coordinate space";
              };
            };
        });
      default = { };
      description = "monitor config";
    };
  };

  config = lib.mkIf config.sapphire.desktop.niri.enable {
    home-manager.sharedModules = lib.singleton {
      imports = [
        inputs.niri-flake.homeModules.niri
      ];

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
        }) cfg.monitors;

        layout = {
          gaps = 16;
          center-focused-column = "never";
          background-color = "#1a1b26";

          preset-column-widths = [
            { proportion = 0.33333; }
            { proportion = 0.5; }
            { proportion = 0.66667; }
          ];

          default-column-width = {
            proportion = 0.5;
          };

          focus-ring = {
            enable = true;
            width = 4;

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
          "Mod+T".action.spawn = "ghostty";
          # "Mod+Alt+Return".action.spawn = "~/.config/niri/scripts/dev";
          # "Mod+Alt+V".action.spawn = [ "dms" "ipc" "call" "clipboard" "toggle" ];
          # "Mod+N".action.spawn = [ "dms" "ipc" "call" "notifications" "toggle" ];
          # "Mod+Space".action.spawn = [ "dms" "ipc" "call" "spotlight" "toggle" ];
          # "Mod+X".action.spawn = [ "dms" "ipc" "call" "powermenu" "toggle" ];
          # "Shift+Alt+S".action.screenshot-screen = { show-pointer = false; };
          # "Print".action.screenshot-screen = { show-pointer = false; };
          # "Mod+E".action.spawn = [ "nautilus" "--new-window" ];
          # "Mod+Z".action.spawn = "zen-browser";
          # "XF86Launch1".action.spawn = "rog-control-center";
          # "XF86Launch4".action.spawn = [ "asusctl" "profile" "--next" ];
          # "XF86Launch3".action.spawn = [ "dms" "ipc" "call" "mpris" "playPause" ];

          # "XF86AudioLowerVolume" = {
          #   allow-when-locked = true;
          #   action.spawn = [ "dms" "ipc" "call" "audio" "decrement" "3" ];
          # };
          # "XF86AudioMicMute" = {
          #   allow-when-locked = true;
          #   action.spawn = [ "dms" "ipc" "call" "audio" "micmute" ];
          # };
          # "XF86AudioMute" = {
          #   allow-when-locked = true;
          #   action.spawn = [ "dms" "ipc" "call" "audio" "mute" ];
          # };
          # "XF86AudioRaiseVolume" = {
          #   allow-when-locked = true;
          #   action.spawn = [ "dms" "ipc" "call" "audio" "increment" "3" ];
          # };
          # "XF86KbdBrightnessDown" = {
          #   allow-when-locked = true;
          #   action.spawn = [ "asusctl" "--prev-kbd-bright" ];
          # };
          # "XF86KbdBrightnessUp" = {
          #   allow-when-locked = true;
          #   action.spawn = [ "asusctl" "--next-kbd-bright" ];
          # };
          # "XF86MonBrightnessDown" = {
          #   allow-when-locked = true;
          #   action.spawn = [ "dms" "ipc" "call" "brightness" "decrement" "5" "amdgpu_bl1" ];
          # };
          # "XF86MonBrightnessUp" = {
          #   allow-when-locked = true;
          #   action.spawn = [ "dms" "ipc" "call" "brightness" "increment" "5" "amdgpu_bl1" ];
          # };

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

          "Mod+Comma".action.consume-or-expel-window-left = [ ];
          "Mod+Period".action.consume-or-expel-window-right = [ ];

          "Mod+R".action.switch-preset-column-width = [ ];
          "Mod+M".action.maximize-column = [ ];
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
              { app-id = "zen"; }
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
