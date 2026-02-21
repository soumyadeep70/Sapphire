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
  home-manager.sharedModules = lib.singleton {
    programs.niri.config = null;
  };
  # stylix.enable = true;

  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.noctalia-shell = {
    enable = true;
    package = inputs'.noctalia.packages.default;
  };

}
