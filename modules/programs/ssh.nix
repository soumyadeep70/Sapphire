{
  self,
  config,
  lib,
  ...
}:
{
  sops.secrets = {
    github_ssh_key = {
      sopsFile = self + "/secrets/shared/ssh_keys.yaml";
      key = "github";
      group = "secrets";
      mode = "0440";
    };
    gitlab_ssh_key = {
      sopsFile = self + "/secrets/shared/ssh_keys.yaml";
      key = "gitlab";
      group = "secrets";
      mode = "0440";
    };
  };

  home-manager.sharedModules = lib.singleton {
    programs.ssh = {
      enable = true;
      matchBlocks = {
        "github.com" = {
          user = "git";
          hostname = "github.com";
          identityFile = config.sops.secrets.github_ssh_key.path;
          identitiesOnly = true;
        };
        "gitlab.com" = {
          user = "git";
          hostname = "gitlab.com";
          identityFile = config.sops.secrets.gitlab_ssh_key.path;
          identitiesOnly = true;
        };
      };
    };
  };
}