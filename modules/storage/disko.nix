{
  inputs,
  lib,
  config,
  ...
}:
let
  cfg = config.sapphire.storage;
in
{
  imports = [
    inputs.disko.nixosModules.default
  ];

  options.sapphire.storage = {
    disko = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "disko (declarative disk management tool)";
          mainDisk = lib.mkOption {
            type = lib.types.submodule {
              options = {
                device = lib.mkOption {
                  type = lib.types.strMatching "^/dev/.+";
                  description = "Main disk device (where nixos will be installed)";
                  example = "/dev/disk/by-id/nvme-XXXX";
                };
                mountpoint = lib.mkOption {
                  type = lib.types.strMatching "^/([a-zA-Z0-9_]+/)*[a-zA-Z0-9_]+$";
                  default = "/btrfs";
                  description = "Mountpoint for the raw unlocked (if encrypted) Btrfs filesystem";
                  example = "/mnt/btrfs";
                };
              };
            };
            description = "Main disk config";
          };
          luksEncryption = lib.mkOption {
            type = lib.types.submodule {
              options = {
                enable = lib.mkEnableOption "full disk encryption using LUKS";
                name = lib.mkOption {
                  type = lib.types.strMatching "^[a-zA-Z0-9._-]+$";
                  default = "cryptroot";
                  description = "Name of LUKS mapper device";
                };
              };
            };
            default = { };
            description = "LUKS encryption config";
          };
          compression = lib.mkOption {
            type = lib.types.submodule {
              options = {
                enable = lib.mkEnableOption ''
                  compression for the btrfs filesystem and its subvolumes
                '';
                mode = lib.mkOption {
                  type = lib.types.strMatching "^(zstd(:[0-9]{1,2})?|lzo)$";
                  default = "zstd:1";
                  description = "Btrfs compression method";
                  example = "lzo";
                };
              };
            };
            default = { };
            description = "Btrfs compression config";
          };
          reservedSubvols = lib.mkOption {
            type =
              with lib.types;
              attrsOf (submodule {
                options = {
                  name = lib.mkOption {
                    type = lib.types.str;
                    internal = true;
                  };
                  mountpoint = lib.mkOption {
                    type = lib.types.str;
                    internal = true;
                  };
                };
              });
            default = {
              root = {
                name = "root";
                mountpoint = "/";
              };
              persist = {
                name = "persist";
                mountpoint = "/persist";
              };
              nix = {
                name = "nix";
                mountpoint = "/nix";
              };
              swap = {
                name = "swap";
                mountpoint = "/.swapvol";
              };
            };
            description = "Reserved internal btrfs subvolumes";
            internal = true;
            readOnly = true;
          };
          extraSubvols = lib.mkOption {
            type =
              with lib.types;
              attrsOf (
                submodule (
                  { name, ... }:
                  {
                    options = {
                      name = lib.mkOption {
                        type = lib.types.strMatching "^[a-zA-Z0-9._@-]+$";
                        default = name;
                        description = "name of the subvolume (equals to the attr name by default)";
                      };
                      mountpoint = lib.mkOption {
                        type = lib.types.strMatching "^/([a-zA-Z0-9._-]+/)*[a-zA-Z0-9._-]+$";
                        default = "/${name}";
                        description = "mountpoint of the subvolume";
                      };
                    };
                  }
                )
              );
            default = { };
            description = lib.literalMD ''
              Btrfs subvolume config. Subvolume names `root`, `persist`, `nix`
              `swap` and mountpoints `/`, `/persist`, `/nix`, `/.swapvol` are reserved.
            '';
          };
          swap = lib.mkOption {
            type = lib.types.submodule {
              options = {
                enable = lib.mkEnableOption "swap";
                size = lib.mkOption {
                  type = lib.types.strMatching "^[1-9][0-9]*(M|G|T)$";
                  default = "4G";
                  description = "swapfile size";
                  example = "16G";
                };
              };
            };
            default = { };
            description = "Swap configuration";
          };
        };
      };
    };
  };

  config =
    let
      espConfig = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
      };

      btrfsConfig =
        let
          compressionOpt = lib.optional cfg.disko.compression.enable "compress=${cfg.disko.compression.mode}";
        in
        {
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            inherit (cfg.disko.mainDisk) mountpoint;
            mountOptions = [ "noatime" ] ++ compressionOpt;

            subvolumes = {
              "${cfg.disko.reservedSubvols.root.name}/current" = {
                inherit (cfg.disko.reservedSubvols.root) mountpoint;
                mountOptions = [ "noatime" ];
              };
              "${cfg.disko.reservedSubvols.persist.name}" = {
                inherit (cfg.disko.reservedSubvols.persist) mountpoint;
                mountOptions = [ "noatime" ] ++ compressionOpt;
              };
              "${cfg.disko.reservedSubvols.nix.name}" = {
                inherit (cfg.disko.reservedSubvols.nix) mountpoint;
                mountOptions = [ "noatime" ] ++ compressionOpt;
              };
            }
            // lib.optionalAttrs cfg.disko.swap.enable {
              "${cfg.disko.reservedSubvols.swap.name}" = {
                inherit (cfg.disko.reservedSubvols.swap) mountpoint;
                swap.swapfile.size = cfg.disko.swap.size;
              };
            }
            // lib.mapAttrs' (
              _: subvolCfg:
              lib.nameValuePair "${subvolCfg.name}" {
                inherit (subvolCfg) mountpoint;
                mountOptions = [ "noatime" ] ++ compressionOpt;
              }
            ) cfg.disko.extraSubvols;
          };
        };
    in
    lib.mkIf (cfg.enable && cfg.disko.enable) {
      assertions = [
        (
          let
            conflictNames = lib.intersectLists (lib.mapAttrsToList (_: v: v.name) cfg.disko.reservedSubvols) (
              lib.mapAttrsToList (_: v: v.name) cfg.disko.extraSubvols
            );
          in
          {
            assertion = conflictNames == [ ];
            message = ''
              Reserved subvolume name(s) reused:
              ${lib.concatStringsSep ", " conflictNames}
            '';
          }
        )
        (
          let
            conflictMounts = lib.intersectLists (lib.mapAttrsToList (
              _: v: v.mountpoint
            ) cfg.disko.reservedSubvols) (lib.mapAttrsToList (_: v: v.mountpoint) cfg.disko.extraSubvols);
          in
          {
            assertion = conflictMounts == [ ];
            message = ''
              Reserved subvolume mountpoint(s) reused:
              ${lib.concatStringsSep ", " conflictMounts}
            '';
          }
        )
        (
          let
            extraNames = lib.mapAttrsToList (_: v: v.name) cfg.disko.extraSubvols;
            duplicateNames = builtins.attrNames (
              lib.filterAttrs (_: v: builtins.length v > 1) (builtins.groupBy (x: x) extraNames)
            );
          in
          {
            assertion = duplicateNames == [ ];
            message = ''
              Duplicate subvolume name(s) detected:
              ${lib.concatStringsSep ", " duplicateNames}
            '';
          }
        )
        (
          let
            extraMounts = lib.mapAttrsToList (_: v: v.mountpoint) cfg.disko.extraSubvols;
            duplicateMounts = builtins.attrNames (
              lib.filterAttrs (_: v: builtins.length v > 1) (builtins.groupBy (x: x) extraMounts)
            );
          in
          {
            assertion = duplicateMounts == [ ];
            message = ''
              Duplicate subvolume mountpoint(s) detected:
              ${lib.concatStringsSep ", " duplicateMounts}
            '';
          }
        )
      ];

      disko.devices = {
        disk."main" = {
          type = "disk";
          inherit (cfg.disko.mainDisk) device;
          content = {
            type = "gpt";
            partitions =
              espConfig
              // (
                if cfg.disko.luksEncryption.enable then
                  {
                    luks = {
                      size = "100%";
                      content = {
                        type = "luks";
                        inherit (cfg.disko.luksEncryption) name;
                        settings.allowDiscards = true;
                        inherit (btrfsConfig) content;
                      };
                    };
                  }
                else
                  {
                    btrfs = btrfsConfig;
                  }
              );
          };
        };
      };

      security.tpm2.enable = lib.mkDefault cfg.disko.luksEncryption.enable;
    };
}
