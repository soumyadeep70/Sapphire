{
  lib,
  pkgs,
  ...
}:
{
  home-manager.sharedModules = lib.singleton {
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      settings = {
        # TODO: modularize it
        user = {
          name = "soumyadeep70";
          email = "soumyadeepdash70@gmail.com";
        };
        push.default = "simple";
        init.defaultBranch = "main";
        log.decorate = "full";
        log.date = "iso";
        merge.conflictStyle = "diff3";
      };
      lfs.enable = true;
    };
    programs.gitui.enable = true;

    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = false;
      settings.git_protocol = "ssh";
    };
    programs.gh-dash.enable = true;
  };
}