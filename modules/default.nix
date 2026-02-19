{
  lib,
  ...
}:
let
  importModulesRecursive =
    path:
    if builtins.pathExists (path + "/default.nix") then
      [ (path + "/default.nix") ]
    else
      builtins.readDir path
      |> lib.mapAttrsToList (
        name: type:
        if lib.hasPrefix "_" name then
          [ ]
        else if type == "regular" && lib.hasSuffix ".nix" name then
          [ (path + "/${name}") ]
        else if type == "directory" then
          importModulesRecursive (path + "/${name}")
        else
          [ ]
      )
      |> lib.flatten;

  importModules =
    path:
    builtins.readDir path
    |> lib.mapAttrsToList (
      name: type:
      if name == "default.nix" || lib.hasPrefix "_" name then
        [ ]
      else if type == "regular" && lib.hasSuffix ".nix" name then
        [ (path + "/${name}") ]
      else if type == "directory" then
        importModulesRecursive (path + "/${name}")
      else
        [ ]
    )
    |> lib.flatten;
in
{
  flake.nixosModules.sapphire =
    {
      inputs,
      inputs',
      self,
      self',
      ...
    }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ]
      ++ importModules ./.;

      home-manager = {
        extraSpecialArgs = {
          inherit
            inputs
            inputs'
            self
            self'
            ;
        };
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    };
}
