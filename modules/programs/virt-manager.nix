{
  lib,
  config,
  pkgs,
  specs,
  ...
}:
{
  # programs.virt-manager.enable = true;

  # virtualisation.libvirtd = {
  #   enable = true;
  #   qemu = {
  #     swtpm.enable = true;
  #     vhostUserPackages = [ pkgs.virtiofsd ];
  #   };
  # };

  # users.groups."libvirtd".members = builtins.attrNames specs.users;

  # sapphire.storage.impermanence.system.dirs = [
  #   "/var/lib/libvirt"
  #   "/var/lib/swtpm-localca"
  # ];
}
