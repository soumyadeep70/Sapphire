{
  inputs,
  inputs',
  lib,
  specs,
  ...
}:
{
  imports = [
    inputs.dank-material-shell.nixosModules.default
    ./login-manager.nix
    ./theming.nix
    ./xdg.nix
    ./backends/niri.nix
  ];

  config = lib.mkIf (specs.desktop.variant == "dank-material-shell") {
    programs.dank-material-shell = {
      enable = true;
      systemd.enable = false;
      dgop.package = inputs'.dgop.packages.default;
    };

    home-manager.sharedModules = lib.singleton ({ config, ... }: {
      imports = [
        inputs.dank-material-shell.homeModules.default
      ];

      programs.dank-material-shell.enable = true;

      #TODO: remove hardcoded path
      xdg.configFile."DankMaterialShell/settings.json".source = 
        config.lib.file.mkOutOfStoreSymlink "/home/cypher/Downloads/sapphire/modules/desktop/dank-material-shell/settings.json";
      xdg.stateFile."DankMaterialShell/session.json".source = 
        config.lib.file.mkOutOfStoreSymlink "/home/cypher/Downloads/sapphire/modules/desktop/dank-material-shell/session.json";
    });
  };
}
