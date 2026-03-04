{
  inputs',
  config,
  lib,
  ...
}:
{
  imports = [
    ./settings.nix
    ./flavors/dank-material-shell
    ./flavors/noctalia-shell
  ];

  options.sapphire.desktop.niri = {
    enable = lib.mkEnableOption "niri window manager";
    flavor = lib.mkOption {
      type = lib.types.enum [
        "dank-material-shell"
        "noctalia-shell"
      ];
      default = "dank-material-shell";
      description = "Which desktop flavour to use";
    };
  };

  config = lib.mkIf config.sapphire.desktop.niri.enable {
    # TODO: move these deps
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;

    environment.sessionVariables = {
      CLUTTER_BACKEND = "wayland";
      GDK_BACKEND = "wayland,x11,*";
      GDK_DPI_SCALE = "1";
      GDK_SCALE = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_QPA_PLATFORMTHEME = "gtk3";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      SDL_VIDEODRIVER = "wayland";
      GSK_RENDERER = "ngl";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      WLR_NO_HARDWARE_CURSORS = "1";
      DMS_DISABLE_MATUGEN = "1";
      QT_MEDIA_BACKEND = "ffmpeg";
      QT_FFMPEG_DECODING_HW_DEVICE_TYPES = "vaapi"; # Alternatives: drm, qsv, cuda,
      QT_FFMPEG_ENCODING_HW_DEVICE_TYPES = "vaapi"; # vdpau, opencl, vulkan
    };

    nix.settings = {
      substituters = [
        "https://niri.cachix.org"
      ];
      trusted-public-keys = [
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      ];
    };

    # setting up niri
    environment.systemPackages = [
      inputs'.niri-flake.packages.niri-unstable
    ];
    services.displayManager.sessionPackages = [
      inputs'.niri-flake.packages.niri-unstable
    ];
  };
}
