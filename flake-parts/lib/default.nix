# --- flake-parts/lib/default.nix
_: {
  flake.lib = {
    # modules = import ./modules { inherit localFlake lib inputs; };
    # functions = import ./functions { inherit localFlake lib; };
  };
}
