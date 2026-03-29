{
  config,
  self,
  ...
}:
{
  sops.secrets.tailscale_auth_key = {
    sopsFile = self + "/secrets/phoenix/tailscale.yaml";
    key = "auth_key";
    group = "secrets";
    mode = "0440";
  };
  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.sops.secrets.tailscale_auth_key.path;
  };
}