{
  lib,
  config,
  ...
}:
let
  cfg = config.sapphire.nixos.users;

  mkCommonOptions = {
    extraPersistentDirs = lib.mkOption {
      type =
        with lib.types;
        listOf (oneOf [
          str
          attrs
        ]);
      default = [ ];
      description = lib.literalMD ''
        Per-user directories to persist. Supports XDG variable substitution:
        - `@configHome` → XDG_CONFIG_HOME (default: `~/.config`)
        - `@dataHome` → XDG_DATA_HOME (default: `~/.local/share`)
        - `@cacheHome` → XDG_CACHE_HOME (default: `~/.cache`)
        - `@stateHome` → XDG_STATE_HOME (default: `~/.local/state`)

        Example: `"@configHome/nvim"` expands to `~/.config/nvim`
      '';
      example = lib.literalExpression ''
        [
          "@dataHome/direnv"
          {
            directory = ".nixops";
            mode = "0700";
          }
        ]
      '';
    };
    extraPersistentFiles = lib.mkOption {
      type =
        with lib.types;
        listOf (oneOf [
          str
          attrs
        ]);
      default = [ ];
      description = lib.literalMD ''
        Per-user files to persist. Supports XDG variable substitution
        - `@configHome` → XDG_CONFIG_HOME (default: `~/.config`)
        - `@dataHome` → XDG_DATA_HOME (default: `~/.local/share`)
        - `@cacheHome` → XDG_CACHE_HOME (default: `~/.cache`)
        - `@stateHome` → XDG_STATE_HOME (default: `~/.local/state`)

        Example: `"@configHome/nvim"` expands to `~/.config/nvim`
      '';
      example = lib.literalExpression ''[ ".screenrc" ]'';
    };
    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra user groups";
    };
  };
in
{
  options.sapphire.nixos.users = lib.mkOption {
    type = lib.types.submodule {
      options = {
        shared = lib.mkOption {
          type = lib.types.submodule {
            options = mkCommonOptions;
          };
          default = { };
          description = "Shared user config";
        };
        perUser = lib.mkOption {
          type =
            with lib.types;
            attrsOf (submodule {
              options = mkCommonOptions // {
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
              };
            });
          default = { };
          description = "Per user config";
        };
      };
    };
    default = { };
    description = "User config";
  };

  config = {
    sapphire.nixos.storage.impermanence.perUser = lib.mapAttrs (_: userCfg: {
      dirs = [
        "@dataHome/Trash"
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"
      ]
      ++ cfg.shared.extraPersistentDirs
      ++ userCfg.extraPersistentDirs;
      files = cfg.shared.extraPersistentFiles ++ userCfg.extraPersistentFiles;
    }) cfg.perUser;

    users.mutableUsers = false;
    users.users = lib.mapAttrs (_: userCfg: {
      isNormalUser = true;
      inherit (userCfg) description hashedPassword;
      extraGroups = cfg.shared.extraGroups ++ userCfg.extraGroups ++ lib.optional userCfg.isAdmin "wheel";
    }) cfg.perUser;

    home-manager.users = lib.mapAttrs (user: _userCfg: {
      home = {
        username = user;
        homeDirectory = "/home/${user}";
        inherit (config.sapphire.nixos.system) stateVersion; # TODO: do smth abt it
      };
    }) cfg.perUser;
  };
}
