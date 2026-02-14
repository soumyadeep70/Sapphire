{
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.files.flakeModules.default
  ];

  perSystem =
    { pkgs, ... }:
    {
      files.files = [
        {
          path_ = "README.md";
          drv = pkgs.writeText "-" (import ./project-readme.nix { inherit config lib; });
        }
        {
          path_ = "hosts/README.md";
          drv = pkgs.writeText "-" (import ./driver-profiles-readme.nix { inherit config lib; });
        }
      ];
    };
}
