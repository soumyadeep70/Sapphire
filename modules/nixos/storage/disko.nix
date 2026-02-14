{
  lib,
  config,
  ...
}:
let
  cfg = config.sapphire.nixos.storage;

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
      compressionOpt = lib.optional (
        cfg.mainDisk.compressionMode != null
      ) "compress=${cfg.mainDisk.compressionMode}";
    in
    {
      content = {
        type = "btrfs";
        extraArgs = [ "-f" ];
        mountpoint = cfg.mainDisk.rawBtrfsMountpoint;
        mountOptions = [ "noatime" ] ++ compressionOpt;

        subvolumes = {
          "${cfg.mainDisk.subvolumes.root.name}/current" = {
            inherit (cfg.mainDisk.subvolumes.root) mountpoint;
            mountOptions = [ "noatime" ];
          };

          "${cfg.mainDisk.subvolumes.nix.name}" = {
            inherit (cfg.mainDisk.subvolumes.nix) mountpoint;
            mountOptions = [ "noatime" ] ++ compressionOpt;
          };

          "${cfg.mainDisk.subvolumes.persistent.name}" = {
            inherit (cfg.mainDisk.subvolumes.persistent) mountpoint;
            mountOptions = [ "noatime" ] ++ compressionOpt;
          };
        }
        // lib.optionalAttrs (cfg.mainDisk.swapSize != null) {
          "swap" = {
            mountpoint = "/.swapvol";
            swap.swapfile.size = cfg.mainDisk.swapSize;
          };
        };
      };
    };
in
{
  disko.devices = {
    disk."main" = {
      type = "disk";
      inherit (cfg.mainDisk) device;
      content = {
        type = "gpt";

        partitions =
          espConfig
          // (
            if cfg.mainDisk.luksEncryption.enable then
              {
                luks = {
                  size = "100%";
                  content = {
                    type = "luks";
                    inherit (cfg.mainDisk.luksEncryption) name;
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
}
