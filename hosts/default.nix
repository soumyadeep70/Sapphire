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
        specs = {
          core = 
            if builtins.pathExists (dir + "/core.toml") then 
              fromTOML (builtins.readFile (dir + "/core.toml"))
            else
              throw "core.toml doesn't exist";
          programs = 
            if builtins.pathExists (dir + "/programs.toml") then 
              fromTOML (builtins.readFile (dir + "/programs.toml"))
            else
              throw "programs.toml doesn't exist";
          services = 
            if builtins.pathExists (dir + "/services.toml") then 
              fromTOML (builtins.readFile (dir + "/services.toml"))
            else
              throw "services.toml doesn't exist";
          desktop = 
            if builtins.pathExists (dir + "/desktop.toml") then 
              fromTOML (builtins.readFile (dir + "/desktop.toml"))
            else
              throw "desktop.toml doesn't exist";
        };
      in
      {
        name = name;
        value = {
          system = "${specs.core.system.arch}-linux";
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
          specialArgs = { specs = builtins.trace (builtins.toJSON cfg.specs) cfg.specs; inherit inputs self; };

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