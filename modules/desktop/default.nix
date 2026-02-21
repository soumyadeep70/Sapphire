{
  inputs,
  inputs',
  lib,
  pkgs,
  ...
}:

{
  imports = [
    inputs.niri-flake.nixosModules.niri
    # inputs.stylix.nixosModules.stylix
    inputs.noctalia.nixosModules.default
  ];

  nixpkgs.overlays = [ inputs.niri-flake.overlays.niri ];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  programs.niri = {
    enable = true;
    package = pkgs.niri-stable;
  };
  # stylix.enable = true;

  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  home-manager.sharedModules = lib.singleton {
    imports = [
      inputs.noctalia.homeModules.default
    ];
    programs.niri.config = null;
    programs.noctalia-shell = {
      systemd.enable = true;
      package = inputs'.noctalia.packages.default;
    };
    programs.ghostty = {
      enable = true;
      systemd.enable = true;
    };
  };
}
