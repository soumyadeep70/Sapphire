{
  lib,
  ...
}:
let
  importModules =
    path:
    let
      entries = builtins.readDir path;
      defaultPath = path + "/default.nix";
    in
    if builtins.pathExists defaultPath then
      [ defaultPath ]
    else
      lib.flatten (
        lib.mapAttrsToList (
          name: type:
          let
            p = path + "/${name}";
          in
          if lib.hasPrefix "_" name then
            [ ]
          else if type == "regular" && lib.hasSuffix ".nix" name then
            [ p ]
          else if type == "directory" then
            importModules p
          else
            [ ]
        ) entries
      );
in
{
  flake = {
    nixosModules.sapphire =
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
        ++ importModules ./nixos;

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

    # homeModules.sapphire = inputs.import-tree ./home;
  };
}
