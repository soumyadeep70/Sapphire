# --- flake-parts/dev-tooling/default.nix
{ ... }:
{
  imports = [
    ./devShell.nix
    ./pre-commit-hooks.nix
    ./treefmt.nix
  ];
}
