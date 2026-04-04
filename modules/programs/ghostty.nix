{
  lib,
  ...
}:
{
  home-manager.sharedModules = lib.singleton {
    programs.ghostty = {
      enable = true;
      settings.command = "fish";
    };
    home.sessionVariables.TERMINAL = "ghostty";
    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/terminal" = "com.mitchellh.ghostty.desktop";
    };
  };
}