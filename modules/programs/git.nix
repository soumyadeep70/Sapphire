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
    # programs.git-credential-keepassxc = {
    #   enable = true;
    #   groups = "Git";
    #   hosts = [
    #     # TODO: extend
    #     "https://github.com"
    #     "https://gitlab.com"
    #   ];
    # };
    # TODO: custom theme
    programs.gitui.enable = true;
  };
}