{
  config,
  lib,
  self,
  specs,
  ...
}:
let
  inherit (specs.services.cloudflare-tunnel) tunnelName;
in
{
  imports = [
    ./coder.nix
  ];

  config = lib.mkIf specs.services.cloudflare-tunnel.enable {
    assertions = lib.singleton {
      assertion = specs.services.caddy.enable;
      message = "Caddy must be enabled to use cloudflare tunnel, because it is used as a reverse proxy";
    };
    sops.secrets = {
      certificate = {
        sopsFile = self + "/secrets/shared/cloudflared.yaml";
        key = "cert_pem";
        group = "secrets";
        mode = "0440";
      };
      credential = {
        sopsFile = self + "/secrets/shared/cloudflared.yaml";
        key = "credential/${tunnelName}";
        group = "secrets";
        mode = "0440";
      };
    };

    services.cloudflared = {
      enable = true;
      certificateFile = config.sops.secrets.certificate.path;
      tunnels = {
        ${tunnelName} = {
          credentialsFile = config.sops.secrets.credential.path;
          default = "http://localhost:80"; # forward everything to caddy
        };
      };
    };

    sapphire.storage.impermanence.system.dirs = [
      "/var/lib/cloudflared"
    ];
  };
}