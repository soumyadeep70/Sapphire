{
  lib,
  ...
}:
{
  imports = [
    ./disko.nix
    ./impermanence.nix
  ];

  options.sapphire.nixos.storage = {
    enable = lib.mkEnableOption "storage config (btrfs filesystem, encryption etc)";
  };
}
