# --- flake-parts/hosts/default.nix
_: {
  flake.nixosConfigurations = {
    # myExampleHost = withSystem "x86_64-linux" (
    #   args:
    #   mkHost args "myExampleHost" {
    #     withHomeManager = true;
    #     extraOverlays = with inputs; [
    #       neovim-nightly-overlay.overlays.default
    #       (final: _prev: { nur = import inputs.nur { pkgs = final; }; })
    #     ];
    #   }
    # );
  };
}
