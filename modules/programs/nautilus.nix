{
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    nautilus
    file-roller
  ];
  services.gvfs.enable = true;
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "ghostty";
  };
  home-manager.sharedModules = lib.singleton {
    xdg.mimeApps.defaultApplications = {
      "inode/directory" = lib.mkBefore [ "nautilus.desktop" ];
    };
  };
  sapphire.storage.impermanence.users.shared.dirs = [
    "@dataHome/gvfs-metadata"
  ];
}