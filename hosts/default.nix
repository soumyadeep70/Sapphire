{ 
  lib,
  inputs,
  self,
  withSystem,
  ...
}:
let
  hostDirs = builtins.attrNames (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./.)
  );

  hosts = lib.listToAttrs (
    map (name:
      let
        dir = ./${name};
        specsPath = dir + "/specs.toml";
        specs = if builtins.pathExists specsPath
                then builtins.fromTOML (builtins.readFile specsPath)
                else throw "specs.toml doesn't exist";
      in
      {
        name = name;
        value = {
          system = "${specs.system.arch}-linux";
          config = import dir;
          specs = specs;
        };
      }
    ) hostDirs
  );
in
{
  flake.nixosConfigurations = lib.mapAttrs (
    _name: cfg:
    inputs.nixpkgs.lib.nixosSystem (
      withSystem cfg.system (
        { self', inputs', ... }:
        {
          specialArgs = { inherit (cfg) specs; inherit inputs self; };

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