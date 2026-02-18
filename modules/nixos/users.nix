{
  lib,
  config,
  ...
}:
let
  cfg = config.sapphire.nixos.users;
in
{
  options.sapphire.nixos.users = lib.mkOption {
    type =
      with lib.types;
      attrsOf (submodule {
        options = {
          isAdmin = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether the user is system administrator or not";
            example = true;
          };
          description = lib.mkOption {
            type = lib.types.str;
            description = "Description of the user, typically the full name";
            example = "Primary User";
          };
          hashedPassword = lib.mkOption {
            type = lib.types.str;
            description = "Specify the hashed password generated using `mkpasswd -m sha-512`";
            example = "$6$VBp1lzQj3d3ZB3NX$IIwpk9jp3gWwOhcA1.m2uCgSw5knMAWiD09qYWyYMbQnA3sTGrMxl4nEODwld7Wb93c2mYA3kSMvytG.7QzXC.";
          };
          extraGroups = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Extra user groups";
          };
        };
      });
    default = { };
    description = "User config";
  };

  config = {
    sapphire.nixos.storage.impermanence.users.shared = {
      dirs = [
        "@dataHome/Trash"
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"
      ];
    };

    users.mutableUsers = false;
    users.users = lib.mapAttrs (_: userCfg: {
      isNormalUser = true;
      inherit (userCfg) description hashedPassword;
      extraGroups = userCfg.extraGroups ++ lib.optional userCfg.isAdmin "wheel";
    }) cfg;

    security.sudo.extraConfig = ''
      Defaults lecture=never
      Defaults timestamp_timeout=30
    '';

    home-manager.users = lib.mapAttrs (user: _userCfg: {
      home = {
        username = user;
        homeDirectory = "/home/${user}";
        inherit (config.sapphire.nixos.system) stateVersion; # TODO: do smth abt it
      };
    }) cfg;
  };
}
