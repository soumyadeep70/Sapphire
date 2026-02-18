{
  lib,
  config,
  ...
}:
let
  cfg = config.sapphire.nixos.services.openssh;
in
{
  options.sapphire.nixos.services.openssh = {
    enable = lib.mkEnableOption "openssh config";
    perUserPublicKeys = lib.mkOption {
      type = with lib.types; attrsOf (listOf str);
      default = { };
      description = "Authorized public keys for user access";
      example = lib.literalExpression ''
        {
          bob = [
            "ssh-rsa AAAAB3NzaC1yc2etc/etc/etcjwrsh8e596z6J0l7 example@host"
            "ssh-ed25519 AAAAC3NzaCetcetera/etceteraJZMfk3QPfQ foo@bar"
          ];
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = lib.mapAttrsToList (name: _: {
      assertion = lib.hasAttr name config.sapphire.nixos.users;
      message = "impermanence: user ${name} not defined";
    }) cfg.perUserPublicKeys;

    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    users.users = lib.mapAttrs (_: pubKeys: {
      openssh.authorizedKeys.keys = pubKeys;
    }) cfg.perUserPublicKeys;

    sapphire.nixos.storage.impermanence.system.files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];

    sapphire.nixos.storage.impermanence.users.shared.dirs = [
      ".ssh"
    ];
  };
}
