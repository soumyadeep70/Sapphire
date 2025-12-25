# --- flake-parts/homes/default.nix
{
  lib,
  ...
}:
{
  options.flake.homeConfigurations = lib.mkOption {
    type = with lib.types; lazyAttrsOf unspecified;
    default = { };
  };

  config = {
    flake.homeConfigurations = {
      # "myUser@myHost" = withSystem "x86_64-linux" (
      #   args:
      #   mkHome args "myUser@myHost" {
      #     extraOverlays = with inputs; [
      #       neovim-nightly-overlay.overlays.default
      #       (final: _prev: { nur = import inputs.nur { pkgs = final; }; })
      #     ];
      # }
      # );
    };

    flake.checks."x86_64-linux" = {
      # "home-myUser@myHost" = config.flake.homeConfigurations."myUser@myHost".config.home.path;
    };
  };
}
