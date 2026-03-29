{
  self,
  lib,
  ...
}:
{
  sops.secrets = {
    gdrive_client_id = {
      sopsFile = self + "/secrets/shared/rclone.yaml";
      key = "gdrive/client_id";
      group = "secrets";
      mode = "0440";
    };
    gdrive_client_secret = {
      sopsFile = self + "/secrets/shared/rclone.yaml";
      key = "gdrive/client_secret";
      group = "secrets";
      mode = "0440";
    };
    gdrive_token = {
      sopsFile = self + "/secrets/shared/rclone.yaml";
      key = "gdrive/token";
      group = "secrets";
      mode = "0440";
    };
  };

  home-manager.sharedModules = lib.singleton ({ config, osConfig, ... }: {
    programs.rclone = {
      enable = true;

      remotes."gdrive" = {
        config = {
          type = "drive";
          scope = "drive";
        };
        secrets = {
          client_id     = osConfig.sops.secrets.gdrive_client_id.path;
          client_secret = osConfig.sops.secrets.gdrive_client_secret.path;
          token         = osConfig.sops.secrets.gdrive_token.path;
        };
        mounts."" = {
          enable     = true;
          mountPoint = "${config.home.homeDirectory}/GoogleDrive";
          logLevel   = "NOTICE";
          options = {
            vfs-cache-mode     = "full";
            vfs-cache-max-size = "10G";
            vfs-cache-max-age  = "24h";
            poll-interval      = "30s";
            dir-cache-time     = "5m";
            buffer-size        = "32M";
            transfers          = 8;
            read-only          = false;
            allow-other        = false;
          };
        };
      };
    };
  });
}