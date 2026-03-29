{
  lib,
  config,
  specs,
  ...
}:
{
  sapphire.storage.impermanence.users.shared = {
    dirs = [
      "@dataHome/Trash"
      "Downloads"
      "Music"
      "Pictures"
      "Documents"
      "Videos"
    ];
  };

  users.mutableUsers = false;
  users.users = lib.mapAttrs (_: userCfg: {
    isNormalUser = true;
    inherit (userCfg) description hashedPassword;
    extraGroups = userCfg.extraGroups ++ lib.optional userCfg.isAdmin "wheel";
  }) specs.users;

  security.sudo.extraConfig = ''
    Defaults lecture=never
    Defaults timestamp_timeout=30
  '';

  home-manager.users = lib.mapAttrs (user: _userCfg: {
    home = {
      username = user;
      homeDirectory = "/home/${user}";
      inherit (specs.system) stateVersion; # TODO: do smth abt it
    };
  }) specs.users;
}
