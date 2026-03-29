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
      lib.flatten (
        lib.mapAttrsToList (
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
        (builtins.readDir path) 
      );

  importModules =
    path:
    lib.flatten (
      lib.mapAttrsToList (
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
      (builtins.readDir path)
    );
in
{
  flake.nixosModules.sapphire =
    {
      inputs,
      inputs',
      self,
      self',
      config,
      ...
    }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ]
      ++ importModules ./.;

      nixpkgs.overlays = [
        self.overlays.default
      ];

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
