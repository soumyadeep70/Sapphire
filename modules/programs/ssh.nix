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
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          forwardAgent = false;
          addKeysToAgent = "no";
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
        };
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