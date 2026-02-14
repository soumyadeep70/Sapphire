{
  lib,
  config,
  ...
}:
{
  options.sapphire.nixos.security.enable = lib.mkEnableOption "security config";

  config = lib.mkIf config.sapphire.nixos.security.enable {
    security = {
      rtkit.enable = true;
      tpm2.enable = true;

      sudo.extraConfig = ''
        Defaults lecture=never
        Defaults timestamp_timeout=30
      '';

      polkit = {
        enable = true;
        # extraConfig = ''
        #   polkit.addRule(function(action, subject) {
        #     if (
        #       subject.isInGroup("users")
        #         && (
        #           action.id == "org.freedesktop.login1.reboot" ||
        #           action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
        #           action.id == "org.freedesktop.login1.power-off" ||
        #           action.id == "org.freedesktop.login1.power-off-multiple-sessions"
        #         )
        #       )
        #     {
        #       return polkit.Result.YES;
        #     }
        #   })
        # '';
      };
    };
  };
}
