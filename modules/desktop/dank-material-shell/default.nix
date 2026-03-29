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
    ./utils.nix
    ./backends/niri.nix
  ];

  config = lib.mkIf (specs.desktop.variant == "dank-material-shell") {
    programs.dank-material-shell = {
      enable = true;
      systemd.enable = false;
      dgop.package = inputs'.dgop.packages.default;
    };

    home-manager.sharedModules = lib.singleton({ config, lib, ... }: {
      imports = [
        inputs.dank-material-shell.homeModules. default
      ];

      programs.dank-material-shell.enable = true;

      home.activation.initDMS = lib.hm.dag.entryAfter ["writeBoundary"] ''
        install -Dm644 ${./settings.json} \
          "${config.xdg.configHome}/DankMaterialShell/settings.json"
        install -Dm644 ${./session.json} \
          "${config.xdg.stateHome}/DankMaterialShell/session.json"
      '';
    });
  };
}
