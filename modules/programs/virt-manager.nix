{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.sapphire.programs.virt-manager = {
    enable = lib.mkEnableOption "virt-manager";
  };

  config = lib.mkIf config.sapphire.programs.virt-manager.enable {
    programs.virt-manager.enable = true;

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
    };

    users.users = lib.genAttrs (builtins.attrNames config.sapphire.users) (_: {
      extraGroups = [ "libvirtd" ];
    });

    sapphire.storage.impermanence.system.dirs = [
      "/var/lib/libvirt"
      "/var/lib/swtpm-localca"
    ];
  };
}
