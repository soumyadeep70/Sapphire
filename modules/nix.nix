{
  lib,
  config,
  inputs,
  self,
  ...
}:
{
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];

  options.sapphire.nix.enable = lib.mkEnableOption ''
    configure nixpkgs, disable nix channels, use flakes,
    use substituters etc.
  '';

  config = lib.mkIf config.sapphire.nix.enable {
    nixpkgs = {
      config.allowUnfree = true;
      overlays = lib.optional (
        lib.hasAttr "overlays" self && lib.hasAttr "default" self.overlays
      ) self.overlays.default;
    };

    programs.nix-index-database.comma.enable = true;

    nix =
      let
        flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
      in
      {
        registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
        nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

        settings = {
          trusted-users = [ "@wheel" ];
          experimental-features = [
            "nix-command"
            "flakes"
            "pipe-operators"
          ];
          # disable global registry
          flake-registry = "";

          connect-timeout = 5;
          log-lines = 25;
          min-free = 1073741824;
          max-free = 5368709120;
          fallback = true;
          auto-optimise-store = true;
          warn-dirty = false;

          substituters = [
            "https://cache.nixos.org?priority=10"
            "https://hyprland.cachix.org"
            "https://nix-community.cachix.org"
            "https://cache.flox.dev"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
          ];
        };

        channel.enable = false;
      };

    sapphire.storage.impermanence.users.shared = {
      dirs = [
        "@cacheHome/nix"
      ];
      files = [
        "@dataHome/nix/repl-history"
      ];
    };
  };
}
