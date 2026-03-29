{
  lib,
  ...
}:
{
  programs.bash.enable = true;
  programs.fish.enable = true;
  home-manager.sharedModules = lib.singleton {
    programs.bash.enable = true;
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
      '';
    };
  };
  sapphire.storage.impermanence.users.shared.dirs = [
    "@dataHome/fish"
  ];
}