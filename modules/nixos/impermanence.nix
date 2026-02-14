{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.sapphire.nixos.impermanence;

  persistentVolume = config.sapphire.nixos.storage.mainDisk.subvolumes.persistent.mountpoint;

  mkPersistOptions =
    { dirsDesc, filesDesc }:
    {
      dirs = lib.mkOption {
        type =
          with lib.types;
          listOf (oneOf [
            str
            attrs
          ]);
        default = [ ];
        description = dirsDesc;
        internal = true;
      };

      files = lib.mkOption {
        type =
          with lib.types;
          listOf (oneOf [
            str
            attrs
          ]);
        default = [ ];
        description = filesDesc;
        internal = true;
      };
    };
in
{
  imports = [
    inputs.impermanence.nixosModules.default
  ];

  options.sapphire.nixos.impermanence = {
    enable = lib.mkEnableOption "Enable impermanence";

    system = lib.mkOption {
      type = lib.types.submodule {
        options = mkPersistOptions {
          dirsDesc = "System directories to persist";
          filesDesc = "System files to persist";
        };
      };
      default = { };
      description = "System persistence config";
      internal = true;
    };

    perUser = lib.mkOption {
      type =
        with lib.types;
        attrsOf (submodule {
          options = mkPersistOptions {
            dirsDesc = "per user directories to persist";
            filesDesc = "per user files to persist";
          };
        });
      default = { };
      description = "Per user persistence config";
      internal = true;
    };
  };

  config = lib.mkIf cfg.enable {
    fileSystems.${persistentVolume}.neededForBoot = true;

    environment.persistence.default = {
      enable = true;
      persistentStoragePath = "${persistentVolume}/system";
      hideMounts = true;
      allowTrash = true;
      enableWarnings = true;

      directories = cfg.system.dirs;
      inherit (cfg.system) files;
    };

    home-manager.users = lib.mapAttrs (
      _: userCfg:
      (
        { config, lib, ... }:
        let
          home = config.home.homeDirectory;

          toRel =
            path:
            let
              p = toString path;
            in
            if lib.hasPrefix "~/" p then
              lib.removePrefix "~/" p
            else if lib.hasPrefix "${home}/" p then
              lib.removePrefix "${home}/" p
            else
              throw "XDG path must be under home: ${path}";

          xdg = {
            config = toRel config.xdg.configHome;
            data = toRel config.xdg.dataHome;
            cache = toRel config.xdg.cacheHome;
            state = toRel config.xdg.stateHome;
          };

          replaceXDGVars =
            str:
            builtins.replaceStrings
              [ "@configHome" "@dataHome" "@cacheHome" "@stateHome" ]
              [ xdg.config xdg.data xdg.cache xdg.state ]
              str;

          normalize =
            entries:
            map (
              entry:
              if builtins.isString entry then
                replaceXDGVars entry
              else if builtins.isAttrs entry && lib.hasAttr "directory" entry then
                entry // { directory = replaceXDGVars entry.directory; }
              else if builtins.isAttrs entry && lib.hasAttr "file" entry then
                entry // { file = replaceXDGVars entry.file; }
              else
                throw "Invalid entry: expected string or attrset with `directory`/`file`"
            ) entries;
        in
        {
          home.persistence.default = {
            enable = true;
            persistentStoragePath = persistentVolume;
            hideMounts = true;
            allowTrash = true;
            enableWarnings = true;

            directories = normalize userCfg.dirs;
            files = normalize userCfg.files;
          };
        }
      )
    ) cfg.perUser;
  };
}
