_:
# let
#   cfg = config.sapphire.desktop.utils.interactiveShell;
# in
{
  # options.sapphire.desktop.utils.interactiveShell = {
  #   enable = lib.mkEnableOption ''
  #     interactive-shell module (installs and configure bash/zsh/fish for interactive use)
  #   '';
  #   provider = lib.mkOption {
  #     type = lib.types.enum [ "bash" "zsh" "fish" ];
  #     default = "fish";
  #     description = "Shell for interactive use";
  #   };
  # };

  # config = lib.mkIf cfg.enable (
  #   lib.mkMerge [
  #     (lib.mkIf (cfg.provider == "fish") {
  #       programs.fish.enable = true;

  #     })
  #     (lib.mkIf (cfg.provider == "zsh") {

  #     })
  #   ]
  # );
}
