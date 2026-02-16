{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.sapphire.nixos.storage;
in
{
  imports = [
    inputs.impermanence.nixosModules.default
  ];

  options.sapphire.nixos.storage =
    let
      mkPersistenceOptions =
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
      impermanence = lib.mkOption {
        type = lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "impermanence";
            system = lib.mkOption {
              type = lib.types.submodule {
                options = mkPersistenceOptions {
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
                  options = mkPersistenceOptions {
                    dirsDesc = "per user directories to persist";
                    filesDesc = "per user files to persist";
                  };
                });
              default = { };
              description = "Per user persistence config";
              internal = true;
            };
          };
        };
      };
    };

  config = lib.mkIf (cfg.enable && cfg.impermanence.enable) {
    assertions = [
      {
        assertion = cfg.disko.enable;
        message = ''
          Impermanence module has hard dependency on disko module.
          Enable and configure it first.
        '';
      }
    ];

    # https://discourse.nixos.org/t/impermanence-vs-systemd-initrd-w-tpm-unlocking/25167/3
    boot.initrd.systemd = {
      enable = true;
      services.root-subvol-switch = {
        description = "Switch btrfs root subvolume";
        wantedBy = [
          "initrd.target"
        ];
        after = lib.optionals cfg.disko.luksEncryption.enable [
          "systemd-cryptsetup@${cfg.disko.luksEncryption.name}.service"
        ];
        requires = lib.optionals cfg.disko.luksEncryption.enable [
          "systemd-cryptsetup@${cfg.disko.luksEncryption.name}.service"
        ];
        before = [
          "sysroot.mount"
        ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          BLOCK_DEV=${config.fileSystems."/".device}
          ROOT_SUBVOL_NAME=${cfg.disko.reservedSubvols.root.name}

          ${builtins.readFile ./root-subvol-switch}
        '';
      };
    };

    # based on https://github.com/tejing1/nixos-config/blob/46e31a56242d1aee21a4ef9095946f32564e8181/nixosConfigurations/tejingdesk/optin-state.nix#L67-L92
    # and https://github.com/nix-community/impermanence/blob/4b3e914cdf97a5b536a889e939fb2fd2b043a170/README.org?plain=1#L120-L126
    systemd.services.root-subvol-cleanup =
      let
        mountUnit = "${
          builtins.replaceStrings [ "/" ] [ "-" ] (lib.removePrefix "/" cfg.disko.mainDisk.mountpoint)
        }.mount";
      in
      {
        description = "Btrfs root subvolume cleaner";
        startAt = "daily";
        after = [ mountUnit ];
        requires = [ mountUnit ];

        serviceConfig.ExecStart = lib.getExe (
          pkgs.writeShellApplication {
            name = "root-subvol-cleanup";
            runtimeInputs = with pkgs; [
              btrfs-progs
              util-linux
            ];
            text = ''
              RAW_BTRFS_MP=${cfg.disko.mainDisk.mountpoint}
              ROOT_SUBVOL_NAME=${cfg.disko.reservedSubvols.root.name}
              KEEP_MIN=5
              KEEP_DAYS=30

              ${builtins.readFile ./root-subvol-cleanup}
            '';
          }
        );
      };

    fileSystems.${cfg.disko.reservedSubvols.persist.mountpoint}.neededForBoot = true;

    environment.persistence.default = {
      enable = true;
      persistentStoragePath = "${cfg.disko.reservedSubvols.persist.mountpoint}/system";
      hideMounts = true;
      allowTrash = true;
      enableWarnings = true;

      directories = cfg.impermanence.system.dirs;
      inherit (cfg.impermanence.system) files;
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
            persistentStoragePath = cfg.disko.reservedSubvols.persist.mountpoint;
            hideMounts = true;
            allowTrash = true;
            enableWarnings = true;

            directories = normalize userCfg.dirs;
            files = normalize userCfg.files;
          };
        }
      )
    ) cfg.impermanence.perUser;
  };
}
