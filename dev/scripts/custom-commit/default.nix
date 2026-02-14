{ pkgs }:

rec {
  name = "commit";
  description = "commitizen style commit functionality (interactive)";
  package = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      git
      gum
      pre-commit
    ];
    text = builtins.readFile ./script.sh;
  };
}
