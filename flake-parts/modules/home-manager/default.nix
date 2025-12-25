# --- flake-parts/modules/home-manager/default.nix
{
  lib,
  ...
}:
{
  options.flake.homeModules = lib.mkOption {
    type = with lib.types; lazyAttrsOf unspecified;
    default = { };
  };

  config.flake.homeModules = {
    # NOTE Dogfooding your modules with `importApply` will make them more
    # reusable even outside of your flake. For more info see
    # https://flake.parts/dogfood-a-reusable-module#example-with-importapply

    # programs_myProgram = importApply ./programs/myProgram { inherit localFlake; };
    # services_myService = importApply ./services/myService { inherit localFlake inputs; };
  };
}
