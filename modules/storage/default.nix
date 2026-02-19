{
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
}
