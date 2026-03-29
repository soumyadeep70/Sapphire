{
  lib,
  pkgs,
  ...
}:
{
  home-manager.sharedModules = lib.singleton {
    programs.firefoxpwa = {
      enable = true;

      profiles = {
        "01KMBX3H5609MW2B9SDQEFW98C" = {
          name = "personal";
          sites = {
            "01KMBX44429RR1ZM4C0H4JFAHS" = {
              name = "YouTube";
              url = "https://youtube.com";
              manifestUrl = "https://www.youtube.com/manifest.webmanifest";

              desktopEntry.icon = pkgs.fetchurl {
                url = "https://www.gstatic.com/youtube/img/branding/favicon/favicon_192x192_v2.png";
                sha256 = "sha256-Ngx9QctP6rxSmceeB9DlH3+RD5OBEiCl2Cond5Kz6TU=";
              };
            };
            "01KMEEC2T7P68Y200VXERPVZNZ" = {
              name = "WhatsApp";
              url = "https://web.whatsapp.com";
              manifestUrl = "https://web.whatsapp.com/manifest.json";

              desktopEntry.icon = pkgs.fetchurl {
                url = "https://upload.wikimedia.org/wikipedia/commons/6/6b/WhatsApp.svg";
                sha256 = "sha256-3WpNssOUyhGqirCHNp8vUKEub4dOSdt7HVYJ0Kj7KMo=";
              };
            };
          };
        };
      };
    };
  };
  sapphire.storage.impermanence.users.shared.dirs = [
    "@dataHome/firefoxpwa"
  ];
}