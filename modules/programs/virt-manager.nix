{
  lib,
  pkgs,
  specs,
  ...
}:
{
  config = lib.mkIf (specs.programs.virt-manager.enable) {
    programs.virt-manager.enable = true;

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
    };

    users.groups."libvirtd".members = builtins.attrNames specs.core.users;

    sapphire.storage.impermanence.system.dirs = [
      "/var/lib/libvirt"
      "/var/lib/swtpm-localca"
    ];
  };
}
