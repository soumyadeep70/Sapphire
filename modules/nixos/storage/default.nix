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
    inputs.disko.nixosModules.default
    ./disko.nix
  ];

  options.sapphire.nixos.storage = {
    enable = lib.mkEnableOption "storage config (btrfs filesystem, encryption etc)";

    mainDisk = lib.mkOption {
      type = lib.types.submodule {
        options = {
          device = lib.mkOption {
            type = lib.types.strMatching "^/dev.+";
            description = "Main disk device";
            example = "/dev/disk/by-id/nvme-XXXX";
          };
          rawBtrfsMountpoint = lib.mkOption {
            type = lib.types.strMatching "^/[a-zA-Z0-9_]+$";
            default = "/btrfs";
            description = "Mountpoint for the raw unlocked (if encrypted) Btrfs filesystem";
            readOnly = true;
          };
          luksEncryption = lib.mkOption {
            type = lib.types.submodule {
              options = {
                enable = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "Whether to enable full disk encryption using LUKS";
                };
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
          compressionMode = lib.mkOption {
            type = with lib.types; nullOr (strMatching "^(zstd(:[0-9]{1,2})?|lzo)$");
            default = "zstd:1";
            description = "Btrfs compression method (use null to disable compression)";
            example = "lzo";
          };
          # TODO: make it extensible using attrsOf
          subvolumes = lib.mkOption {
            type = lib.types.submodule {
              options = {
                root = lib.mkOption {
                  type = lib.types.submodule {
                    options = {
                      name = lib.mkOption {
                        type = lib.types.strMatching "^[a-zA-Z0-9._@-]+$";
                        default = "root";
                        description = "subvolume name for /";
                      };
                      mountpoint = lib.mkOption {
                        type = lib.types.str;
                        default = "/";
                        readOnly = true;
                      };
                    };
                  };
                  default = { };
                  description = "Btrfs subvolume for /";
                };
                persistent = lib.mkOption {
                  type = lib.types.submodule {
                    options = {
                      name = lib.mkOption {
                        type = lib.types.strMatching "^[a-zA-Z0-9._@-]+$";
                        default = "persist";
                        description = "subvolume name for persistent storage";
                      };
                      mountpoint = lib.mkOption {
                        type = lib.types.strMatching "^/[a-zA-Z0-9._-]+$";
                        default = "/persist";
                        description = "subvolume mountpoint for persistent storage";
                      };
                    };
                  };
                  default = { };
                  description = "Btrfs subvolume for persistent storage";
                };
                nix = lib.mkOption {
                  type = lib.types.submodule {
                    options = {
                      name = lib.mkOption {
                        type = lib.types.strMatching "^[a-zA-Z0-9._@-]+$";
                        default = "nix";
                        description = "subvolume name for /nix";
                      };
                      mountpoint = lib.mkOption {
                        type = lib.types.str;
                        default = "/nix";
                        readOnly = true;
                      };
                    };
                  };
                  default = { };
                  description = "Btrfs subvolume for /nix";
                };
              };
            };
            default = { };
            description = "Btrfs subvolume config";
          };
          swapSize = lib.mkOption {
            type = with lib.types; nullOr (strMatching "^[1-9][0-9]*(M|G)$");
            default = null;
            description = "Swapfile size (use null to disable swap)";
            example = "16G";
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # https://discourse.nixos.org/t/impermanence-vs-systemd-initrd-w-tpm-unlocking/25167/3
    boot.initrd.systemd = {
      enable = true;
      services.root-subvol-switch = {
        description = "Switch btrfs root subvolume";
        wantedBy = [
          "initrd.target"
        ];
        after = lib.optionals cfg.mainDisk.luksEncryption.enable [
          "systemd-cryptsetup@${cfg.mainDisk.luksEncryption.name}.service"
        ];
        requires = lib.optionals cfg.mainDisk.luksEncryption.enable [
          "systemd-cryptsetup@${cfg.mainDisk.luksEncryption.name}.service"
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
          ROOT_SUBVOL_NAME=${cfg.mainDisk.subvolumes.root.name}

          ${builtins.readFile ./root-subvol-switch}
        '';
      };
    };

    # based on https://github.com/tejing1/nixos-config/blob/46e31a56242d1aee21a4ef9095946f32564e8181/nixosConfigurations/tejingdesk/optin-state.nix#L67-L92
    # and https://github.com/nix-community/impermanence/blob/4b3e914cdf97a5b536a889e939fb2fd2b043a170/README.org?plain=1#L120-L126
    systemd.services.root-subvol-cleanup =
      let
        mountUnit = "${
          builtins.replaceStrings [ "/" ] [ "-" ] (lib.removePrefix "/" cfg.mainDisk.rawBtrfsMountpoint)
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
              RAW_BTRFS_MP=${cfg.mainDisk.rawBtrfsMountpoint}
              ROOT_SUBVOL_NAME=${cfg.mainDisk.subvolumes.root.name}
              KEEP_MIN=5
              KEEP_DAYS=30

              ${builtins.readFile ./root-subvol-cleanup}
            '';
          }
        );
      };
  };
}
