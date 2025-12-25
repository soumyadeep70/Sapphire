# --- flake-parts/nix-topology/default.nix
{
  inputs,
  self,
  ...
}:
let
  inherit (inputs.flake-parts.lib) importApply;
  localFlake = self;
in
{
  imports = with inputs; [ nix-topology.flakeModule ];

  perSystem = _: {
    topology.modules = [
      { inherit (localFlake) nixosConfigurations; }
      (importApply ./topology.nix { inherit localFlake; })
    ];
  };
}
