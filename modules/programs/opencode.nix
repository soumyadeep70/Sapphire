{
  lib,
  ...
}:
{
  home-manager.sharedModules = lib.singleton {
    programs.opencode = {
      enable = true;
      web = {
        enable = true;
        extraArgs = [
          "--hostname" "127.0.0.1"
          "--port"     "4096"
          # "--cors"     "http://localhost:3000"
          "--print-logs"
          "--log-level" "INFO"
        ];
      };
    };
  };
}