{
  lib,
  ...
}:
{
  home-manager.sharedModules = lib.singleton {
    programs.ghostty = {
      enable = true;
      settings = {
        theme = "dankcolors";
        command = "fish";
      };
    };
    xdg.configFile."ghostty/config".onChange = "";
    home.sessionVariables.TERMINAL = "ghostty";
    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/terminal" = "com.mitchellh.ghostty.desktop";
    };
  };
}