# --- flake-parts/treefmt.nix
{ inputs, ... }:
{
  imports = with inputs; [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        # treefmt is a formatting tool that saves you time
        # - https://numtide.github.io/treefmt/
        # - https://github.com/numtide/treefmt-nix
        package = pkgs.treefmt;
        flakeCheck = true;
        flakeFormatter = true;
        projectRootFile = "flake.nix";

        settings = {
          global.excludes = [
            "*.age"
          ];
          shellcheck.includes = [
            "*.sh"
            ".envrc"
          ];
          prettier.editorconfig = true;
        };

        programs = {
          deadnix.enable = true;
          statix.enable = true;
          nixfmt.enable = true;

          prettier.enable = true;
          yamlfmt.enable = true;
          jsonfmt.enable = true;
          # mdformat.enable = true;

          # shellcheck.enable = true;
          # shfmt.enable = true;

          # actionlint.enable = true;
          # mdsh.enable = true;
        };
      };
    };
}
