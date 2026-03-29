{
  lib,
  pkgs,
  ...
}:
{
  home-manager.sharedModules = lib.singleton {
    programs.firefox = {
      enable = true;
      nativeMessagingHosts = [
        pkgs.keepassxc
      ];

      policies = {
        DisableTelemetry = true;
        DisablePocket = true;
        DisableFirefoxStudies = true;
        DontCheckDefaultBrowser = true;
        PasswordManagerEnabled = false;
        HardwareAcceleration = true;
        DevToolsEnabled = true;
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          };
          "keepassxc-browser@keepassxc.org" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
          };
        };
      };

      profiles = {
        dev = {
          id = 0;
          isDefault = true;
          settings = {
            "browser.aboutwelcome.enabled" = false;
            "startup.homepage_welcome_url" = "";
            "startup.homepage_welcome_url.additional" = "";
            "browser.startup.homepage_override.mstone" = "ignore";
            "browser.startup.page" = 3;
            "browser.contentblocking.category" = "strict";
            "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
            "media.av1.enabled" = false;  # TODO: enable for latst cpus
            "browser.newtabpage.pinned" = [
              {
                title = "NixOS";
                url = "https://nixos.org";
              }
              {
                title = "Codeforces";
                url = "https://codeforces.com";
              }
            ];
          };
          search = {
            default = "google";
            privateDefault = "ddg";
            force = true;
          };
          # TODO: theme integration with materialfox and dms
        };
      };
    };
    home.sessionVariables.BROWSER = "firefox";
    xdg.mimeApps.defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
    };
  };
  sapphire.storage.impermanence.users.shared.dirs = [
    ".mozilla"
  ];
}