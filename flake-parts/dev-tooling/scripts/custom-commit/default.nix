{ lib, pkgs }:

rec {
  name = "commit";
  description = "commitizen style commit functionality (interactive)";
  package = pkgs.writeShellScriptBin "${name}" ''
    export PATH=${
      lib.makeBinPath [
        pkgs.git
        pkgs.gum
      ]
    }:$PATH

    exec ${./script.sh} "$@"
  '';
}
