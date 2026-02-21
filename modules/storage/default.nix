{
  config,
  lib,
  ...
}:
{
  imports = [
    ./disko.nix
    ./impermanence.nix
  ];

  options.sapphire.storage = {
    enable = lib.mkEnableOption "storage config (btrfs filesystem, encryption etc)";
  };

  config = lib.mkIf config.sapphire.storage.enable {
    services = {
      fstrim.enable = true;
      smartd = {
        enable = true;
        autodetect = true;
      };
    };
  };
}
