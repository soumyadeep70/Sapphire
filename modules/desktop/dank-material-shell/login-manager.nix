{
  inputs,
  lib,
  specs,
  ...
}:
{
  imports = [
    inputs.dank-material-shell.nixosModules.greeter
  ];

  programs.dank-material-shell.greeter = {
    enable = true;
    compositor.name = specs.desktop.backend;
    # configFiles = [
    #   "${cfg.configHome}/.config/DankMaterialShell/settings.json"
    #   "${cfg.configHome}/.local/state/DankMaterialShell/session.json"
    #   "${cfg.configHome}/.cache/DankMaterialShell/dms-colors.json"
    # ];
    logs = {
      save = true;
      path = "/tmp/dms-greeter.log";
    };
  };
}
