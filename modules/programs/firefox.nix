{
  lib,
  pkgs,
  ...
}:
let 
  materialfox = pkgs.buildNpmPackage {
    pname = "materialfox";
    version = "latest";

    src = pkgs.fetchFromGitHub {
      owner = "soumyadeep70";
      repo = "material-fox-updated";
      rev = "main";
      sha256 = "sha256-l77Unw1sRLDkQWJEhs61uTZCAuPIVdiZ+S5pi+VAepc=";
    };

    npmDepsHash = "sha256-XfyQ9rasl54dd9qh1wThIMe2esm2PHPMc/Lbfv/d+7A=";

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r chrome/* $out/
      runHook postInstall
    '';
  };
in
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
            "startup.homepage_welcome_url" = "";
            "startup.homepage_welcome_url.additional" = "";
            "browser.aboutwelcome.enabled" = false;
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
            "toolkit.legacyuserprofilecustomizations.stylesheets" = true;
            "svg.context-properties.content.enabled" = true;
          };
          search = {
            default = "google";
            privateDefault = "ddg";
            force = true;
          };
        };
      };
    };
    home.file.".mozilla/firefox/dev/chrome" = {
      source = materialfox;
      recursive = true;
      force = true;
    };

    home.sessionVariables.BROWSER = "firefox";
    xdg.mimeApps.defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
    };
  };

  security.apparmor.policies.firefox = {
    state = "complain";

    profile = ''
      alias /etc/profiles/per-user/*/bin/firefox -> ${lib.getExe pkgs.firefox},
      alias /run/current-system/sw/bin/firefox -> ${lib.getExe pkgs.firefox},

      profile firefox ${lib.getExe pkgs.firefox} {
        owner /home/*/.mozilla/** rwk,
        owner /home/*/Downloads/** rw,
      }
    '';
  };

  sapphire.storage.impermanence.users.shared.dirs = [
    ".mozilla"
  ];
}