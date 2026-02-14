{
  lib,
  inputs,
  self,
  withSystem,
  ...
}:
let
  hosts = {
    atlas = {
      system = "x86_64-linux";
      config = import ./atlas;
    };
  };
in
{
  flake.nixosConfigurations = lib.mapAttrs (
    _name: cfg:
    inputs.nixpkgs.lib.nixosSystem (
      withSystem cfg.system (
        { self', inputs', ... }:
        {
          specialArgs = { inherit inputs self; };

          modules = [
            {
              _module.args = { inherit self' inputs'; };
              nixpkgs.hostPlatform = cfg.system;
            }
            cfg.config
          ];
        }
      )
    )
  ) hosts;
}
