{
  config,
  lib,
  specs,
  ...
}:
let
  targetUrl = "coder.${specs.services.cloudflare-tunnel.domainName}";
in
{
  config = lib.mkIf specs.services.cloudflare-tunnel.enableCoder {
    warnings = lib.optional (!specs.services.docker.enable) 
      "Warning: You have enabled coder service without docker enabled. You can't create containers on the dashboard";
    
    services.coder = {
      enable = true;
      listenAddress = "localhost:3000";
      accessUrl = "https://${targetUrl}";
      wildcardAccessUrl = "*.${targetUrl}";
    };

    sapphire.storage.impermanence.system.dirs = [
      { directory = "/var/lib/coder"; user = "coder"; group = "coder"; mode = "u=rwx,g=rwx,o="; }
    ];

    users.users."coder".extraGroups = [ "docker" ];
    users.groups."coder".members = builtins.attrNames specs.core.users;

    services.caddy.virtualHosts."http://${targetUrl}".extraConfig = ''
      reverse_proxy ${config.services.coder.listenAddress} {
        transport http {
          keepalive 30s
          keepalive_idle_conns 10
        }
        header_up Host {host}
        header_up X-Real-IP {remote_host}
        header_up X-Forwarded-For {remote_host}
        header_up X-Forwarded-Proto {scheme}
      }
    '';
  };
}