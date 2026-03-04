{
  inputs,
  inputs',
  config,
  lib,
  ...
}:
{
  imports = [
    inputs.dank-material-shell.nixosModules.dank-material-shell
  ];

  config = lib.mkIf (config.sapphire.desktop.niri.flavor == "dank-material-shell") {
    programs.dank-material-shell = {
      enable = true;
      enableSystemMonitoring = true;
      dgop.package = inputs'.dgop.packages.default;
    };

    home-manager.sharedModules = lib.singleton {
      programs.niri.settings.spawn-at-startup = [
        {
          argv = [
            "dms"
            "run"
          ];
        }
      ];
    };
  };
}
