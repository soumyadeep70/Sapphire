{
  lib,
  ...
}:
{
  home-manager.sharedModules = lib.singleton {
    programs.starship = {
      enable = true;
      enableTransience = true;
    };
  };
}