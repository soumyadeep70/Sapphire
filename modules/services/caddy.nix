{
  lib,
  specs,
  ...
}:
{
  config = lib.mkIf specs.services.caddy.enable {
    services.caddy.enable = true;

    networking.firewall.allowedTCPPorts = [ 80 443 ];
    sapphire.storage.impermanence.system.dirs = [
      { directory = "/var/lib/caddy"; user = "caddy"; group = "caddy"; mode = "u=rwx,g=rx,o="; }
    ];
  };
}