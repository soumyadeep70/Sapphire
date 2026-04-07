{
  lib,
  specs,
  ...
}:
{
  config = lib.mkIf specs.services.docker.enable {
    virtualisation.docker.enable = true;
    users.groups."docker".members = builtins.attrNames specs.core.users;
  };
}