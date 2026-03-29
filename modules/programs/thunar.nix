{
  lib,
  pkgs,
  ...
}:
{
  # programs.thunar = {
  #   enable = true;
  #   plugins = with pkgs; [
  #     thunar-archive-plugin
  #     thunar-volman
  #     thunar-vcs-plugin
  #     thunar-media-tags-plugin
  #   ];
  # };
  # services.gvfs.enable = true;
  # services.tumbler.enable = true;
  # environment.systemPackages = [
  #   pkgs.file-roller
  # ];
  # home-manager.sharedModules = lib.singleton {
  #   xdg.mimeApps.defaultApplications = {
  #     "inode/directory" = lib.mkBefore [ "thunar.desktop" ];
  #   };
  # };
  # # TODO: apply dms themes and fix theming
  # sapphire.storage.impermanence.users.shared.dirs = [
  #   "@configHome/Thunar"
  #   "@dataHome/gvfs-metadata"
  # ];
}